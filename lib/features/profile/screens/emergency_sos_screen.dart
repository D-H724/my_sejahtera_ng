import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';

class EmergencySOSScreen extends StatelessWidget {
  const EmergencySOSScreen({super.key});

  Future<void> _callEmergency() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '999',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // In a real app we'd show a dialog, but for now print/snackbar
      debugPrint("Could not launch 999");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0505), // Dark Red/Black bg
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        title: const Text("EMERGENCY MEDICAL CARD", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Photo and Name (Large)
              const Center(
                child: CircleAvatar(
                  radius: 60,
                   backgroundImage: AssetImage('assets/images/user_avatar.png'), // Placeholder or use icon
                   backgroundColor: Colors.white10,
                   child: Icon(LucideIcons.user, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "SHANJAAY DHIVIYAN THARA",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
               const Text(
                "DOB: 01 Jan 1995 (31 Y.O)",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Critical Info Grid
              Row(
                children: [
                  Expanded(child: _buildInfoCard("BLOOD TYPE", "A+", Colors.red)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard("WEIGHT", "75 KG", Colors.blue)),
                ],
              ),
              const SizedBox(height: 16),
              _buildLargeInfoCard("ALLERGIES", "Penicillin, Peanuts (Severe)", LucideIcons.alertTriangle),
              const SizedBox(height: 16),
              _buildLargeInfoCard("MEDICAL CONDITIONS", "Asthma (Inhaler Required)", LucideIcons.activity),
              const SizedBox(height: 16),
              _buildLargeInfoCard("EMERGENCY CONTACT", "Mother (012-345 6789)", LucideIcons.phone),
              
              const SizedBox(height: 40),
              
              // SOS Button
              SizedBox(
                height: 80,
                child: ElevatedButton.icon(
                  onPressed: _callEmergency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    elevation: 10,
                    shadowColor: Colors.redAccent,
                  ),
                  icon: const Icon(LucideIcons.phoneCall, size: 32, color: Colors.white),
                  label: const Text("CALL 999", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ).animate(onPlay: (c) => c.repeat())
               .shimmer(duration: 2.seconds, color: Colors.white54)
               .boxShadow(
                 begin: BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
                 end: BoxShadow(color: Colors.red.withOpacity(0.8), blurRadius: 40, spreadRadius: 10),
                 duration: 1.seconds,
                 curve: Curves.easeInOut
               ),
              
              const SizedBox(height: 20),
              const Text(
                "Show this screen to emergency responders",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildLargeInfoCard(String label, String value, IconData icon) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
