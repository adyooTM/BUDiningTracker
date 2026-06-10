import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuPage extends StatefulWidget {
  final int diningHallId;
  final String diningHallName;

  const MenuPage({
    super.key,
    required this.diningHallId,
    required this.diningHallName,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  Map<String, List<Map<String, dynamic>>> _menuByMeal = {};
  bool _isLoading = true;
  String? _error;

  final List<String> _mealTypes = ['breakfast', 'lunch', 'brunch', 'dinner'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchMenu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMenu() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('dining_hall_id', widget.diningHallId)
          .eq('date', today)
          .order('meal_type');

      final items = List<Map<String, dynamic>>.from(response);
      final grouped = <String, List<Map<String, dynamic>>>{};

      for (final meal in _mealTypes) {
        grouped[meal] =
            items.where((i) => i['meal_type'] == meal).toList();
      }

      setState(() {
        _menuByMeal = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load menu. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.diningHallName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFCC0000),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Breakfast'),
            Tab(text: 'Lunch'),
            Tab(text: 'Brunch'),
            Tab(text: 'Dinner'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFCC0000)))
          : _error != null
              ? Center(child: Text(_error!))
              : TabBarView(
                  controller: _tabController,
                  children: _mealTypes
                      .map((meal) => _MealList(
                            items: _menuByMeal[meal] ?? [],
                            mealType: meal,
                          ))
                      .toList(),
                ),
    );
  }
}

class _MealList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String mealType;

  const _MealList({required this.items, required this.mealType});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😴', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'No $mealType items today',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (mealType == 'breakfast' && index == 0) {
          return const _OmeletStation();
        }
        final item = items[index];
        return _MenuItemCard(item: item);
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final calories = item['calories'];
    final protein = item['protein_g'];
    final carbs = item['carbs_g'];
    final fat = item['sat_fat_g'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + calories + button row
          Row(
            children: [
              Expanded(
                child: Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (calories != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC0000).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$calories cal',
                    style: const TextStyle(
                      color: Color(0xFFCC0000),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // your action here
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCC0000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          // Dietary tags
          if (item['is_vegan'] == true ||
              item['is_vegetarian'] == true ||
              item['is_gluten_free'] == true ||
              item['is_halal'] == true) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                if (item['is_vegan'] == true) _Tag('Vegan', Colors.green),
                if (item['is_vegetarian'] == true && item['is_vegan'] != true)
                  _Tag('Vegetarian', Colors.lightGreen),
                if (item['is_gluten_free'] == true)
                  _Tag('GF', Colors.orange),
                if (item['is_halal'] == true) _Tag('Halal', Colors.blue),
              ],
            ),
          ],

          // Nutrition row
          if (protein != null || carbs != null || fat != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (protein != null)
                  _NutrientInfo('Protein', '${protein}g', Colors.blue),
                if (carbs != null)
                  _NutrientInfo('Carbs', '${carbs}g', Colors.orange),
                if (fat != null)
                  _NutrientInfo('Sat. Fat', '${fat}g', Colors.red),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Widget _Tag(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _NutrientInfo(String label, String value, Color color) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    ],
  );
}

class _OmeletStation extends StatefulWidget {
  const _OmeletStation();

  @override
  State<_OmeletStation> createState() => _OmeletStationState();
}

class _OmeletStationState extends State<_OmeletStation> {
  bool _isExpanded = false;
  final List<String> _selected = [];
  List<Map<String, dynamic>> _ingredients = [];
  bool _isLoading = true;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  Future<void> _fetchIngredients() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _supabase
        .from('omelet_ingredients')
        .select()
        .eq('date', today)
        .eq('dining_hall_id', 1);

    setState(() {
      _ingredients = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  int get _totalCalories => _selected.fold(0, (sum, name) {
    final match = _ingredients.firstWhere(
      (i) => i['name'] == name,
      orElse: () => {'calories': 0},
    );
    return sum + ((match['calories'] ?? 0) as int);
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header / toggle row ──
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('🍳', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Create Your Own Omelet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_selected.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC0000).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_totalCalories cal',
                        style: const TextStyle(
                          color: Color(0xFFCC0000),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // ── Dropdown ingredient list ──
          if (_isExpanded) ...[
            const Divider(height: 1),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: Color(0xFFCC0000)),
              )
            else if (_ingredients.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No omelet ingredients available today.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  final name = ingredient['name'] as String;
                  final isAdded = _selected.contains(name);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Name + button row ──
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // your action
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isAdded ? Colors.green : const Color(0xFFCC0000),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isAdded ? Icons.check : Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _NutrientInfo('Protein', '${ingredient['protein_g']}g', Colors.blue),
                            _NutrientInfo('Carbs', '${ingredient['carbs_g']}g', Colors.orange),
                            _NutrientInfo('Sat. Fat', '${ingredient['sat_fat_g']}g', Colors.red),
                          ],
                        ),  
                      ],
                    ),
                  );
                },
              ),

            // ── Selected summary ──
            if (_selected.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'Your omelet: ${_selected.join(', ')}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}