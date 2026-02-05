import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProgress {
  final int level;
  final double xp;
  final List<String> unlockedThemes;
  final List<String> unlockedFrames;

  UserProgress({
    required this.level,
    required this.xp,
    required this.unlockedThemes,
    required this.unlockedFrames,
  });

  UserProgress copyWith({
    int? level,
    double? xp,
    List<String>? unlockedThemes,
    List<String>? unlockedFrames,
  }) {
    return UserProgress(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      unlockedFrames: unlockedFrames ?? this.unlockedFrames,
    );
  }
  
  static UserProgress initial() {
    return UserProgress(
      level: 5, // Start at 5 as per existing mockup
      xp: 0.3,
      unlockedThemes: ['default'],
      unlockedFrames: ['default'],
    );
  }
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
  
  // Debug method to force level up for testing
  void cheatLevelUp() {
    addXp(1.0);
  }
}

final userProgressProvider = NotifierProvider<UserProgressNotifier, UserProgress>(UserProgressNotifier.new);
