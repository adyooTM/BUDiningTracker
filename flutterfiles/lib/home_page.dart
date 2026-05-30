import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'menu_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, dynamic>> diningHalls = const [
    {
      'id': 1,
      'name': 'Marciano Commons',
      'location': 'East Campus',
      'image': 'assets/images/marciano.jpg',
      'color': 0xFFCC0000,
    },
    {
      'id': 2,
      'name': 'Warren Towers',
      'location': 'Central Campus',
      'image': 'assets/images/warren.jpg',
      'color': 0xFF8B0000,
    },
    {
      'id': 3,
      'name': 'West Campus',
      'location': 'West Campus',
      'image': 'assets/images/west.jpg',
      'color': 0xFF8B0000,
    },
    {
      'id': 4,
      'name': 'Fenway Campus',
      'location': 'Fenway',
      'image': 'assets/images/fenway.jpg',
      'color': 0xFF6B0000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final username = user?.email?.split('@')[0] ?? 'Terrier';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          '🍽️ BU Dining',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'My Cart',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Profile banner
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ProfilePage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFCC0000),
                        ),
                        child: Center(
                          child: Text(
                            username.length >= 2
                                ? username.substring(0, 2).toUpperCase()
                                : username.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Track your progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white38, size: 14),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Where are you eating today?',
                style: TextStyle(fontSize: 15, color: Colors.white60),
              ),
              const SizedBox(height: 12),

              // Responsive 2x2 grid
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardHeight =
                        (constraints.maxHeight - 12) / 2;
                    final cardWidth =
                        (constraints.maxWidth - 12) / 2;
                    final aspectRatio = cardWidth / cardHeight;

                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: aspectRatio,
                      physics: const NeverScrollableScrollPhysics(),
                      children: diningHalls
                          .map((hall) => _DiningHallCard(
                                id: hall['id'],
                                name: hall['name'],
                                location: hall['location'],
                                image: hall['image'],
                                color: Color(hall['color']),
                              ))
                          .toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiningHallCard extends StatefulWidget {
  final int id;
  final String name;
  final String location;
  final String image;
  final Color color;

  const _DiningHallCard({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.color,
  });

  @override
  State<_DiningHallCard> createState() => _DiningHallCardState();
}

class _DiningHallCardState extends State<_DiningHallCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();

  void _onTapUp(_) {
    _controller.reverse();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => MenuPage(
          diningHallId: widget.id,
          diningHallName: widget.name,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                widget.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: widget.color,
                ),
              ),

              // Dark gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
                ),
              ),

              // Red tint
              Container(
                color: widget.color.withOpacity(0.25),
              ),

              // Text
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 11, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text(
                          widget.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}