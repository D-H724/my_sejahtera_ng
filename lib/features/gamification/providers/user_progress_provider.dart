import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProgress {
  final int level;
  final double xp;
  final List<String> unlockedThemes;
  final List<String> unlockedFrames;
  
  // Daily Quest State
  final bool hasCheckedIn;
  final bool hasTakenMeds;
  final bool hasLoggedMood;
  final int currentStreak;
  final bool hasDailyFlame;
  final DateTime? lastCheckInDate;

  UserProgress({
    required this.level,
    required this.xp,
    required this.unlockedThemes,
    required this.unlockedFrames,
    this.hasCheckedIn = false,
    this.hasTakenMeds = false,
    this.hasLoggedMood = false,
    this.currentStreak = 0,
    this.hasDailyFlame = false,
    this.lastCheckInDate,
  });

  UserProgress copyWith({
    int? level,
    double? xp,
    List<String>? unlockedThemes,
    List<String>? unlockedFrames,
    bool? hasCheckedIn,
    bool? hasTakenMeds,
    bool? hasLoggedMood,
    int? currentStreak,
    bool? hasDailyFlame,
    DateTime? lastCheckInDate,
  }) {
    return UserProgress(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      unlockedFrames: unlockedFrames ?? this.unlockedFrames,
      hasCheckedIn: hasCheckedIn ?? this.hasCheckedIn,
      hasTakenMeds: hasTakenMeds ?? this.hasTakenMeds,
      hasLoggedMood: hasLoggedMood ?? this.hasLoggedMood,
      currentStreak: currentStreak ?? this.currentStreak,
      hasDailyFlame: hasDailyFlame ?? this.hasDailyFlame,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
    );
  }
  
  static UserProgress initial() {
    return UserProgress(
      level: 5,
      xp: 0.3,
      unlockedThemes: ['default'],
      unlockedFrames: ['default'],
      currentStreak: 3, // Mock initial streak for engagement
    );
  }

  bool get isDailyQuestComplete => hasCheckedIn && hasTakenMeds && hasLoggedMood;
}

class UserProgressNotifier extends Notifier<UserProgress> {
  @override
  UserProgress build() {
    return UserProgress.initial();
  }

  void addXp(double amount) {
    double newXp = state.xp + amount;
    int newLevel = state.level;
    
    // Simple level up logic: 1.0 XP required per level
    if (newXp >= 1.0) {
      newXp = newXp - 1.0;
      newLevel++;
      _checkUnlocks(newLevel);
    }
    
    state = state.copyWith(level: newLevel, xp: newXp);
  }

  void _checkUnlocks(int level) {
    final List<String> newThemes = List.from(state.unlockedThemes);
    final List<String> newFrames = List.from(state.unlockedFrames);
    
    if (level >= 10 && !newThemes.contains('cyberpunk')) {
      newThemes.add('cyberpunk');
    }
    if (level >= 10 && !newThemes.contains('nature')) {
      newThemes.add('nature');
    }
    if (level >= 15 && !newThemes.contains('sunset')) {
      newThemes.add('sunset');
    }
    if (level >= 20 && !newThemes.contains('ocean')) {
      newThemes.add('ocean');
    }
    
    if (level >= 15 && !newFrames.contains('neon_glow')) {
      newFrames.add('neon_glow');
    }
    
    state = state.copyWith(unlockedThemes: newThemes, unlockedFrames: newFrames);
  }
  
  // Daily Quest Logic
  void completeQuest(String questType) {
    bool updated = false;
    UserProgress newState = state;

    // Check if we need to reset for a new day (mock logic for now, ideally strictly date-based)
    // For now, we assume simple state updates. In a real app, check DateTime.now().difference(lastDate).inDays > 0

    if (questType == 'checkIn' && !state.hasCheckedIn) {
      newState = newState.copyWith(hasCheckedIn: true, lastCheckInDate: DateTime.now());
      updated = true;
    } else if (questType == 'meds' && !state.hasTakenMeds) {
      newState = newState.copyWith(hasTakenMeds: true);
      updated = true;
    } else if (questType == 'mood' && !state.hasLoggedMood) {
      newState = newState.copyWith(hasLoggedMood: true);
      updated = true;
    }

    if (updated) {
      // Award small XP for each step
      addXp(0.05);

      // Check if all complete
      if (newState.hasCheckedIn && newState.hasTakenMeds && newState.hasLoggedMood && !state.hasDailyFlame) {
        // Complete Daily Quest!
        newState = newState.copyWith(
          hasDailyFlame: true,
          currentStreak: state.currentStreak + 1,
        );
        // Bonus XP
        addXp(0.2); 
      }
      state = newState;
    }
  }

  // Debug method to force level up for testing
  void cheatLevelUp() {
    addXp(1.0);
  }
  
  // Debug method to reset daily quests
  void debugResetDaily() {
    state = state.copyWith(
      hasCheckedIn: false,
      hasTakenMeds: false,
      hasLoggedMood: false,
      hasDailyFlame: false,
    );
  }
}

final userProgressProvider = NotifierProvider<UserProgressNotifier, UserProgress>(UserProgressNotifier.new);
