import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

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

  // AI Insight Logic (Shared)
  String get currentInsight {
    final calPercent = totalCalories / calorieTarget;
    if (calPercent > 1.0) return "Warning: Calorie target exceeded!";
    if (calPercent > 0.8) return "Approaching daily limit.";
    if (waterCount < 3) return "Hydration Low: Drink more water.";
    return "You are on track today!";
  }

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

  Future<Map<String, dynamic>?> analyzeFoodImage(XFile image) async {
    state = state.copyWith(isScanning: true);
    
    try {
      debugPrint("Starting AI Scan...");
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      debugPrint("Image encoded: ${base64Image.length} bytes");
      
      String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        // Fallback for dev/web if .env fails
        debugPrint("Warning: .env key missing, using fallback.");
        apiKey = "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"; 
      }

      debugPrint("Sending request to Groq...");
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.2-11b-vision-preview",
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": "Analyze this food image. Identify the food item and estimate calories. Return ONLY valid JSON: {\"food_name\": \"string\", \"calories\": int, \"description\": \"string\"}. Do not include markdown formatting or explanations."},
                {"type": "image_url", "image_url": {"url": "data:image/jpeg;base64,$base64Image"}}
              ]
            }
          ],
          "max_tokens": 300,
          "temperature": 0.1,
          "response_format": {"type": "json_object"}
        }),
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].toString();
        return jsonDecode(content) as Map<String, dynamic>;
      } else {
        throw Exception("AI Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("AI Scan Exception: $e");
      return null;
    } finally {
      state = state.copyWith(isScanning: false);
    }
  }

  Future<Map<String, dynamic>?> analyzeFoodText(String text) async {
    state = state.copyWith(isScanning: true);
    
    try {
      String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
         debugPrint("Warning: .env key missing in Text Analysis, using fallback.");
         apiKey = "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";
      }

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "You are a nutritionist AI. Analyze the food description. Return ONLY valid JSON: {\"food_name\": \"string\", \"calories\": int, \"description\": \"string\"}. Estimate calories conservatively."
            },
            {
              "role": "user",
              "content": text
            }
          ],
          "max_tokens": 300,
          "temperature": 0.1,
          "response_format": {"type": "json_object"}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].toString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("AI Text Error: $e");
      return null;
    } finally {
      state = state.copyWith(isScanning: false);
    }
  }
}
