from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
from datetime import date
from datetime import datetime
from supabase import create_client
import re
import time
import requests


SUPABASE_URL = "https://cwficgymseewxmadzwfu.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3ZmljZ3ltc2Vld3htYWR6d2Z1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5MTg3MTEsImV4cCI6MjA5MDQ5NDcxMX0.fNoyk5-BH_A-jyb1hTbKXCLDF80whdj9k_vddqhnYTE"

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

DINING_HALLS = {
    "marciano": 1,
    "warren": 2,
    "west": 3,
    "granby": 4, 
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

    # Lock onto ONLY today's list container so future dates are invisible
    today_ol_container = soup.find("ol", class_="js-menu-bydate menu-area background-opaque menubydate-active")
    
    if not today_ol_container:
        print(f"  ⚠ Could not find today's active menu container for {slug}!")
        return []

    # Search for headers ONLY inside today's container, not 'soup'
    meal_headers = today_ol_container.find_all(["h2", "h3", "h4", "h5"])

    current_meal = None

    # Everything below this line is YOUR exact original working code
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

                    if any(bad in food_text.lower() for bad in ["ingredients:", "create your own", "create your own omelet station", "grill works"]):
                        continue
                    
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

def scrape_Marci_omelet_ingredients(driver):
    today = date.today().isoformat()

    driver.get("https://www.bu.edu/dining/location/marciano/")

    WebDriverWait(driver, 15).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "section.cyo-nutrition-facts"))
    )

    cyo_sections = driver.find_elements(By.CSS_SELECTOR, "li.menu-item")
    omelet_ul = None

    for section in cyo_sections:
        try:
            text = section.get_attribute("innerHTML").lower()
            if "omelet" in text:
                omelet_ul = section.find_element(By.CLASS_NAME, "nutrition-label-cyo")
                break
        except:
            continue

    if not omelet_ul:
        print("  ✗ Omelet station not found")
        return

    ingredient_rows = omelet_ul.find_elements(
        By.CSS_SELECTOR, "li.nutrition-label-cyo-section"
    )

    ingredients = []

    for row in ingredient_rows:
        try:
            name = row.find_element(
                By.CSS_SELECTOR, "h3.nutrition-title"
            ).get_attribute("textContent").replace("Nutrition Facts", "").strip()

            calories_text = row.find_element(
                By.CLASS_NAME, "nutrition-label-cyo-cals"
            ).get_attribute("textContent").strip()
            calories = int(re.search(r"\d+", calories_text).group()) if re.search(r"\d+", calories_text) else 0

            def get_nutrient(label):
                trs = row.find_elements(
                    By.CSS_SELECTOR, "tr.nutrition-label-section, tr.nutrition-label-subsection"
                )
                for r in trs:
                    try:
                        nutrient = r.find_element(
                            By.CLASS_NAME, "nutrition-label-nutrient"
                        ).get_attribute("textContent").strip()
                        if label.lower() in nutrient.lower():
                            amount = r.find_element(
                                By.CLASS_NAME, "nutrition-label-amount"
                            ).get_attribute("textContent").strip()
                            return int(re.search(r"\d+", amount).group())
                    except:
                        continue
                return 0

            ingredients.append({
                "dining_hall_id": 1,
                "date": today,
                "name": name,
                "calories": calories,
                "protein_g": get_nutrient("Protein"),
                "carbs_g": get_nutrient("Total Carbohydrate"),
                "sat_fat_g": get_nutrient("Saturated Fat"),
            })

            print(f"    - scraped: {name} ({calories} cal)")

        except Exception as e:
            print(f"  ✗ Error scraping ingredient: {e}")
            continue

    if ingredients:
        supabase.table("omelet_ingredients").delete().eq("date", today).execute()
        supabase.table("omelet_ingredients").insert(ingredients).execute()
        print(f"  ✓ Inserted {len(ingredients)} omelet ingredients for {today}")
    else:
        print("  ✗ No omelet ingredients found")
        return

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
        print("Scraping omelet ingredients...")
        try:
            scrape_Marci_omelet_ingredients(driver)
        except Exception as e:
            print(f"  ✗ Error scraping omelet ingredients: {e}")
    finally:
        driver.quit()

if __name__ == "__main__":
    main()