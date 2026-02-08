import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:my_sejahtera_ng/core/providers/user_provider.dart';

class DigitalCertCard extends ConsumerStatefulWidget {
  const DigitalCertCard({super.key});

  @override
  ConsumerState<DigitalCertCard> createState() => _DigitalCertCardState();
}

class _DigitalCertCardState extends ConsumerState<DigitalCertCard> with SingleTickerProviderStateMixin {
  double _x = 0;
  double _y = 0;
  late AnimationController _shimmerController;
  @override
  void initState() {
    super.initState();
    // Gyroscope effect disabled by user request

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    
    // Matrix for 3D Transform
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(_y * 0.01)
      ..rotateY(_x * 0.01);

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: Container(
        height: 500, // Large certificate format
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
               Color(0xFFE6B800), // Gold
               Color(0xFFF0E68C), // Light Gold
               Color(0xFFB8860B), // Dark Gold
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB8860B).withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 2,
              offset: Offset(_x, _y),
            )
          ],
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // 1. Texture / Noise
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset('assets/images/banner.png', fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.black)),
                ),
              ),

              // 2. Holographic Gradient Overlay (Animated)
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        stops: [
                           _shimmerController.value - 0.2,
                           _shimmerController.value,
                           _shimmerController.value + 0.2
                        ],
                      )
                    ),
                  );
                },
              ),

              // 3. Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.shieldCheck, color: Colors.black, size: 28),
                        const SizedBox(width: 10),
                        Text("DIGITAL CERTIFICATE", style: GoogleFonts.shareTechMono(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // User Info
                    Text(user?.fullName.toUpperCase() ?? "USER NAME", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 5),
                    Text("IC/Passport: ${user?.icNumber ?? 'N/A'}", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 14)),
                    
                    const SizedBox(height: 15),

                    // QR Code
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
                          ]
                        ),
                        child: QrImageView(
                          data: "https://mysejahtera.malaysia.gov.my?id=${user?.username}",
                          version: QrVersions.auto,
                          size: 150.0,
                          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Verification Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.checkCircle, color: Colors.amber, size: 20).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            "FULLY VACCINATED", 
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 4. Glare effect moves with tilt
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-_x / 5, -_y / 5),
                      end: Alignment(_x / 5, _y / 5),
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
