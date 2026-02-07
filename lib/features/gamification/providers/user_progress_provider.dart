import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sejahtera_ng/features/gamification/models/voucher.dart';

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
      level: 5,
      xp: 0.3,
      points: 450, // Start with some points to encourage first redemption
      redeemedVoucherIds: [],
    );
  }

  bool get isDailyQuestComplete => hasCheckedIn && hasTakenMeds && hasLoggedMood;
}

class UserProgressNotifier extends Notifier<UserProgress> {
  // Static Store Inventory
  static const List<Voucher> shopInventory = [
    Voucher(
      id: 'shopee_rm5',
      title: 'Shopee',
      description: 'RM5 Off Shipping',
      discountCode: 'SHOPEEMYSJ',
      expiryDate: '31 Dec 2026',
      cost: 300,
      brandColor: Colors.orange,
    ),
    Voucher(
      id: 'tealive_10',
      title: 'Tealive',
      description: '10% Off Bill',
      discountCode: 'MYSJTEA10',
      expiryDate: '31 Dec 2026',
      cost: 500,
      brandColor: Colors.purple,
    ),
    Voucher(
      id: 'grab_5',
      title: 'GrabFood',
      description: 'RM5 Off Delivery',
      discountCode: 'GRABMYSJ5',
      expiryDate: '30 Nov 2026',
      cost: 800,
      brandColor: Colors.green,
    ),
    Voucher(
      id: 'kfc_snack',
      title: 'KFC',
      description: 'Free Cheesy Wedges',
      discountCode: 'KFCMYSJ',
      expiryDate: '30 Nov 2026',
      cost: 1000,
      brandColor: Colors.redAccent,
    ),
    Voucher(
      id: 'watsons_20',
      title: 'Watsons',
      description: 'RM20 Off Health',
      discountCode: 'WATSONS20',
      expiryDate: '15 Oct 2026',
      cost: 1500,
      brandColor: Colors.teal,
    ),
    Voucher(
      id: 'golds_gym',
      title: 'Gold\'s Gym',
      description: '1 Week Free Pass',
      discountCode: 'GOLDSFREE',
      expiryDate: '31 Dec 2026',
      cost: 2500,
      brandColor: Colors.amber,
    ),
  ];

  @override
  UserProgress build() {
    return UserProgress.initial();
  }

  void addXp(double amount) {
    double newXp = state.xp + amount;
    int newLevel = state.level;
    
    if (newXp >= 1.0) {
      newXp = newXp - 1.0;
      newLevel++;
    }
    
    state = state.copyWith(level: newLevel, xp: newXp);
  }

  void addPoints(int amount) {
    state = state.copyWith(points: state.points + amount);
  }

  bool redeemVoucher(String voucherId) {
    try {
      final voucher = shopInventory.firstWhere((v) => v.id == voucherId);
      if (state.points >= voucher.cost && !state.redeemedVoucherIds.contains(voucherId)) {
        state = state.copyWith(
          points: state.points - voucher.cost,
          redeemedVoucherIds: [...state.redeemedVoucherIds, voucherId],
        );
        return true;
      }
    } catch (e) {
      // Voucher not found
    }
    return false;
  }
  
  // Daily Quest Logic
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
      // Award small XP
      addXp(0.05);
      addPoints(10); // 10 points per step

      if (newState.hasCheckedIn && newState.hasTakenMeds && newState.hasLoggedMood) {
        addXp(0.2); 
        addPoints(50); // 50 points bonus
      }
      state = newState;
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
  }
}

final userProgressProvider = NotifierProvider<UserProgressNotifier, UserProgress>(UserProgressNotifier.new);

