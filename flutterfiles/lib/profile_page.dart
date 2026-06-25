import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'onboarding_sex.dart';
import 'progress_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profile;
  int _proteinConsumed = 0;
  int _carbsConsumed = 0;
  int _fatConsumed = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];

    final profile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    final logs = await Supabase.instance.client
        .from('meal_logs')
        .select('menu_items(calories, protein_g, carbs_g, sat_fat_g)')
        .eq('user_id', userId)
        .eq('date', today);

    int totalCals = 0;
    double totalProtein = 0, totalCarbs = 0, totalFat = 0;
    for (final log in logs) {
      final mi = log['menu_items'];
      if (mi == null) continue;
      totalCals += ((mi['calories'] ?? 0) as num).round();
      totalProtein += (mi['protein_g'] ?? 0) as num;
      totalCarbs += (mi['carbs_g'] ?? 0) as num;
      totalFat += (mi['sat_fat_g'] ?? 0) as num;
    }

    // Feed the shared calorie store so the bar stays in sync with checkout's
    // optimistic updates instead of keeping a separate local copy.
    ProgressStore.instance.setTotals(
      consumed: totalCals,
      goal: (profile?['daily_calorie_goal'] ?? 2000) as int,
    );

    setState(() {
      _profile = profile;
      _proteinConsumed = totalProtein.round();
      _carbsConsumed = totalCarbs.round();
      _fatConsumed = totalFat.round();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final username = user?.email?.split('@')[0] ?? 'Terrier';
    final initials = username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();

    final proteinGoal = _profile?['daily_protein_goal'] ?? 150;
    final carbsGoal = _profile?['daily_carbs_goal'] ?? 250;
    final fatGoal = _profile?['daily_fat_goal'] ?? 65;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const OnboardingSexPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFCC0000)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar + name
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFCC0000),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Calories card — driven by the shared ProgressStore so a
                  // checkout updates these numbers live.
                  AnimatedBuilder(
                    animation: ProgressStore.instance,
                    builder: (context, _) {
                      final store = ProgressStore.instance;
                      final calorieGoal = store.calorieGoal;
                      final caloriesConsumed = store.caloriesConsumed;
                      final caloriesLeft =
                          store.caloriesLeft.clamp(0, calorieGoal);
                      final progress = store.progress;

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Progress",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Text('🔥',
                                    style: TextStyle(fontSize: 32)),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$caloriesLeft',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text('Calories left',
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 13)),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '$caloriesConsumed',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' / $calorieGoal',
                                            style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Text('consumed / goal',
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation(
                                  calorieProgressColor(progress),
                                ),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Macros row
                  Row(
                    children: [
                      Expanded(
                        child: _MacroCard(
                          emoji: '🥩',
                          label: 'Protein',
                          consumed: _proteinConsumed,
                          goal: proteinGoal,
                          unit: 'g',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MacroCard(
                          emoji: '🌾',
                          label: 'Carbs',
                          consumed: _carbsConsumed,
                          goal: carbsGoal,
                          unit: 'g',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MacroCard(
                          emoji: '🫙',
                          label: 'Fats',
                          consumed: _fatConsumed,
                          goal: fatGoal,
                          unit: 'g',
                          color: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Profile info card
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
                          'Your Info',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'Sex',
                          value: _profile?['sex'] ?? '--',
                        ),
                        _InfoRow(
                          icon: Icons.cake_outlined,
                          label: 'Date of Birth',
                          value: _profile?['date_of_birth'] ?? '--',
                        ),
                        _InfoRow(
                          icon: Icons.height,
                          label: 'Height',
                          value: _profile?['height_cm'] != null
                              ? '${_profile!['height_cm'].toStringAsFixed(1)} cm'
                              : '--',
                        ),
                        _InfoRow(
                          icon: Icons.monitor_weight_outlined,
                          label: 'Weight',
                          value: _profile?['weight_kg'] != null
                              ? '${_profile!['weight_kg'].toStringAsFixed(1)} kg'
                              : '--',
                        ),
                        _InfoRow(
                          icon: Icons.directions_run,
                          label: 'Activity Level',
                          value: _profile?['activity_level'] ?? '--',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int consumed;
  final int goal;
  final String unit;
  final Color color;

  const _MacroCard({
    required this.emoji,
    required this.label,
    required this.consumed,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        goal == 0 ? 0.0 : (consumed / goal).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            '$consumed$unit',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('of $goal$unit',
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.white54, size: 20),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 14)),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(color: Colors.white10, height: 1),
      ],
    );
  }
}