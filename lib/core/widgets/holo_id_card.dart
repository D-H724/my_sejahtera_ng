import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/user_progress_provider.dart';
import 'package:my_sejahtera_ng/core/providers/theme_provider.dart';
import 'package:my_sejahtera_ng/core/theme/app_themes.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HoloIdCard extends ConsumerStatefulWidget {
  const HoloIdCard({super.key});

  @override
  ConsumerState<HoloIdCard> createState() => _HoloIdCardState();
}

class _HoloIdCardState extends ConsumerState<HoloIdCard> with SingleTickerProviderStateMixin {
  double _x = 0;
  double _y = 0;
  StreamSubscription<GyroscopeEvent>? _streamSubscription;
  late AnimationController _scanController;

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

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final currentTheme = ref.watch(themeProvider);
    
    // Dynamic theme colors
    final themeColor = AppThemes.getPrimaryColor(currentTheme);
    final accentColor = AppThemes.getAccentColor(currentTheme);
    final bgGradient = AppThemes.getBackgroundGradient(currentTheme);

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(_y * 0.02)
      ..rotateY(_x * 0.02);

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Darker version of theme gradient for card background
            colors: bgGradient.map((c) => HSLColor.fromColor(c).withLightness(0.2).toColor()).toList(),
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.3 + (progress.level / 50)),
              blurRadius: 20.0 + (progress.level.toDouble()),
              spreadRadius: 1,
              offset: Offset(_x, _y),
            )
          ],
          border: Border.all(
            color: accentColor.withValues(alpha: 0.5), 
            width: 1.5
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
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.0),
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
                       Row(
                         children: [
                            Icon(LucideIcons.shieldCheck, color: accentColor, size: 20),
                            const SizedBox(width: 8),
                            Text("DIGITAL HEALTH ID", style: GoogleFonts.shareTechMono(color: themeColor, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold)),
                         ],
                       ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(
                           color: Colors.green.withValues(alpha: 0.2),
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: Colors.greenAccent),
                           boxShadow: [
                             BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.2), blurRadius: 8)
                           ]
                         ),
                         child: Row(
                           children: const [
                             Icon(LucideIcons.checkCircle, color: Colors.greenAccent, size: 14),
                             SizedBox(width: 4),
                             Text("LOW RISK", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                           ],
                         ),
                       )
                    ],
                  ),
                  const Spacer(),
                  
                  Row(
                    children: [
                      Container(
                        width: 65, height: 65,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: themeColor, width: 2),
                          boxShadow: [
                            BoxShadow(color: themeColor.withValues(alpha: 0.4), blurRadius: 15)
                          ]
                        ),
                        child: const Icon(LucideIcons.user, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SHANJAAY DHIVIYAN THARA", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildBadge(context, "LVL ${progress.level}", themeColor),
                              const SizedBox(width: 8),
                              _buildBadge(context, "FULLY VACCINATED", accentColor),
                              if (progress.hasDailyFlame) ...[
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.flame, color: Colors.orangeAccent, size: 16)
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3))
                                  .then()
                                  .shimmer(duration: 1200.ms, color: Colors.yellow),
                              ]
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Scan Line Animation
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return Positioned(
                  top: -100 + (_scanController.value * 500), // Move from top to bottom
                  left: 0,
                  right: 0,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                           themeColor.withValues(alpha: 0.0),
                           themeColor.withValues(alpha: 0.2),
                           themeColor.withValues(alpha: 0.0),
                        ]
                      )
                    ),
                  ),
                );
              },
            ),

            // Holo Overlay (Iridescent)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(24),
                     gradient: LinearGradient(
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                       colors: [
                         Colors.blue.withValues(alpha: 0.05),
                         Colors.purple.withValues(alpha: 0.05),
                         themeColor.withValues(alpha: 0.05),
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

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: GoogleFonts.shareTechMono(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
