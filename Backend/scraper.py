from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
from datetime import date
from supabase import create_client
import re
import time

SUPABASE_URL = "https://cwficgymseewxmadzwfu.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3ZmljZ3ltc2Vld3htYWR6d2Z1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5MTg3MTEsImV4cCI6MjA5MDQ5NDcxMX0.fNoyk5-BH_A-jyb1hTbKXCLDF80whdj9k_vddqhnYTE"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

DINING_HALLS = {
    "marciano": 1,
    "warren": 2,
    "west": 3,
    "fenway": 4,
}

def get_driver():
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("user-agent=Mozilla/5.0")
    driver = webdriver.Chrome(
        service=Service(ChromeDriverManager().install()),
        options=options
    )
    return driver

def get_meal_type(text):
    text = text.lower()
    if "breakfast" in text:
        return "breakfast"
    elif "dinner" in text:
        return "dinner"
    elif "brunch" in text:
        return "brunch"
    return "lunch"

def extract_number(pattern, text):
    match = re.search(pattern, text, re.IGNORECASE)
    return int(match.group(1)) if match else None

def scrape_hall(driver, slug):
    url = f"https://www.bu.edu/dining/location/{slug}/#menu"
    driver.get(url)
    
    # Wait for menu items to load
    try:
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, ".meal-items, .menu-item, [class*='menu']"))
        )
    except:
        pass
    
    time.sleep(3)  # extra wait for JS to finish rendering
    
    soup = BeautifulSoup(driver.page_source, "html.parser")
    today = date.today().isoformat()
    items = []
    current_meal = "lunch"

    # Find all meal sections by looking for meal headers
    meal_headers = soup.find_all(["h2", "h3", "h4", "h5"])
    
    for header in meal_headers:
        header_text = header.get_text(strip=True)
        if any(m in header_text.lower() for m in ["breakfast", "lunch", "dinner", "brunch"]):
            current_meal = get_meal_type(header_text)
            
            # Get all menu items under this header
            sibling = header.find_next_sibling()
            while sibling:
                # Stop if we hit another meal header
                if sibling.name in ["h2", "h3", "h4", "h5"] and any(
                    m in sibling.get_text().lower() 
                    for m in ["breakfast", "lunch", "dinner", "brunch"]
                ):
                    break
                
                # Find individual food items
                food_items = sibling.find_all(["li", "div"], recursive=True)
                for food in food_items:
                    food_text = food.get_text(separator=" ", strip=True)
                    
                    # Skip very short or very long blocks
                    if len(food_text) < 3 or len(food_text) > 300:
                        continue
                    
                    # Must have calorie info to be a real menu item
                    if not re.search(r'\d+\s*cals?', food_text, re.IGNORECASE):
                        continue

                    # Try to get just the item name (first line / bold text)
                    name_tag = food.find(["strong", "b", "h3", "h4", "h5", "span"])
                    name = name_tag.get_text(strip=True) if name_tag else food_text.split("\n")[0].strip()
                    
                    # Skip if name is empty, too short, or just a number
                    if not name or len(name) < 3:
                        continue
                    if name.strip().isdigit():
                        continue
                    if re.match(r'^\d+(\.\d+)?g?$', name.strip()):
                        continue

                    item = {
                        "dining_hall_id": DINING_HALLS[slug],
                        "date": today,
                        "meal_type": current_meal,
                        "name": name[:200],
                        "calories": extract_number(r'(\d+)\s*cals?', food_text),
                        "protein_g": extract_number(r'(\d+)g\s*protein', food_text),
                        "carbs_g": extract_number(r'(\d+)g\s*carbs?', food_text),
                        "sat_fat_g": extract_number(r'(\d+)g\s*sat', food_text),
                        "sugars_g": extract_number(r'(\d+)g\s*sugars?', food_text),
                        "fat_g": None,
                        "is_vegetarian": "Vegetarian" in food_text,
                        "is_vegan": "Vegan" in food_text,
                        "is_gluten_free": "Gluten Free" in food_text,
                        "is_halal": "Halal" in food_text,
                    }
                    items.append(item)
                
                sibling = sibling.find_next_sibling()

    # Deduplicate by name
    seen = set()
    unique_items = []
    for item in items:
        if item["name"] not in seen:
            seen.add(item["name"])
            unique_items.append(item)

    return unique_items

def main():
    today = date.today().isoformat()
    driver = get_driver()

    try:
        # Clear today's data
        supabase.table("menu_items").delete().eq("date", today).execute()

        for slug in DINING_HALLS:
            print(f"Scraping {slug}...")
            try:
                items = scrape_hall(driver, slug)
                if items:
                    supabase.table("menu_items").insert(items).execute()
                    print(f"  ✓ Inserted {len(items)} items for {slug}")
                    for item in items[:3]:  # preview first 3
                        print(f"    - {item['name']} ({item['calories']} cals)")
                else:
                    print(f"  ⚠ No items found for {slug}")
            except Exception as e:
                print(f"  ✗ Error scraping {slug}: {e}")
    finally:
        driver.quit()

if __name__ == "__main__":
    main()