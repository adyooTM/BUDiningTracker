import 'package:flutter/material.dart';
import 'onboarding_activity.dart';

class OnboardingHeightWeightPage extends StatefulWidget {
  final String sex;
  final DateTime dob;

  const OnboardingHeightWeightPage({
    super.key,
    required this.sex,
    required this.dob,
  });

  @override
  State<OnboardingHeightWeightPage> createState() =>
      _OnboardingHeightWeightPageState();
}

class _OnboardingHeightWeightPageState
    extends State<OnboardingHeightWeightPage> {
  bool _isMetric = false;

  // Imperial
  int _feetIndex = 2; // 5ft
  int _inchesIndex = 6; // 6in
  int _lbsIndex = 70; // 150lb

  // Metric
  int _cmIndex = 40; // 170cm
  int _kgIndex = 40; // 70kg

  final List<String> _feetItems = List.generate(6, (i) => '${i + 3} ft');
  final List<String> _inchItems = List.generate(12, (i) => '$i in');
  final List<String> _lbItems = List.generate(351, (i) => '${i + 80} lb');
  final List<String> _cmItems = List.generate(121, (i) => '${i + 130} cm');
  final List<String> _kgItems = List.generate(171, (i) => '${i + 30} kg');

  late FixedExtentScrollController _feetCtrl;
  late FixedExtentScrollController _inchCtrl;
  late FixedExtentScrollController _lbCtrl;
  late FixedExtentScrollController _cmCtrl;
  late FixedExtentScrollController _kgCtrl;

  @override
  void initState() {
    super.initState();
    _feetCtrl = FixedExtentScrollController(initialItem: _feetIndex);
    _inchCtrl = FixedExtentScrollController(initialItem: _inchesIndex);
    _lbCtrl = FixedExtentScrollController(initialItem: _lbsIndex);
    _cmCtrl = FixedExtentScrollController(initialItem: _cmIndex);
    _kgCtrl = FixedExtentScrollController(initialItem: _kgIndex);
  }

  @override
  void dispose() {
    _feetCtrl.dispose();
    _inchCtrl.dispose();
    _lbCtrl.dispose();
    _cmCtrl.dispose();
    _kgCtrl.dispose();
    super.dispose();
  }

  double get heightCm => _isMetric
      ? (_cmIndex + 130).toDouble()
      : ((_feetIndex + 3) * 30.48) + (_inchesIndex * 2.54);

  double get weightKg => _isMetric
      ? (_kgIndex + 30).toDouble()
      : (_lbsIndex + 80) * 0.453592;

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

  Widget _buildContainer(List<Widget> dials) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
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
            children: dials,
          ),
          Positioned(
            top: 0, left: 0, right: 0, height: 90,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
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
          Positioned(
            bottom: 0, left: 0, right: 0, height: 90,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
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
    );
  }

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
                  value: 0.75,
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFFCC0000)),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Height & Weight',
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
              const SizedBox(height: 24),

              // Toggle
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ToggleBtn(
                        label: 'Imperial',
                        selected: !_isMetric,
                        onTap: () => setState(() => _isMetric = false),
                      ),
                      _ToggleBtn(
                        label: 'Metric',
                        selected: _isMetric,
                        onTap: () => setState(() => _isMetric = true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _isMetric
                    ? [
                        SizedBox(width: 110, child: Center(child: _label('Height'))),
                        SizedBox(width: 110, child: Center(child: _label('Weight'))),
                      ]
                    : [
                        SizedBox(width: 85, child: Center(child: _label('Feet'))),
                        SizedBox(width: 75, child: Center(child: _label('Inches'))),
                        SizedBox(width: 95, child: Center(child: _label('Weight'))),
                      ],
              ),
              const SizedBox(height: 8),

              // Pickers
              _isMetric
                  ? _buildContainer([
                      _buildDial(
                        controller: _cmCtrl,
                        items: _cmItems,
                        width: 110,
                        onChanged: (i) =>
                            setState(() => _cmIndex = i % _cmItems.length),
                      ),
                      _buildDial(
                        controller: _kgCtrl,
                        items: _kgItems,
                        width: 110,
                        onChanged: (i) =>
                            setState(() => _kgIndex = i % _kgItems.length),
                      ),
                    ])
                  : _buildContainer([
                      _buildDial(
                        controller: _feetCtrl,
                        items: _feetItems,
                        width: 85,
                        onChanged: (i) =>
                            setState(() => _feetIndex = i % _feetItems.length),
                      ),
                      _buildDial(
                        controller: _inchCtrl,
                        items: _inchItems,
                        width: 75,
                        onChanged: (i) =>
                            setState(() => _inchesIndex = i % _inchItems.length),
                      ),
                      _buildDial(
                        controller: _lbCtrl,
                        items: _lbItems,
                        width: 95,
                        onChanged: (i) =>
                            setState(() => _lbsIndex = i % _lbItems.length),
                      ),
                    ]),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OnboardingActivityPage(
                          sex: widget.sex,
                          dob: widget.dob,
                          heightCm: heightCm,
                          weightKg: weightKg,
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

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleBtn({
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFCC0000) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}