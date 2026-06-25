import 'package:flutter/foundation.dart';

/// A single line in the cart: one menu item plus how many were added.
class CartLine {
  final Map<String, dynamic> item;
  int quantity;
  CartLine(this.item, this.quantity);
}

/// App-wide cart. A simple singleton [ChangeNotifier] so any page can read
/// from / listen to the same cart without a state-management package.
class CartStore extends ChangeNotifier {
  CartStore._();
  static final CartStore instance = CartStore._();

  final List<CartLine> _lines = [];
  List<CartLine> get lines => List.unmodifiable(_lines);

  bool get isEmpty => _lines.isEmpty;

  /// Total number of items (counting quantities), for the cart badge.
  int get itemCount => _lines.fold(0, (sum, l) => sum + l.quantity);

  void add(Map<String, dynamic> item) {
    final name = item['name'];
    final existing = _lines.indexWhere((l) => l.item['name'] == name);
    if (existing >= 0) {
      _lines[existing].quantity++;
    } else {
      _lines.add(CartLine(item, 1));
    }
    notifyListeners();
  }

  void decrement(CartLine line) {
    line.quantity--;
    if (line.quantity <= 0) _lines.remove(line);
    notifyListeners();
  }

  void removeLine(CartLine line) {
    _lines.remove(line);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }

  num _sum(String key) => _lines.fold<num>(0, (sum, l) {
        final v = l.item[key];
        return v is num ? sum + v * l.quantity : sum;
      });

  num get totalCalories => _sum('calories');
  num get totalProtein => _sum('protein_g');
  num get totalCarbs => _sum('carbs_g');
  num get totalFat => _sum('sat_fat_g');
}
