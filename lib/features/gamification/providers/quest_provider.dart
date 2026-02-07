import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/user_progress_provider.dart';

enum QuestStatus { pending, completed, claimed }
enum QuestType { navigation, manual }

class Quest {
  final String id;
  final String title;
  final int xp;
  final int points;
  final IconData icon;
  final QuestStatus status;
  final QuestType type;
  final String? actionId; // e.g., 'nav_hotspots'

  Quest({
    required this.id,
    required this.title,
    required this.xp,
    required this.points,
    required this.icon,
    this.status = QuestStatus.pending,
    this.type = QuestType.manual,
    this.actionId,
  });

  Quest copyWith({QuestStatus? status}) {
    return Quest(
      id: id,
      title: title,
      xp: xp,
      points: points,
      icon: icon,
      status: status ?? this.status,
      type: type,
      actionId: actionId,
    );
  }
}

class QuestNotifier extends Notifier<List<Quest>> {
  @override
  List<Quest> build() {
    return _generateDailyQuests();
  }

  List<Quest> _generateDailyQuests() {
    // Ideally this seed changes daily
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);

    final pool = [
      Quest(id: 'q1', title: "Check Hotspots", xp: 60, points: 50, icon: LucideIcons.mapPin, type: QuestType.navigation, actionId: 'nav_hotspots'),
      Quest(id: 'q2', title: "Talk to AI", xp: 70, points: 60, icon: LucideIcons.bot, type: QuestType.navigation, actionId: 'nav_ai'),
      Quest(id: 'q3', title: "Verify Vaccine", xp: 100, points: 80, icon: LucideIcons.syringe, type: QuestType.navigation, actionId: 'nav_vaccine'),
      Quest(id: 'q4', title: "Daily Check-In", xp: 50, points: 40, icon: LucideIcons.qrCode, type: QuestType.manual), 
      Quest(id: 'q5', title: "Read Health Tips", xp: 30, points: 30, icon: LucideIcons.bookOpen, type: QuestType.manual),
      Quest(id: 'q6', title: "Drink 2L Water", xp: 80, points: 70, icon: LucideIcons.glassWater, type: QuestType.manual),
      Quest(id: 'q7', title: "Walk 5000 Steps", xp: 120, points: 100, icon: LucideIcons.footprints, type: QuestType.manual),
      Quest(id: 'q8', title: "Update Profile", xp: 40, points: 40, icon: LucideIcons.user, type: QuestType.manual),
      Quest(id: 'q9', title: "Share App", xp: 90, points: 80, icon: LucideIcons.share2, type: QuestType.manual),
      Quest(id: 'q10', title: "Sleep 8 Hours", xp: 100, points: 90, icon: LucideIcons.moon, type: QuestType.manual),
      Quest(id: 'q11', title: "Avoid Sugar", xp: 60, points: 50, icon: LucideIcons.candyOff, type: QuestType.manual),
      Quest(id: 'q12', title: "Eat Fruit", xp: 50, points: 40, icon: LucideIcons.apple, type: QuestType.manual),
    ];

    final shuffled = List<Quest>.from(pool)..shuffle(random);
    return shuffled.take(3).toList();
  }

  void completeQuestByAction(String actionId) {
    state = [
      for (final quest in state)
        if (quest.actionId == actionId && quest.status == QuestStatus.pending)
          quest.copyWith(status: QuestStatus.completed)
        else
          quest
    ];
  }

  void markManualComplete(String questId) {
    state = [
      for (final quest in state)
        if (quest.id == questId && quest.status == QuestStatus.pending)
          quest.copyWith(status: QuestStatus.completed)
        else
          quest
    ];
  }

  void claimQuest(String questId, WidgetRef ref) {
    // Find quest
    final index = state.indexWhere((q) => q.id == questId);
    if (index == -1) return;
    
    final quest = state[index];
    if (quest.status == QuestStatus.completed) {
      // Award XP & Points
      ref.read(userProgressProvider.notifier).addXp(quest.xp / 1000.0);
      ref.read(userProgressProvider.notifier).addPoints(quest.points);
      
      // Mark claimed
      state = [
        for (final q in state)
          if (q.id == questId) q.copyWith(status: QuestStatus.claimed) else q
      ];
    }
  }
}

final questProvider = NotifierProvider<QuestNotifier, List<Quest>>(QuestNotifier.new);
