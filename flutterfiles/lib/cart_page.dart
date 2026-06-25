import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_store.dart';
import 'progress_store.dart';

/// Shopping-cart icon with a live item-count badge. Reused on the home page
/// and on every dining-hall page so the cart is always one tap away.
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartStore.instance,
      builder: (context, _) {
        final count = CartStore.instance.itemCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'My Cart',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFCC0000),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _checkout(BuildContext context) async {
    final cart = CartStore.instance;
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null || cart.isEmpty) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final caloriesAdded = cart.totalCalories.round();

    // One meal_logs row per item per quantity.
    final rows = <Map<String, dynamic>>[];
    for (final line in cart.lines) {
      for (var i = 0; i < line.quantity; i++) {
        rows.add({
          'user_id': userId,
          'menu_item_id': line.item['id'],
          'date': today,
        });
      }
    }

    try {
      await client.from('meal_logs').insert(rows);
      ProgressStore.instance.addLocally(caloriesAdded);
      cart.clear();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged $caloriesAdded cal to your daily progress'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF43A047),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkout failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFE53935),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartStore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('My Cart',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          AnimatedBuilder(
            animation: cart,
            builder: (context, _) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: cart.clear,
                child: const Text('Clear',
                    style: TextStyle(color: Colors.white70)),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: cart,
        builder: (context, _) {
          if (cart.isEmpty) {
            return _buildEmpty();
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.lines.length,
                  itemBuilder: (context, index) {
                    final line = cart.lines[index];
                    return _CartLineCard(line: line);
                  },
                ),
              ),
              _TotalsBar(cart: cart, onCheckout: () => _checkout(context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('🛒', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add items from a dining hall to see\nthem here with nutrition totals',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  final CartLine line;
  const _CartLineCard({required this.line});

  @override
  Widget build(BuildContext context) {
    final cart = CartStore.instance;
    final item = line.item;
    final calories = item['calories'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (calories != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$calories cal each',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          // Quantity stepper
          _RoundIconButton(
            icon: Icons.remove,
            onTap: () => cart.decrement(line),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${line.quantity}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _RoundIconButton(
            icon: Icons.add,
            onTap: () => cart.add(item),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFCC0000),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _TotalsBar extends StatelessWidget {
  final CartStore cart;
  final VoidCallback onCheckout;
  const _TotalsBar({required this.cart, required this.onCheckout});

  String _fmt(num v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Calories',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14)),
              Text(
                '${_fmt(cart.totalCalories)} cal',
                style: const TextStyle(
                  color: Color(0xFFCC0000),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _macro('Protein', '${_fmt(cart.totalProtein)}g', Colors.blue),
              _macro('Carbs', '${_fmt(cart.totalCarbs)}g', Colors.orange),
              _macro('Sat. Fat', '${_fmt(cart.totalFat)}g', Colors.red),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC0000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Checkout & Log',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _macro(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
