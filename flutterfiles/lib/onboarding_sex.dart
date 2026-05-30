import 'package:flutter/material.dart';
import 'onboarding_dob.dart';

class OnboardingSexPage extends StatefulWidget {
  const OnboardingSexPage({super.key});

  @override
  State<OnboardingSexPage> createState() => _OnboardingSexPageState();
}

class _OnboardingSexPageState extends State<OnboardingSexPage> {
  String? _selected;

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
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.25,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFCC0000)),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                'Choose your sex',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This helps personalize your calorie goal.',
                style: TextStyle(fontSize: 16, color: Colors.white60),
              ),

              const Spacer(),

              // Options
              _Option(
                label: 'Male',
                selected: _selected == 'male',
                onTap: () => setState(() => _selected = 'male'),
              ),
              const SizedBox(height: 12),
              _Option(
                label: 'Female',
                selected: _selected == 'female',
                onTap: () => setState(() => _selected = 'female'),
              ),
              const SizedBox(height: 12),
              _Option(
                label: 'Other',
                selected: _selected == 'other',
                onTap: () => setState(() => _selected = 'other'),
              ),

              const Spacer(),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  OnboardingDobPage(sex: _selected!),
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
                  child: const Text(
                    'Continue',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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

class _Option extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFCC0000) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFCC0000) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}