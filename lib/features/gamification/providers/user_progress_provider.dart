import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sejahtera_ng/features/gamification/models/voucher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_sejahtera_ng/core/services/supabase_service.dart';

class UserProgress {
  final int level;
  final double xp;
  final int points;
  final List<String> redeemedVoucherIds;
  
  // Daily Quest State
  final bool hasCheckedIn;
  final bool hasTakenMeds;
  final bool hasLoggedMood;

  UserProgress({
    required this.level,
    required this.xp,
    required this.points,
    required this.redeemedVoucherIds,
    this.hasCheckedIn = false,
    this.hasTakenMeds = false,
    this.hasLoggedMood = false,
  });

  UserProgress copyWith({
    int? level,
    double? xp,
    int? points,
    List<String>? redeemedVoucherIds,
    bool? hasCheckedIn,
    bool? hasTakenMeds,
    bool? hasLoggedMood,
  }) {
    return UserProgress(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      points: points ?? this.points,
      redeemedVoucherIds: redeemedVoucherIds ?? this.redeemedVoucherIds,
      hasCheckedIn: hasCheckedIn ?? this.hasCheckedIn,
      hasTakenMeds: hasTakenMeds ?? this.hasTakenMeds,
      hasLoggedMood: hasLoggedMood ?? this.hasLoggedMood,
    );
  }
  
  static UserProgress initial() {
    return UserProgress(
      level: 1,
      xp: 0.0,
      points: 0,
      redeemedVoucherIds: [],
    );
  }

  bool get isDailyQuestComplete => hasCheckedIn && hasTakenMeds && hasLoggedMood;
}

class UserProgressNotifier extends Notifier<UserProgress> {
  late final SupabaseClient _supabase;

  // Static Store Inventory (Same as before)
  static const List<Voucher> shopInventory = [
    Voucher(id: 'shopee_rm5', title: 'Shopee', description: 'RM5 Off Shipping', discountCode: 'SHOPEEMYSJ', expiryDate: '31 Dec 2026', cost: 300, brandColor: Colors.orange),
    Voucher(id: 'tealive_10', title: 'Tealive', description: '10% Off Bill', discountCode: 'MYSJTEA10', expiryDate: '31 Dec 2026', cost: 500, brandColor: Colors.purple),
    Voucher(id: 'grab_5', title: 'GrabFood', description: 'RM5 Off Delivery', discountCode: 'GRABMYSJ5', expiryDate: '30 Nov 2026', cost: 800, brandColor: Colors.green),
    Voucher(id: 'kfc_snack', title: 'KFC', description: 'Free Cheesy Wedges', discountCode: 'KFCMYSJ', expiryDate: '30 Nov 2026', cost: 1000, brandColor: Colors.redAccent),
    Voucher(id: 'watsons_20', title: 'Watsons', description: 'RM20 Off Health', discountCode: 'WATSONS20', expiryDate: '15 Oct 2026', cost: 1500, brandColor: Colors.teal),
    Voucher(id: 'golds_gym', title: 'Gold\'s Gym', description: '1 Week Free Pass', discountCode: 'GOLDSFREE', expiryDate: '31 Dec 2026', cost: 2500, brandColor: Colors.amber),
  ];

  @override
  UserProgress build() {
    _supabase = SupabaseService().client;
    _loadProgress();
    return UserProgress.initial();
  }

  Future<void> _loadProgress() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase.from('user_progress').select().eq('user_id', user.id).single();
      
      final dailyQuests = response['daily_quests'] as Map<String, dynamic>? ?? {};
      final lastDate = dailyQuests['last_date'] as String?;
      final todayDate = DateTime.now().toIso8601String().split('T')[0];

      bool isToday = lastDate == todayDate;

