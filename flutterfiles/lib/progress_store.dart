import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tracks the user's daily calorie progress (consumed vs. goal).
///
/// Source of truth is the `meal_logs` table, but [addLocally] lets us bump
/// the count instantly on checkout so the UI updates without a round-trip.
class ProgressStore extends ChangeNotifier {
  ProgressStore._();
  static final ProgressStore instance = ProgressStore._();

  int caloriesConsumed = 0;
  int calorieGoal = 2000;
  bool loaded = false;

  Future<void> load() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];

    final profile = await client
        .from('profiles')
        .select('daily_calorie_goal')
        .eq('id', userId)
        .maybeSingle();

    final logs = await client
        .from('meal_logs')
        .select('menu_items(calories)')
        .eq('user_id', userId)
        .eq('date', today);

    int total = 0;
    for (final log in logs) {
      total += (log['menu_items']?['calories'] ?? 0) as int;
    }

    caloriesConsumed = total;
    calorieGoal = (profile?['daily_calorie_goal'] ?? 2000) as int;
    loaded = true;
    notifyListeners();
  }

  /// Replace the current totals from a fresh fetch (e.g. when a screen that
  /// already queried `meal_logs`/`profiles` wants to feed this store rather
  /// than triggering a second round-trip via [load]).
  void setTotals({required int consumed, required int goal}) {
    caloriesConsumed = consumed;
    calorieGoal = goal;
    loaded = true;
    notifyListeners();
  }

  /// Optimistically add calories (e.g. right after checkout).
  void addLocally(int calories) {
    caloriesConsumed += calories;
    notifyListeners();
  }

  /// 0.0–1.0 fraction of the goal consumed, clamped for the bar width.
  double get progress =>
      calorieGoal == 0 ? 0 : (caloriesConsumed / calorieGoal).clamp(0.0, 1.0);

  /// Calories remaining (can go negative if the goal is overshot).
  int get caloriesLeft => calorieGoal - caloriesConsumed;
}

/// Shared color logic for the calorie bar so every screen matches:
///   • yellow  — plenty of calories still left (under ~70% of goal)
///   • green   — in the "just right" zone (~70%–95%)
///   • red     — almost at the goal or overshooting (>= ~95%)
Color calorieProgressColor(double progress) {
  if (progress >= 0.95) return const Color(0xFFE53935); // red
  if (progress >= 0.70) return const Color(0xFF43A047); // green
  return const Color(0xFFFBC02D); // yellow
}
