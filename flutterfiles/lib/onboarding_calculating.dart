import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'onboarding_plan.dart';

class OnboardingCalculatingPage extends StatefulWidget {
  final String sex;
  final DateTime dob;
  final double heightCm;
  final double weightKg;
  final String activityLevel;

  const OnboardingCalculatingPage({
    super.key,
    required this.sex,
    required this.dob,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
  });

  @override
  State<OnboardingCalculatingPage> createState() =>
      _OnboardingCalculatingPageState();
}

class _OnboardingCalculatingPageState
    extends State<OnboardingCalculatingPage> {
  double _progress = 0;
  int _stepIndex = 0;
  late Map<String, int> _goals;

  final List<String> _steps = [
    'Calculating your BMR...',
    'Estimating your metabolic age...',
    'Setting protein goals...',
    'Setting carb goals...',
    'Finalizing your plan...',
  ];

  @override
  void initState() {
    super.initState();
    _calculate();
    _animate();
  }

  void _animate() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() {
        _progress = i / 100;
        _stepIndex = (i / 100 * (_steps.length - 1)).floor();
      });
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OnboardingPlanPage(goals: _goals),
      ),
    );
  }

  void _calculate() {
    final age = DateTime.now().year - widget.dob.year;

    // Harris-Benedict BMR
    double bmr;
    if (widget.sex == 'male') {
      bmr = 88.36 +
          (13.4 * widget.weightKg) +
          (4.8 * widget.heightCm) -
          (5.7 * age);
    } else {
      bmr = 447.6 +
          (9.2 * widget.weightKg) +
          (3.1 * widget.heightCm) -
          (4.3 * age);
    }

    // Activity multiplier
    final multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'very': 1.725,
    };
    final tdee = bmr * (multipliers[widget.activityLevel] ?? 1.2);

    // Macro split: 30% protein, 45% carbs, 25% fat
    final calories = tdee.round();
    final protein = ((tdee * 0.30) / 4).round();
    final carbs = ((tdee * 0.45) / 4).round();
    final fat = ((tdee * 0.25) / 9).round();

    _goals = {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };

    // Save to Supabase
    _saveToSupabase();
  }

  Future<void> _saveToSupabase() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client.from('profiles').upsert({
      'id': userId,
      'sex': widget.sex,
      'date_of_birth': widget.dob.toIso8601String().split('T')[0],
      'height_cm': widget.heightCm,
      'weight_kg': widget.weightKg,
      'activity_level': widget.activityLevel,
      'daily_calorie_goal': _goals['calories'],
      'daily_protein_goal': _goals['protein'],
      'daily_carbs_goal': _goals['carbs'],
      'daily_fat_goal': _goals['fat'],
      'onboarding_complete': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              Text(
                '${(_progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "We're setting everything up for you",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFCC0000)),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _steps[_stepIndex],
                style:
                    const TextStyle(color: Colors.white60, fontSize: 14),
              ),

              const SizedBox(height: 40),

              // Checklist
              ...[
                'Calories',
                'Protein',
                'Carbs',
                'Fats',
              ].asMap().entries.map((entry) {
                final done = _progress > (entry.key + 1) * 0.2;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? const Color(0xFFCC0000)
                              : Colors.white12,
                        ),
                        child: done
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Daily ${entry.value} recommendation',
                        style: TextStyle(
                          color: done ? Colors.white : Colors.white38,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}