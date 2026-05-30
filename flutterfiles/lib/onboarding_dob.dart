import 'package:flutter/material.dart';
import 'onboarding_height_weight.dart';

class OnboardingDobPage extends StatefulWidget {
  final String sex;
  const OnboardingDobPage({super.key, required this.sex});

  @override
  State<OnboardingDobPage> createState() => _OnboardingDobPageState();
}

class _OnboardingDobPageState extends State<OnboardingDobPage> {
  int _selectedMonth = 0; // 0-indexed
  int _selectedDay = 0;
  int _selectedYearIndex = 7;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  final List<String> _years = List.generate(80, (i) => '${2010 - i}');

  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _dayCtrl;
  late FixedExtentScrollController _yearCtrl;

  @override
  void initState() {
    super.initState();
    _monthCtrl = FixedExtentScrollController(initialItem: _selectedMonth);
    _dayCtrl = FixedExtentScrollController(initialItem: _selectedDay);
    _yearCtrl = FixedExtentScrollController(initialItem: _selectedYearIndex);
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  DateTime get _selectedDate => DateTime(
        int.parse(_years[_selectedYearIndex]),
        _selectedMonth + 1,
        _selectedDay + 1,
      );

  Widget _buildDial({
    required FixedExtentScrollController controller,
    required List<String> items,
    required Function(int) onChanged,
    double width = 90,
  }) {
    return SizedBox(
      width: width,
      height: 220,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 48,
        perspective: 0.003,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildLoopingListDelegate(
          children: items
              .map((item) => Center(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(31, (i) => '${i + 1}');

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
                  value: 0.5,
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFFCC0000)),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'When were you born?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Used to calculate your calorie needs.',
                style: TextStyle(fontSize: 16, color: Colors.white60),
              ),
              const Spacer(),

              // Labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 90, child: Center(child: _label('Month'))),
                    SizedBox(width: 60, child: Center(child: _label('Day'))),
                    SizedBox(width: 80, child: Center(child: _label('Year'))),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Picker
              Container(
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Highlight
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC0000).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCC0000).withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDial(
                          controller: _monthCtrl,
                          items: _months,
                          width: 90,
                          onChanged: (i) => setState(
                              () => _selectedMonth = i % _months.length),
                        ),
                        _buildDial(
                          controller: _dayCtrl,
                          items: days,
                          width: 60,
                          onChanged: (i) =>
                              setState(() => _selectedDay = i % days.length),
                        ),
                        _buildDial(
                          controller: _yearCtrl,
                          items: _years,
                          width: 80,
                          onChanged: (i) => setState(
                              () => _selectedYearIndex = i % _years.length),
                        ),
                      ],
                    ),

                    // Top fade
                    Positioned(
                      top: 0, left: 0, right: 0, height: 90,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF2A2A2A),
                              const Color(0xFF2A2A2A).withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom fade
                    Positioned(
                      bottom: 0, left: 0, right: 0, height: 90,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24)),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              const Color(0xFF2A2A2A),
                              const Color(0xFF2A2A2A).withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OnboardingHeightWeightPage(
                          sex: widget.sex,
                          dob: _selectedDate,
                        ),
                      ),
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

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
      );
}