      state = UserProgress(
        level: response['level'] ?? 1,
        xp: (response['xp'] as num?)?.toDouble() ?? 0.0,
        points: response['points'] ?? 0,
        redeemedVoucherIds: List<String>.from(response['redeemed_vouchers'] ?? []),
        hasCheckedIn: isToday ? (dailyQuests['checkIn'] ?? false) : false,
        hasTakenMeds: isToday ? (dailyQuests['meds'] ?? false) : false,
        hasLoggedMood: isToday ? (dailyQuests['mood'] ?? false) : false,
      );
    } catch (e) {
      debugPrint("Error loading progress: $e");
    }
  }

  Future<void> _updateDb() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final todayDate = DateTime.now().toIso8601String().split('T')[0];
    
    await _supabase.from('user_progress').update({
      'level': state.level,
      'xp': state.xp,
      'points': state.points,
      'redeemed_vouchers': state.redeemedVoucherIds,
      'daily_quests': {
        'last_date': todayDate,
        'checkIn': state.hasCheckedIn,
        'meds': state.hasTakenMeds,
        'mood': state.hasLoggedMood,
      }
    }).eq('user_id', user.id);
  }

  void addXp(double amount) {
    double newXp = state.xp + amount;
    int newLevel = state.level;
    
    if (newXp >= 1.0) {
      newXp = newXp - 1.0;
      newLevel++;
    }
    
    state = state.copyWith(level: newLevel, xp: newXp);
    _updateDb();
  }

  void addPoints(int amount) {
    state = state.copyWith(points: state.points + amount);
    _updateDb();
  }

  bool redeemVoucher(String voucherId) {
    try {
      final voucher = shopInventory.firstWhere((v) => v.id == voucherId);
      if (state.points >= voucher.cost && !state.redeemedVoucherIds.contains(voucherId)) {
        state = state.copyWith(
          points: state.points - voucher.cost,
          redeemedVoucherIds: [...state.redeemedVoucherIds, voucherId],
        );
        _updateDb();
        return true;
      }
    } catch (e) {
      // Voucher not found
    }
    return false;
  }
  
  void completeQuest(String questType) {
    bool updated = false;
    UserProgress newState = state;

    if (questType == 'checkIn' && !state.hasCheckedIn) {
      newState = newState.copyWith(hasCheckedIn: true);
      updated = true;
    } else if (questType == 'meds' && !state.hasTakenMeds) {
      newState = newState.copyWith(hasTakenMeds: true);
      updated = true;
    } else if (questType == 'mood' && !state.hasLoggedMood) {
      newState = newState.copyWith(hasLoggedMood: true);
      updated = true;
    }

    if (updated) {
      state = newState;
      // Award small XP and Points call _updateDb inside addXp/addPoints
      // But we need to update state first to ensure db update includes the quest flag
      // Wait, calling addXp triggers _updateDb which uses CURRENT state.
      // So I should update state first, then call addXp/addPoints?
      // No, addXp uses state.xp.
      // The _updateDb uses current state.
      // If I call addXp, it updates state and calls _updateDb.
      // So:
      final xpAmount = (newState.hasCheckedIn && newState.hasTakenMeds && newState.hasLoggedMood && 
        !(state.hasCheckedIn && state.hasTakenMeds && state.hasLoggedMood)) ? 0.25 : 0.05; // Bonus if completing all
      
      final pointsAmount = (newState.hasCheckedIn && newState.hasTakenMeds && newState.hasLoggedMood && 
        !(state.hasCheckedIn && state.hasTakenMeds && state.hasLoggedMood)) ? 60 : 10;

      // Updating state again with XP/Points
      addXp(xpAmount);
      addPoints(pointsAmount);
      
      // Note: addXp/addPoints call _updateDb. 
      // But _updateDb saves ALL state. 
      // So if I call addXp, it saves state (including new quest flags).
      // Then addPoints saves again.
      // It's a bit duplicate but fine.
    }
  }

  void cheatLevelUp() { 
    addXp(1.0); 
    addPoints(1000); 
  }
  
  void debugResetDaily() {
    state = state.copyWith(
      hasCheckedIn: false,
      hasTakenMeds: false,
      hasLoggedMood: false,
    );
    _updateDb();
  }
}

final userProgressProvider = NotifierProvider<UserProgressNotifier, UserProgress>(UserProgressNotifier.new);
