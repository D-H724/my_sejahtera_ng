import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/providers/user_provider.dart';
import 'package:my_sejahtera_ng/core/theme/app_theme.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:my_sejahtera_ng/features/auth/screens/login_screen.dart';
import 'package:my_sejahtera_ng/features/gamification/screens/rewards_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("My Profile"),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryDark, AppTheme.primaryBlue],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: user == null
                ? const Center(child: Text("No User Logged In", style: TextStyle(color: Colors.white)))
                : Column(
                    children: [
                      const SizedBox(height: 20),
                      // Avatar & Name
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.accentTeal,
                        child: Icon(LucideIcons.user, size: 50, color: AppTheme.primaryDark),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          textAlign: TextAlign.center,
                      ),
                      Text(
                        "MySJ ID: ${user.username}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Rewards Entry Point
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RewardsScreen()));
                        },
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.crown, color: Colors.black, size: 20),
                              ),
                              const SizedBox(width: 16),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Rewards & Customization", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text("Themes, Frames, Icons", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              const Icon(LucideIcons.chevronRight, color: Colors.white54),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),

                      // MySJ ID Card
                      GlassContainer(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              "MySJ ID",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Icon(LucideIcons.qrCode, size: 150, color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Scan to verify",
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Details List
                      GlassContainer(
                        width: double.infinity,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _buildProfileItem("Full Name", user.fullName),
                            _buildDivider(),
                            _buildProfileItem("IC / Passport", user.icNumber),
                            _buildDivider(),
                            _buildProfileItem("Phone", user.phone),
                            _buildDivider(),
                            _buildProfileItem("Status", "Verified Account", isVerified: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(userProvider.notifier).logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Log Out"),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, {bool isVerified = false}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                if (isVerified) ...[
                  const SizedBox(width: 5),
                  const Icon(LucideIcons.checkCircle, size: 16, color: AppTheme.accentTeal),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.white10);
  }
}
