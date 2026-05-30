import 'package:flutter/material.dart';
import 'home_page.dart';

class OnboardingPlanPage extends StatelessWidget {
  final Map<String, int> goals;

  const OnboardingPlanPage({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Checkmark
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFCC0000),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),

              const Text(
                'Your Custom Plan',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Based on your inputs',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Daily recommendation card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your daily recommendation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('You can edit this anytime',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 13)),
                    const SizedBox(height: 20),

                    // Calories
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${goals['calories']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Calories',
                                  style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Macros row
                    Row(
                      children: [
                        Expanded(
                          child: _MacroCard(
                            emoji: '🥩',
                            value: '${goals['protein']}g',
                            label: 'Protein',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MacroCard(
                            emoji: '🌾',
                            value: '${goals['carbs']}g',
                            label: 'Carbs',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MacroCard(
                            emoji: '🫙',
                            value: '${goals['fat']}g',
                            label: 'Fats',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Let's get started!",
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _MacroCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}