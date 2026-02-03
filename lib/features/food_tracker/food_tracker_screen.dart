import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifierProvider, StateNotifier;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';

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
  final bool isScanning;

  FoodTrackerState({
    this.calorieTarget = 2500,
    this.allergies = const [],
    this.foods = const [],
    this.drinks = const [],
    this.isScanning = false,
  });

  int get totalCalories =>
      foods.fold(0, (a, b) => a + b.calories) +
          drinks.fold(0, (a, b) => a + b.calories);

  List<String> get aiInsights {
    List<String> insights = [];
    final caloriePercent = (totalCalories / calorieTarget);

    if (caloriePercent >= 0.9) insights.add("🔥 Limit Warning: ${(caloriePercent * 100).toInt()}% reached.");
    if (allergies.isNotEmpty) insights.add("🛡️ AI active: Monitoring ${allergies.length} allergens.");
    return insights;
  }

  FoodTrackerState copyWith({
    int? calorieTarget,
    List<String>? allergies,
    List<FoodEntry>? foods,
    List<FoodEntry>? drinks,
    bool? isScanning,
  }) {
    return FoodTrackerState(
      calorieTarget: calorieTarget ?? this.calorieTarget,
      allergies: allergies ?? this.allergies,
      foods: foods ?? this.foods,
      drinks: drinks ?? this.drinks,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

// --- STATE MANAGEMENT ---

final foodTrackerProvider = StateNotifierProvider<FoodTrackerNotifier, FoodTrackerState>((ref) => FoodTrackerNotifier());

class FoodTrackerNotifier extends StateNotifier<FoodTrackerState> {
  FoodTrackerNotifier() : super(FoodTrackerState());

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

    final riskFound = state.allergies.any((allergy) =>
        name.toLowerCase().contains(allergy.toLowerCase()));

    state = state.copyWith(isScanning: false);

    if (riskFound) {
      return "You have consumed an allergen giving food or drink";
    }
    return null;
  }

  void addFood(String name, int cal) => state = state.copyWith(foods: [...state.foods, FoodEntry(name, cal)]);
  void addDrink(String name, int cal, DrinkType type) => state = state.copyWith(drinks: [...state.drinks, FoodEntry(name, cal, type: type)]);
}

// --- MAIN UI ---

class FoodTrackerScreen extends ConsumerWidget {
  const FoodTrackerScreen({super.key});

  static const List<String> availableAllergens = ['Peanut', 'Milk & Dairy', 'Sesame', 'Wheat & Gluten', 'Shellfish', 'Fish', 'Chicken', 'Lamb', 'Beef', 'Soy', 'Egg', 'Tree Nuts'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foodTrackerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F12),
      appBar: AppBar(
        title: const Text("FOOD INTAKE MONITOR", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.amberAccent)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCcw, color: Colors.redAccent),
            onPressed: () => _showResetDialog(context, ref),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProgressCard(state),
                const SizedBox(height: 20),
                ...state.aiInsights.map((m) => _buildAIInsight(m)),
                const SizedBox(height: 30),
                _sectionHeader("Personalization"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSettingsTile("TARGET", "${state.calorieTarget}", LucideIcons.target, () => _openTargetSheet(context, ref, state)),
                    const SizedBox(width: 12),
                    _buildSettingsTile("ALLERGY", "${state.allergies.length}", LucideIcons.shieldAlert, () => _openAllergySheet(context, ref, state)),
                  ],
                ),
                const SizedBox(height: 40),
                _buildActionRow(context, ref),
              ],
            ),
          ),
          if (state.isScanning) _buildScanningOverlay(),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

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
              const Text("Today's Intake", style: TextStyle(color: Colors.white38, fontSize: 14)),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.white10, color: Colors.cyanAccent, minHeight: 8),
          const SizedBox(height: 15),
          Text("${state.totalCalories} / ${state.calorieTarget} kcal", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildAIInsight(String msg) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amberAccent.withOpacity(0.2))),
      child: Row(children: [const Icon(LucideIcons.sparkles, color: Colors.amberAccent, size: 16), const SizedBox(width: 12), Expanded(child: Text(msg, style: const TextStyle(color: Colors.white70, fontSize: 13)))]),
    );
  }

  Widget _buildSettingsTile(String t, String v, IconData i, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(i, color: Colors.cyanAccent, size: 20),
            const SizedBox(height: 10),
            Text(t, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _mainBtn("ADD FOOD", LucideIcons.utensils, Colors.orangeAccent, () => _logEntry(context, ref, false)),
        const SizedBox(width: 15),
        _mainBtn("ADD DRINK", LucideIcons.coffee, Colors.blueAccent, () => _logEntry(context, ref, true)),
      ],
    );
  }

  Widget _mainBtn(String l, IconData i, Color c, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(i, size: 18),
        label: Text(l, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        style: ElevatedButton.styleFrom(backgroundColor: c.withOpacity(0.1), foregroundColor: c, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: c.withOpacity(0.3)))),
      ),
    );
  }

  Widget _sectionHeader(String t) => Align(alignment: Alignment.centerLeft, child: Text(t, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)));

  // --- LOGIC & SHEETS ---

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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) const Icon(Icons.check, size: 16, color: Colors.redAccent),
                          if (isSelected) const SizedBox(width: 8),
                          Text(allergy, style: TextStyle(color: isSelected ? Colors.redAccent : Colors.white70)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("SAVE OPTIONS", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logEntry(BuildContext context, WidgetRef ref, bool isDrink) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    DrinkType drinkType = DrinkType.water;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161B1E),
      builder: (ctx) => StatefulBuilder(
        builder: (c, setST) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isDrink ? "ADD DRINK" : "ADD FOOD",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              if (isDrink)
                DropdownButton<DrinkType>(
                  dropdownColor: const Color(0xFF161B1E),
                  value: drinkType,
                  items: DrinkType.values
                      .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name,
                          style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (v) => setST(() => drinkType = v!),
                ),
              // Updated dynamic hint text below
              TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: isDrink ? "Drink Name" : "Food Name",
                      hintStyle: const TextStyle(color: Colors.white24))),
              TextField(
                  controller: calCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      hintText: "Calories",
                      hintStyle: TextStyle(color: Colors.white24))),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text;
                  final cal = int.tryParse(calCtrl.text) ?? 0;
                  Navigator.pop(ctx);

                  final riskMessage = await ref
                      .read(foodTrackerProvider.notifier)
                      .checkAllergyRisk(name);

                  if (riskMessage != null) {
                    _showAllergenWarning(context, riskMessage, isDrink, () {
                      isDrink
                          ? ref
                          .read(foodTrackerProvider.notifier)
                          .addDrink(name, cal, drinkType)
                          : ref
                          .read(foodTrackerProvider.notifier)
                          .addFood(name, cal);
                    });
                  } else {
                    isDrink
                        ? ref
                        .read(foodTrackerProvider.notifier)
                        .addDrink(name, cal, drinkType)
                        : ref
                        .read(foodTrackerProvider.notifier)
                        .addFood(name, cal);
                  }
                },
                child: const Text("ANALYZE & ADD"),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllergenWarning(BuildContext context, String message, bool isDrink, VoidCallback onConfirm) {
    final category = isDrink ? "drink" : "food";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A0A0A),
        title: const Icon(LucideIcons.alertCircle, color: Colors.redAccent),
        content: Text("$message ($category type)", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
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
        title: const Text("Reset Page?", style: TextStyle(color: Colors.white)),
        content: const Text("This will clear all intake logs and settings.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("NO")),
          TextButton(onPressed: () { ref.read(foodTrackerProvider.notifier).reset(); Navigator.pop(ctx); }, child: const Text("YES", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() => Container(color: Colors.black87, child: const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)));

  void _openTargetSheet(BuildContext context, WidgetRef ref, FoodTrackerState s) {
    final c = TextEditingController(text: s.calorieTarget.toString());
    showModalBottomSheet(context: context, backgroundColor: const Color(0xFF161B1E), builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: c, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white)), ElevatedButton(onPressed: () { ref.read(foodTrackerProvider.notifier).setTarget(int.parse(c.text)); Navigator.pop(context); }, child: const Text("SAVE"))])));
  }
}