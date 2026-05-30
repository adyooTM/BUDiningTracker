import 'package:flutter/material.dart';
import 'onboarding_calculating.dart';

class OnboardingActivityPage extends StatefulWidget {
  final String sex;
  final DateTime dob;
  final double heightCm;
  final double weightKg;

  const OnboardingActivityPage({
    super.key,
    required this.sex,
    required this.dob,
    required this.heightCm,
    required this.weightKg,
  });

  @override
  State<OnboardingActivityPage> createState() =>
      _OnboardingActivityPageState();
}

class _OnboardingActivityPageState extends State<OnboardingActivityPage> {
  String? _selected;

  final List<Map<String, String>> _options = [
    {
      'value': 'sedentary',
      'label': 'Sedentary',
      'desc': 'Little or no exercise',
      'emoji': '🛋️',
    },
    {
      'value': 'light',
      'label': 'Lightly Active',
      'desc': 'Light exercise 1–3 days/week',
      'emoji': '🚶',
    },
    {
      'value': 'moderate',
      'label': 'Moderately Active',
      'desc': 'Moderate exercise 3–5 days/week',
      'emoji': '🏃',
    },
    {
      'value': 'very',
      'label': 'Very Active',
      'desc': 'Hard exercise 6–7 days/week',
      'emoji': '⚡',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.9,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFCC0000)),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                'Activity Level',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'How active are you on a typical day?',
                style: TextStyle(fontSize: 16, color: Colors.white60),
              ),

              const Spacer(),

              ..._options.map((option) {
                final isSelected = _selected == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selected = option['value']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFCC0000)
                            : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFCC0000)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(option['emoji']!,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['label']!,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                option['desc']!,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.white38,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OnboardingCalculatingPage(
                                sex: widget.sex,
                                dob: widget.dob,
                                heightCm: widget.heightCm,
                                weightKg: widget.weightKg,
                                activityLevel: _selected!,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC0000),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}