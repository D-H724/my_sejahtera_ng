import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/user_progress_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HoloIdCard extends ConsumerStatefulWidget {
  const HoloIdCard({super.key});

  @override
  ConsumerState<HoloIdCard> createState() => _HoloIdCardState();
}

class _HoloIdCardState extends ConsumerState<HoloIdCard> {
  double _x = 0;
  double _y = 0;
  StreamSubscription<GyroscopeEvent>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (!mounted) return;
      setState(() {
        _x += event.y * 2;
        _y += event.x * 2;
        _x = _x.clamp(-15.0, 15.0);
        _y = _y.clamp(-15.0, 15.0);
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  // Determine glow color based on level
  Color _getGlowColor(int level) {
    if (level >= 15) return const Color(0xFFE91E63); // Neon Pink - Master
    if (level >= 10) return const Color(0xFF00FFEA); // Cyan - Elite
    if (level >= 5) return Colors.blueAccent; // Blue - Regular
    return Colors.transparent; // No glow
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final glowColor = _getGlowColor(progress.level);

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(_y * 0.02)
      ..rotateY(_x * 0.02);

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C5364), Color(0xFF203A43), Color(0xFF0F2027)],
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.3 + (progress.level / 50)), // Intensity based on level
              blurRadius: 20.0 + (progress.level.toDouble()),
              spreadRadius: progress.level > 10 ? 2 : 0,
              offset: Offset(_x, _y),
            )
          ],
          border: Border.all(
            color: glowColor.withValues(alpha: 0.5), 
            width: progress.level >= 10 ? 2 : 1
          ),
        ),
        child: Stack(
          children: [
            // Noise
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset('assets/images/banner.png', fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox()),
              ),
            ),

            // Glare
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment(-_x / 10, -_y / 10),
                    end: Alignment(_x / 10, _y / 10),
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                         width: 50, height: 35,
                         decoration: BoxDecoration(
                           color: Colors.amber.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(6),
                           border: Border.all(color: Colors.amber.withOpacity(0.5)),
                         ),
                         child: const Icon(LucideIcons.cpu, color: Colors.amber, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text("DIGITAL RISK ID", style: GoogleFonts.shareTechMono(color: Colors.white38, fontSize: 12, letterSpacing: 2)),
                    ],
                  ),
                  const Spacer(),
                  
                  Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          shape: BoxShape.circle,
                          border: Border.all(color: glowColor, width: 2),
                          boxShadow: [
                            BoxShadow(color: glowColor.withValues(alpha: 0.5), blurRadius: 10)
                          ]
                        ),
                        child: const Icon(LucideIcons.user, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SHANJAAY KRISHNA", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("LVL ${progress.level} • ${progress.unlockedThemes.length} THEMES", style: GoogleFonts.outfit(color: glowColor, fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Holo Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(24),
                     gradient: LinearGradient(
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                       colors: [
                         Colors.blue.withOpacity(0.05),
                         Colors.purple.withOpacity(0.05),
                         Colors.cyan.withOpacity(0.05),
                       ]
                     )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
