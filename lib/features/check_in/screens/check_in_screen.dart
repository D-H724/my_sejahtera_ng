import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/theme/app_theme.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fake Camera Preview
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[900], // Placeholder for CameraPreview
              child: const Center(
                child: Text("Camera Preview", style: TextStyle(color: Colors.white24)),
              ),
            ),
          ),
          
          // Overlay
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  leading: const BackButton(color: Colors.white),
                  backgroundColor: Colors.transparent,
                  title: const Text("Scan QR Code", style: TextStyle(color: Colors.white)),
                ),
                const Spacer(),
                
                // Scanner Box
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentTeal, width: 2),
                  ),
                  child: Stack(
                    children: [
                      // Scanning Line
                      AnimatedBuilder(
                        animation: _scannerController,
                        builder: (context, child) {
                          return Positioned(
                            top: 20 + (260 * _scannerController.value),
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                boxShadow: [
                                  BoxShadow(color: Colors.redAccent.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Corner brackets logic can go here for more realism
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Place QR code inside the frame",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const Spacer(),
                
                // Bottom Actions
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.flashlight, color: Colors.white, size: 30),
                      ),
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: () {
                            // Simulate Check-in success
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Check-in Successful!"), backgroundColor: Colors.green),
                            );
                            Navigator.pop(context);
                          },
                          icon: const Icon(LucideIcons.camera, color: Colors.black, size: 30),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.history, color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
