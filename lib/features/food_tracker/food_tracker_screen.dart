import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:intl/intl.dart';

// --- DATA MODELS ---
enum DrinkType { water, tea, coffee, juice, milk }

class FoodEntry {
  final String name;
  final int calories;
  final DrinkType? type;
  FoodEntry(this.name, this.calories, {this.type});
}

class FoodTrackerState {
  final int calorieTarget;
  final List<String> allergies;
  final List<FoodEntry> foods;
  final List<FoodEntry> drinks;
  final Map<String, int> dailyHistory;
  final bool isScanning;

  FoodTrackerState({
    this.calorieTarget = 2000,
    this.allergies = const [],
    this.foods = const [],
    this.drinks = const [],
    this.dailyHistory = const {},
    this.isScanning = false,
  });

  int get totalCalories =>
      foods.fold(0, (a, b) => a + b.calories) +
          drinks.fold(0, (a, b) => a + b.calories);

  int get waterCount => drinks.where((d) => d.type == DrinkType.water).length;

  FoodTrackerState copyWith({
    int? calorieTarget,
    List<String>? allergies,
    List<FoodEntry>? foods,
    List<FoodEntry>? drinks,
    Map<String, int>? dailyHistory,
    bool? isScanning,
  }) {
    return FoodTrackerState(
      calorieTarget: calorieTarget ?? this.calorieTarget,
      allergies: allergies ?? this.allergies,
      foods: foods ?? this.foods,
      drinks: drinks ?? this.drinks,
      dailyHistory: dailyHistory ?? this.dailyHistory,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

// --- STATE MANAGEMENT ---
final foodTrackerProvider = StateNotifierProvider<FoodTrackerNotifier, FoodTrackerState>((ref) => FoodTrackerNotifier());

class FoodTrackerNotifier extends StateNotifier<FoodTrackerState> {
  FoodTrackerNotifier() : super(FoodTrackerState());

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  void setTarget(int target) => state = state.copyWith(calorieTarget: target);

  void toggleAllergy(String allergy) {
    final list = List<String>.from(state.allergies);
    list.contains(allergy) ? list.remove(allergy) : list.add(allergy);
    state = state.copyWith(allergies: list);
  }

  void reset() => state = FoodTrackerState();

  Future<String?> checkAllergyRisk(String name) async {
    state = state.copyWith(isScanning: true);
    await Future.delayed(1200.ms);
    final riskFound = state.allergies.any((allergy) => name.toLowerCase().contains(allergy.toLowerCase()));
    state = state.copyWith(isScanning: false);
    return riskFound ? "You have consumed an allergen giving food or drink" : null;
  }

  void _updateHistory() {
    final history = Map<String, int>.from(state.dailyHistory);
    history[_todayKey] = state.totalCalories;
    state = state.copyWith(dailyHistory: history);
  }

  void addFood(String name, int cal) {
    state = state.copyWith(foods: [...state.foods, FoodEntry(name, cal)]);
    _updateHistory();
  }

  void addDrink(String name, int cal, DrinkType type) {
    // Requirements logic: Water must be 0
    final validatedCal = (type == DrinkType.water) ? 0 : cal;
    state = state.copyWith(drinks: [...state.drinks, FoodEntry(name, validatedCal, type: type)]);
    _updateHistory();
  }
}

// --- MAIN UI ---
class FoodTrackerScreen extends ConsumerWidget {
  FoodTrackerScreen({super.key});

  final List<String> suggestions = [
    "🥗 Try a Balanced Lunch: Grilled chicken, brown rice, and steamed broccoli.",
    "💧 Reduce Sugar: Swap sugary sodas with plain water and a slice of lemon.",
    "🍎 Snack Smart: A handful of raw almonds and an apple provides sustained energy.",
    "🍵 Metabolism Boost: Switch your afternoon coffee for antioxidant-rich green tea.",
    "🥣 Fiber Focus: Add chia seeds or flaxseeds to your breakfast for better digestion."
  ];

  static const List<String> availableAllergens = ['Peanut', 'Milk & Dairy', 'Sesame', 'Wheat & Gluten', 'Shellfish', 'Fish', 'Chicken', 'Lamb', 'Beef', 'Soy', 'Egg', 'Tree Nuts'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foodTrackerProvider);
    final randomSuggestion = suggestions[Random().nextInt(suggestions.length)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("VITALITY TRACKER", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.amberAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [_buildConfigMenu(context, ref, state)],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(state),
                  const SizedBox(height: 20),
                  _buildCalorieChart(state),
                  const SizedBox(height: 25),
                  _sectionHeader("AI HEALTH INSIGHTS"),
                  const SizedBox(height: 10),
                  _buildDynamicInsights(state),
                  const SizedBox(height: 25),
                  _sectionHeader("HEALTHY SUGGESTIONS"),
                  const SizedBox(height: 10),
                  _buildSuggestionCard(randomSuggestion),
                  const SizedBox(height: 40),
                  _buildActionRow(context, ref),
                ],
              ),
            ),
            if (state.isScanning) _buildScanningOverlay(),
          ],
        ),
      ),
    );
  }

  // --- CONFIG & MODALS ---

  Widget _buildConfigMenu(BuildContext context, WidgetRef ref, FoodTrackerState state) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.settings, color: Colors.white70),
      color: const Color(0xFF161B1E),
      onSelected: (value) {
        if (value == 'target') _openTargetSheet(context, ref, state);
        if (value == 'allergy') _openAllergySheet(context, ref, state);
        if (value == 'reset') _showResetDialog(context, ref);
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'target', child: ListTile(leading: Icon(LucideIcons.target, color: Colors.cyanAccent), title: Text("Daily Goal", style: TextStyle(color: Colors.white)))),
        const PopupMenuItem(value: 'allergy', child: ListTile(leading: Icon(LucideIcons.shieldAlert, color: Colors.redAccent), title: Text("Allergies", style: TextStyle(color: Colors.white)))),
        const PopupMenuItem(value: 'reset', child: ListTile(leading: Icon(LucideIcons.refreshCcw, color: Colors.orangeAccent), title: Text("Reset Data", style: TextStyle(color: Colors.white)))),
      ],
    );
  }

  void _openTargetSheet(BuildContext context, WidgetRef ref, FoodTrackerState s) {
    final formKey = GlobalKey<FormState>();
    final c = TextEditingController(text: s.calorieTarget.toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B1E),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("SET DAILY TARGET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: c,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Calories (kcal)", labelStyle: TextStyle(color: Colors.white54)),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please set your daily calorie goal";
                  final n = int.tryParse(value);
                  if (n == null) return "Calories must be a number";
                  if (n < 800) return "Daily intake too low to be healthy";
                  if (n > 6000) return "Daily intake too high";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    ref.read(foodTrackerProvider.notifier).setTarget(int.parse(c.text));
                    Navigator.pop(context);
                  }
                },
                child: const Text("SAVE TARGET"),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _logEntry(BuildContext context, WidgetRef ref, bool isDrink) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    DrinkType drinkType = DrinkType.water;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161B1E),
      builder: (ctx) => StatefulBuilder(
        builder: (c, setST) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isDrink ? "LOG DRINK" : "LOG FOOD", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                if (isDrink) ...[
                  DropdownButton<DrinkType>(
                    dropdownColor: const Color(0xFF161B1E),
                    value: drinkType,
                    items: DrinkType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name, style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (v) => setST(() {
                      drinkType = v!;
                      if (drinkType == DrinkType.water) calCtrl.text = "0";
                    }),
                  ),
                ],
                TextFormField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(hintText: isDrink ? "Drink Name" : "Food Name", hintStyle: const TextStyle(color: Colors.white24)),
                  validator: (value) {
                    final trimmed = value?.trim() ?? "";
                    if (trimmed.isEmpty) return "Please enter a valid name";
                    if (trimmed.length < 2) return "Name too short";
                    if (RegExp(r'^[0-9]+$').hasMatch(trimmed)) return "Enter a valid name (not just numbers)";
                    return null;
                  },
                ),
                if (drinkType != DrinkType.water)
                  TextFormField(
                    controller: calCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: "Calories", hintStyle: TextStyle(color: Colors.white24)),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter calorie amount";
                      final n = int.tryParse(value);
                      if (n == null) return "Must be a whole number";
                      if (n <= 0) return "Calories must be greater than zero";
                      if (n > 2000) return "Unrealistic for a single item";
                      return null;
                    },
                  ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final name = nameCtrl.text.trim();
                      final cal = int.tryParse(calCtrl.text) ?? 0;
                      Navigator.pop(ctx);

                      final riskMessage = await ref.read(foodTrackerProvider.notifier).checkAllergyRisk(name);
                      if (riskMessage != null) {
                        _showAllergenWarning(context, riskMessage, () {
                          isDrink ? ref.read(foodTrackerProvider.notifier).addDrink(name, cal, drinkType) : ref.read(foodTrackerProvider.notifier).addFood(name, cal);
                        });
                      } else {
                        isDrink ? ref.read(foodTrackerProvider.notifier).addDrink(name, cal, drinkType) : ref.read(foodTrackerProvider.notifier).addFood(name, cal);
                      }
                    }
                  },
                  child: const Text("ANALYZE & ADD"),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- REUSABLE UI ---

  Widget _buildDynamicInsights(FoodTrackerState state) {
    List<Widget> messages = [];
    final calPercent = state.totalCalories / state.calorieTarget;

    if (calPercent > 1.0) {
      messages.add(_insightItem("Warning: Calorie target exceeded by ${(state.totalCalories - state.calorieTarget)} kcal.", Colors.redAccent, LucideIcons.frown));
    } else if (calPercent > 0.8) {
      messages.add(_insightItem("Approaching limit. Consider lighter snacks for later.", Colors.orangeAccent, LucideIcons.gauge));
    }

    if (state.waterCount < 3) {
      messages.add(_insightItem("Hydration Low: You've logged less than 3 glasses of water.", Colors.blueAccent, LucideIcons.droplets));
    } else {
      messages.add(_insightItem("Hydration Good: Keep maintaining this water intake!", Colors.greenAccent, LucideIcons.smile));
    }
    return Column(children: messages);
  }

  Widget _insightItem(String text, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)))]),
    ).animate().fadeIn().slideX();
  }

  Widget _buildSuggestionCard(String text) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Row(children: [const Icon(LucideIcons.lightbulb, color: Colors.amberAccent, size: 24), const SizedBox(width: 15), Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)))]),
    ).animate().shimmer(duration: 2.seconds);
  }

  Widget _buildProgressCard(FoodTrackerState state) {
    double progress = (state.totalCalories / state.calorieTarget).clamp(0.0, 1.0);
    return GlassContainer(
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Progress", style: TextStyle(color: Colors.white38, fontSize: 14)),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.white10, color: progress >= 1.0 ? Colors.redAccent : Colors.cyanAccent, minHeight: 8),
          const SizedBox(height: 15),
          Text("${state.totalCalories} / ${state.calorieTarget} kcal", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildCalorieChart(FoodTrackerState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return GlassContainer(
      borderRadius: BorderRadius.circular(25),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("7-Day Trend", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                maxY: (state.calorieTarget * 1.2).toDouble(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final date = today.subtract(Duration(days: 6 - val.toInt()));
                        return Text(DateFormat('E').format(date).substring(0, 1), style: const TextStyle(color: Colors.white38, fontSize: 11));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(today.subtract(Duration(days: 6 - index)));
                  final calories = state.dailyHistory[dateKey]?.toDouble() ?? 0.0;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: calories,
                        color: calories > state.calorieTarget ? Colors.redAccent : Colors.cyanAccent,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(show: true, toY: state.calorieTarget.toDouble(), color: Colors.white.withOpacity(0.05)),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, WidgetRef ref) {
    return Row(children: [
      _mainBtn("ADD FOOD", LucideIcons.utensils, Colors.orangeAccent, () => _logEntry(context, ref, false)),
      const SizedBox(width: 15),
      _mainBtn("ADD DRINK", LucideIcons.coffee, Colors.blueAccent, () => _logEntry(context, ref, true)),
    ]);
  }

  Widget _mainBtn(String l, IconData i, Color c, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(i, size: 18),
        label: Text(l, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        style: ElevatedButton.styleFrom(
            backgroundColor: c.withOpacity(0.1),
            foregroundColor: c,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: c.withOpacity(0.3)))),
      ),
    );
  }

  Widget _sectionHeader(String t) => Text(t, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2));

  void _openAllergySheet(BuildContext context, WidgetRef ref, FoodTrackerState s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setST) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("SELECT ALLERGENS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: availableAllergens.map((allergy) {
                  final isSelected = ref.watch(foodTrackerProvider).allergies.contains(allergy);
                  return GestureDetector(
                    onTap: () {
                      ref.read(foodTrackerProvider.notifier).toggleAllergy(allergy);
                      setST(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? Colors.redAccent : Colors.transparent),
                      ),
                      child: Text(allergy, style: TextStyle(color: isSelected ? Colors.redAccent : Colors.white70)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.pop(context), child: const Text("SAVE OPTIONS"))),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllergenWarning(BuildContext context, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A0A),
        title: const Icon(LucideIcons.alertCircle, color: Colors.redAccent),
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () { onConfirm(); Navigator.pop(ctx); }, child: const Text("PROCEED")),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B1E),
        title: const Text("Reset all data?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("NO")),
          TextButton(onPressed: () { ref.read(foodTrackerProvider.notifier).reset(); Navigator.pop(ctx); }, child: const Text("YES", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() => Container(color: Colors.black87, child: const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)));
}