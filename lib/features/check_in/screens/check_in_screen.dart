import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/theme/app_theme.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/user_progress_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_sejahtera_ng/features/check_in/services/check_in_service.dart';
import 'package:my_sejahtera_ng/core/utils/ui_utils.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Safe Entry", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
             icon: const Icon(LucideIcons.history, color: Colors.white),
             onPressed: () async {
               final history = await CheckInService().getHistory();
               if (!context.mounted) return;
               
               showDialog(
                 context: context,
                 builder: (ctx) => AlertDialog(
                   backgroundColor: const Color(0xFF161B1E),
                   title: const Text("Check-In History", style: TextStyle(color: Colors.white)),
                   content: SizedBox(
                     width: double.maxFinite,
                     child: history.isEmpty 
                     ? const Text("No recent check-ins found.", style: TextStyle(color: Colors.white70))
                     : ListView.builder(
                       shrinkWrap: true,
                       itemCount: history.length,
                       itemBuilder: (ctx, i) {
                         final item = history[i];
                         // Parse time
                         final time = DateTime.parse(item['check_in_time']).toLocal();
                         return ListTile(
                           leading: const Icon(LucideIcons.mapPin, color: Colors.cyanAccent),
                           title: Text(item['location_name'] ?? "Unknown", style: const TextStyle(color: Colors.white)),
                           subtitle: Text("${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2,'0')}", style: const TextStyle(color: Colors.white54)),
                         );
                       },
                     ),
                   ),
                   actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CLOSE"))],
                 ),
               );
             },
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. Full Screen Camera Placeholder with Gradient Overlay
          Container(
            color: Colors.black,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent, Colors.black54],
              ).createShader(bounds),
              blendMode: BlendMode.darken,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F2027), Color(0xFF203A43)],
                  ),
                ),
                child: const Center(
                  child: Text("Camera Preview", style: TextStyle(color: Colors.white10, fontSize: 30, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          
          // 2. Scanner UI
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Scanner Frame
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glass Frame
                      Container(
                        width: 280, height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: GlassContainer(
                          width: 280, height: 280,
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          child: const SizedBox(),
                        ),
                      ),
                      
                      // Active Corners
                      _buildCornerFrame(),
                      
                      // Moving Laser
                      AnimatedBuilder(
                        animation: _scannerController,
                        builder: (context, child) {
                          return Positioned(
                            top: 20 + (240 * _scannerController.value),
                            child: Container(
                              width: 240,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent,
                                boxShadow: [
                                  BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 10, spreadRadius: 2)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 30),
                Text(
                  "Align QR Code within the frame",
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
                ).animate().fadeIn(delay: 500.ms),
                const Spacer(),
                
                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GlassContainer(
                    borderRadius: BorderRadius.circular(50),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: (){}, icon: const Icon(LucideIcons.zap, color: Colors.white)),
                        const SizedBox(width: 20),
                        // Simulate Scan Button
                        GestureDetector(
                          onTap: () async {
                             try {
                               // Simulate mock location for now (in real app, use Geocoder)
                               final mockPlaces = ["Sunway Pyramid", "Mid Valley", "KLCC", "Pavilion", "One Utama"];
                               final place = (mockPlaces..shuffle()).first;
                               
                               await CheckInService().checkIn(place, "Kuala Lumpur");
                               
                               if (!context.mounted) return;
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text("Checked in at $place!"), backgroundColor: Colors.green),
                               );
                               ref.read(userProgressProvider.notifier).completeQuest('checkIn');
                               Navigator.pop(context);
                             } catch (e) {
                               showElegantErrorDialog(
                                 context,
                                 title: "Check-in Failed",
                                 message: e.toString().contains("User not logged in") 
                                  ? "You must be logged in to check in." 
                                  : e.toString(),
                                 buttonText: "OK",
                               );
                             }
                          },
                          child: Container(
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 20)
                              ]
                            ),
                            child: const Icon(LucideIcons.scanLine, color: Colors.black, size: 30),
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.1,1.1)),
                        const SizedBox(width: 20),
                        IconButton(onPressed: (){}, icon: const Icon(LucideIcons.image, color: Colors.white)),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 1, end: 0, delay: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerFrame() {
    const double size = 30;
    const double thickness = 4;
    const color = Colors.cyanAccent;
    
    return SizedBox(
      width: 280, height: 280,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: Container(width: size, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
          Positioned(top: 0, left: 0, child: Container(width: thickness, height: size, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
          
          Positioned(top: 0, right: 0, child: Container(width: size, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
          Positioned(top: 0, right: 0, child: Container(width: thickness, height: size, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
          
          Positioned(bottom: 0, left: 0, child: Container(width: size, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
          Positioned(bottom: 0, left: 0, child: Container(width: thickness, height: size, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
          
          Positioned(bottom: 0, right: 0, child: Container(width: size, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
          Positioned(bottom: 0, right: 0, child: Container(width: thickness, height: size, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
        ],
      ),
    );
  }
}
