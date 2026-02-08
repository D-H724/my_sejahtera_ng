import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/user_progress_provider.dart';
import 'package:my_sejahtera_ng/core/providers/theme_provider.dart';
import 'package:my_sejahtera_ng/core/providers/user_provider.dart';
import 'package:my_sejahtera_ng/core/theme/app_themes.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HoloIdCard extends ConsumerStatefulWidget {
  final UserSession? userData; // Optional: To display other users' cards
  const HoloIdCard({super.key, this.userData});

  @override
  ConsumerState<HoloIdCard> createState() => _HoloIdCardState();
}

class _HoloIdCardState extends ConsumerState<HoloIdCard> with SingleTickerProviderStateMixin {
  double _x = 0;
  double _y = 0;
  bool _showMedicalInfo = false;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final currentTheme = ref.watch(themeProvider);
    
    // Use passed userData or fallback to signed-in user
    final user = widget.userData ?? ref.watch(userProvider);
    final isOwner = widget.userData == null && user != null;

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
      child: GestureDetector(
        onTap: () => setState(() => _showMedicalInfo = !_showMedicalInfo),
        child: Container(
          height: 230,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgGradient.map((c) => HSLColor.fromColor(c).withLightness(0.2).toColor()).toList(),
            ),
            boxShadow: [
              BoxShadow(
                color: themeColor.withOpacity(0.3 + (progress.level / 50)),
                blurRadius: 20.0 + (progress.level.toDouble()),
                spreadRadius: 1,
                offset: Offset(_x, _y),
              )
            ],
            border: Border.all(
              color: accentColor.withOpacity(0.5), 
              width: 1.5
            ),
          ),
          child: Stack(
            children: [
              // Noise & Glare (Visual Effects)
              Positioned.fill(child: Opacity(opacity: 0.05, child: Image.asset('assets/images/banner.png', fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox()))),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment(-_x / 10, -_y / 10),
                      colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.0)],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: 400.ms,
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(anim), child: child)),
                  child: _showMedicalInfo 
                      ? _buildMedicalInfo(user, themeColor, accentColor, isOwner) 
                      : _buildIdentityInfo(user, themeColor, accentColor, progress, isOwner),
                ),
              ),

              // Edit Button (Only for owner)
              if (isOwner)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(LucideIcons.pencil, color: Colors.white.withOpacity(0.5), size: 16),
                    onPressed: _showEditDialog,
                  ),
                ),
                
              // Mode Indicator
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                  child: Text(_showMedicalInfo ? "MEDICAL MODE" : "IDENTITY MODE", style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityInfo(UserSession? user, Color themeColor, Color accentColor, UserProgress progress, bool isOwner) {
    return Column(
      key: const ValueKey('identity'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.shieldCheck, color: accentColor, size: 20),
            const SizedBox(width: 8),
            Text("DIGITAL HEALTH ID", style: GoogleFonts.shareTechMono(color: themeColor, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Container(
              width: 65, height: 65,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: themeColor, width: 2),
                boxShadow: [BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 15)]
              ),
              child: const Icon(LucideIcons.user, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user?.fullName.toUpperCase() ?? "GUEST USER", 
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text("IC: ${user?.icNumber ?? '----------------'}", style: GoogleFonts.shareTechMono(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildBadge("LVL ${progress.level}", themeColor),
                      _buildBadge("FULLY VACCINATED", accentColor),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20), // Added padding to avoid overlap with "IDENTITY MODE"
      ],
    );
  }

  Widget _buildMedicalInfo(UserSession? user, Color themeColor, Color accentColor, bool isOwner) {
    return Column(
      key: const ValueKey('medical'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.cross, color: Colors.redAccent, size: 20),
            const SizedBox(width: 8),
            Text("EMERGENCY INFO", style: GoogleFonts.shareTechMono(color: Colors.redAccent, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMedicalField("BLOOD TYPE", user?.bloodType ?? "Unknown", Colors.redAccent),
            _buildMedicalField("ALLERGIES", user?.allergies ?? "None", Colors.orangeAccent),
          ],
        ),
        const SizedBox(height: 15),
        _buildMedicalField("CONDITION", user?.medicalCondition ?? "None", Colors.white),
        const SizedBox(height: 15),
        _buildMedicalField("EMERGENCY CONTACT", user?.emergencyContact ?? "Not Set", Colors.greenAccent),
      ],
    );
  }

  Widget _buildMedicalField(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: GoogleFonts.shareTechMono(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _showEditDialog() {
    final user = ref.read(userProvider);
    if (user == null) return;

    final bloodCtrl = TextEditingController(text: user.bloodType);
    final allergyCtrl = TextEditingController(text: user.allergies);
    final conditionCtrl = TextEditingController(text: user.medicalCondition);
    final contactCtrl = TextEditingController(text: user.emergencyContact);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B1E),
        title: const Text("Update Medical ID", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditField("Blood Type", bloodCtrl),
              _buildEditField("Allergies", allergyCtrl),
              _buildEditField("Medical Condition", conditionCtrl),
              _buildEditField("Emergency Contact", contactCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              ref.read(userNotifierProvider.notifier).updateMedicalInfo(
                blood: bloodCtrl.text,
                allergy: allergyCtrl.text,
                condition: conditionCtrl.text,
                contact: contactCtrl.text
              );
              Navigator.pop(ctx);
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }
  
  // Helper for provider access to fix compilation if needed
  NotifierProvider<UserNotifier, UserSession?> get userNotifierProvider => userProvider;

  Widget _buildEditField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}


