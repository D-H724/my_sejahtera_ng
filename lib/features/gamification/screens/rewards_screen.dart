import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/quest_provider.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/user_progress_provider.dart';
import 'package:my_sejahtera_ng/features/gamification/models/voucher.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final quests = ref.watch(questProvider);
    final shopInventory = UserProgressNotifier.shopInventory;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Rewards & Shop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, shadows: [Shadow(color: Colors.black45, blurRadius: 10)])),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
           IconButton(
            onPressed: () {
              ref.read(userProgressProvider.notifier).cheatLevelUp();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cheater! XP & Points Added!")));
            },
            icon: const Icon(LucideIcons.zap, color: Colors.amber),
          ).animate().shimmer(delay: 5.seconds, duration: 2.seconds)
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Points & Level Header
                _buildPointsHeader(progress).animate().fadeIn().slideY(),
                const SizedBox(height: 30),

                // Dynamic Daily Quests (Modified Header)
                Row(
                  children: [
                    const Icon(LucideIcons.flame, color: Colors.orangeAccent, size: 20),
                    const SizedBox(width: 8),
                    const Text("Daily Quests", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),

                GlassContainer(
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (quests.isEmpty)
                         const Text("No quests available right now.", style: TextStyle(color: Colors.white70)),
                      
                      ...quests.asMap().entries.map((entry) {
                        final index = entry.key;
                        final quest = entry.value;
                        return Column(
                          children: [
                            _buildQuestRow(
                              quest.title, 
                              "+${quest.xp} XP • +${quest.points} Pts", 
                              quest.status == QuestStatus.completed || quest.status == QuestStatus.claimed, 
                              quest.icon,
                              Colors.primaries[index % Colors.primaries.length],
                              onTap: () {
                                if (quest.status == QuestStatus.pending) {
                                  ref.read(questProvider.notifier).markManualComplete(quest.id);
                                } else if (quest.status == QuestStatus.completed) {
                                  ref.read(questProvider.notifier).claimQuest(quest.id, ref);
                                }
                              }
                            ),
                            if (index < quests.length - 1)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1, color: Colors.white10),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(),
                
                const SizedBox(height: 30),
                
                // Points Shop
                Row(
                  children: [
                    const Icon(LucideIcons.shoppingBag, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text("Rewards Shop", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
                
                // Vertical List of Vouchers
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: shopInventory.length,
                    itemBuilder: (context, index) {
                      final voucher = shopInventory[index];
                      final isRedeemed = progress.redeemedVoucherIds.contains(voucher.id);
                      final canAfford = progress.points >= voucher.cost;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildVoucherShopCard(context, ref, voucher, isRedeemed, canAfford)
                            .animate().fadeIn(delay: (300 + (index * 100)).ms).slideX(),
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsHeader(UserProgress progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("YOUR POINTS", style: TextStyle(color: Colors.white70, letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text("${progress.points}", style: const TextStyle(color: Colors.amber, fontSize: 36, fontWeight: FontWeight.w900)),
                      const Text(" pts", style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2)
                ),
                child: const Icon(LucideIcons.coins, color: Colors.amber, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.xp, // Level progress
              backgroundColor: Colors.black26,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Level ${progress.level}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Text("Next Level", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVoucherShopCard(BuildContext context, WidgetRef ref, Voucher voucher, bool isRedeemed, bool canAfford) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: voucher.brandColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: voucher.brandColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.tag, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(voucher.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(voucher.description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    if (isRedeemed)
                       Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(voucher.discountCode, style: TextStyle(color: voucher.brandColor, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            Icon(LucideIcons.copy, size: 16, color: voucher.brandColor),
                          ],
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: canAfford ? () => _confirmRedemption(context, ref, voucher) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: voucher.brandColor,
                          disabledBackgroundColor: Colors.black26,
                          disabledForegroundColor: Colors.white38,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(canAfford ? "Redeem" : "Locked", style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            Container(width: 1, height: 12, color: canAfford ? voucher.brandColor : Colors.white24),
                            const SizedBox(width: 6),
                            Text("${voucher.cost} pts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: canAfford ? voucher.brandColor.withOpacity(0.8) : Colors.white38)),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmRedemption(BuildContext context, WidgetRef ref, Voucher voucher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text("Redeem Reward?", style: TextStyle(color: Colors.white)),
        content: Text("Spend ${voucher.cost} points to unlock '${voucher.title}'?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text("Confirm", style: TextStyle(color: Colors.black)),
            onPressed: () {
               final success = ref.read(userProgressProvider.notifier).redeemVoucher(voucher.id);
               Navigator.pop(ctx);
               if (success) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voucher Redeemed! Check your shop.")));
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough points!")));
               }
            },
          ),
        ],
      )
    );
  }

  Widget _buildQuestRow(String title, String subtitle, bool isCompleted, IconData icon, Color color, {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.check, color: Colors.greenAccent, size: 14),
                  SizedBox(width: 4),
                  Text("DONE", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 10)),
                ],
              ),
            ).animate().scale(curve: Curves.elasticOut)
          else
            Container(
               width: 24, height: 24,
               decoration: BoxDecoration(
                 border: Border.all(color: Colors.white24, width: 2),
                 shape: BoxShape.circle
               ),
            ),
        ],
      ),
    );
  }
}

