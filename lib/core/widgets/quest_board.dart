import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/quest_provider.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/user_progress_provider.dart';
import 'package:my_sejahtera_ng/features/hotspots/screens/hotspot_screen.dart';
import 'package:my_sejahtera_ng/features/health_assistant/screens/ai_chat_screen.dart';
import 'package:my_sejahtera_ng/features/vaccine/screens/vaccine_screen.dart';

class QuestBoard extends ConsumerWidget {
  const QuestBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final quests = ref.watch(questProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Daily Quests", style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber, 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 10)
                ]
              ),
              child: Text("LVL ${progress.level}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 12),
        
        // XP Bar
        Container(
          height: 10, 
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(5)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.xp,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(colors: [Colors.amber, Colors.orange])
              ),
            ),
          ).animate(target: progress.xp == 1 ? 1 : 0).shimmer(duration: 1.seconds),
        ),
        const SizedBox(height: 4),
        Text("${(progress.xp * 1000).toInt()}/1000 XP", style: const TextStyle(color: Colors.white54, fontSize: 12)),
        
        const SizedBox(height: 16),
        
        // Quests List
        ...quests.map((quest) {
           return Padding(
             padding: const EdgeInsets.only(bottom: 12),
             child: GlassContainer(
               borderRadius: BorderRadius.circular(16),
               padding: const EdgeInsets.all(12),
               child: Row(
                 children: [
                   Container(
                     padding: const EdgeInsets.all(10),
                     decoration: const BoxDecoration(
                       color: Colors.white10,
                       shape: BoxShape.circle
                     ),
                     child: Icon(quest.icon, color: quest.status == QuestStatus.claimed ? Colors.greenAccent : Colors.white, size: 20),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(quest.title, style: TextStyle(
                           color: quest.status == QuestStatus.claimed ? Colors.white54 : Colors.white,
                           decoration: quest.status == QuestStatus.claimed ? TextDecoration.lineThrough : null,
                           fontWeight: FontWeight.w600
                         )),
                         Text("+${quest.xp} XP", style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
                       ],
                     ),
                   ),
                   
                   _buildActionButton(context, ref, quest),
                 ],
               ),
             ),
           );
        })
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, Quest quest) {
    switch (quest.status) {
      case QuestStatus.claimed:
        return const Icon(LucideIcons.checkCircle, color: Colors.greenAccent);
        
      case QuestStatus.completed:
        return ElevatedButton(
          onPressed: () {
            ref.read(questProvider.notifier).claimQuest(quest.id, ref);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Claimed +${quest.xp} XP!"),
              backgroundColor: Colors.amber,
              duration: 800.ms,
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          ),
          child: const Text("Claim XP"),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 800.ms, begin: const Offset(1,1), end: const Offset(1.1, 1.1));
        
      case QuestStatus.pending:
        if (quest.type == QuestType.navigation) {
          return ElevatedButton(
             onPressed: () {
                _handleNavigation(context, ref, quest.actionId!);
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.blueAccent.withOpacity(0.2),
               foregroundColor: Colors.blueAccent,
               elevation: 0,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.blueAccent)),
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
             ),
             child: const Text("GO"),
           );
        } else {
          // Manual quest (like "Drink Water")
          return ElevatedButton(
             onPressed: () {
                ref.read(questProvider.notifier).markManualComplete(quest.id);
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.white10,
               foregroundColor: Colors.white,
               elevation: 0,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
             ),
             child: const Text("Mark Done"),
           );
        }
    }
  }

  void _handleNavigation(BuildContext context, WidgetRef ref, String actionId) {
    Widget targetScreen;
    if (actionId == 'nav_hotspots') {
      targetScreen = const HotspotScreen();
    } else if (actionId == 'nav_ai') {
      targetScreen = const AIChatScreen();
    } else if (actionId == 'nav_vaccine') {
      targetScreen = const VaccineScreen();
    } else {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    ).then((_) {
      // Upon return, check if we should auto-complete
      // In a real app we might want to check if they actually *did* something there
      // For now, visiting is enough.
      ref.read(questProvider.notifier).completeQuestByAction(actionId);
    });
  }
}
