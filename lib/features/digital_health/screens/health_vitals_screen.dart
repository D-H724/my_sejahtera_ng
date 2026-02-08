import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_sejahtera_ng/features/digital_health/providers/vitals_provider.dart';

class HealthVitalsScreen extends ConsumerWidget {
  const HealthVitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitals = ref.watch(vitalsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(""), 
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          _buildConnectionToggle(context, ref, vitals.isDeviceConnected),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF20002c), Color(0xFFcbb4d4)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Animated Title
                Center(
                  child: Text(
                    "Health Vitals",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      shadows: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ).animate()
                 .scale(duration: 600.ms, curve: Curves.elasticOut)
                 .fadeIn(duration: 400.ms),
                 
                const SizedBox(height: 10),
                 
                const SizedBox(height: 10),
                
                // Always show BMI Status
                // 3D Avatar & BMI Status Visualizer
                _buildBmiAvatar(vitals.bmiStatus),
                const SizedBox(height: 10),

                const SizedBox(height: 16),

                // Show Live Data Indicator if Connected
                if (vitals.isDeviceConnected) ...[
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.greenAccent),
                      boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 10)]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.activity, color: Colors.greenAccent, size: 16)
                          .animate(onPlay: (c) => c.repeat()).fade(duration: 1.seconds),
                        const SizedBox(width: 8),
                        const Text("LIVE DEVICE DATA", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.5),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 24),
                _buildChartCard(context, ref, "Heart Rate", "${vitals.heartRate} bpm", Colors.redAccent, LucideIcons.heart, [70, 72, 75, 73, 78, 74, vitals.heartRate.toDouble()], 
                  isLive: vitals.isDeviceConnected,
                  onTap: () => _handleCardTap(context, ref, vitals.isDeviceConnected, "Heart Rate", (val) => ref.read(vitalsProvider.notifier).updateHeartRate(int.parse(val)))),
                const SizedBox(height: 20),
                _buildChartCard(context, ref, "Blood Pressure", "${vitals.systolicBP}/${vitals.diastolicBP} mmHg", Colors.blueAccent, LucideIcons.activity, [118, 120, 119, 121, 122, 120, vitals.systolicBP.toDouble()],
                  isLive: vitals.isDeviceConnected,
                  onTap: () => vitals.isDeviceConnected ? _showDeviceToast(context) : _updateBP(context, ref)), 
                const SizedBox(height: 20),
                 _buildChartCard(context, ref, "Weight", "${vitals.weight} kg", Colors.orangeAccent, LucideIcons.scale, [66, 65.8, 65.5, 65.3, 65.1, 65.0, vitals.weight],
                   // Allow manual update for weight even if connected, usually scales are separate
                   onTap: () => _showUpdateSheet(context, ref, "Weight (kg)", (val) => ref.read(vitalsProvider.notifier).updateWeight(double.parse(val)))),
                const SizedBox(height: 20),
                 _buildChartCard(context, ref, "Height", "${vitals.height} cm", Colors.purpleAccent, LucideIcons.ruler, [175, 175, 175, 175, 175, 175, vitals.height],
                   onTap: () => _showUpdateSheet(context, ref, "Height (cm)", (val) => ref.read(vitalsProvider.notifier).updateHeight(double.parse(val)))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionToggle(BuildContext context, WidgetRef ref, bool isConnected) {
    return GestureDetector(
      onTap: () {
        ref.read(vitalsProvider.notifier).toggleDeviceConnection(!isConnected);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isConnected ? "Device Disconnected. Switched to Manual Mode." : "Smart Watch Connected! Receiving Live Data..."),
            backgroundColor: isConnected ? Colors.redAccent : Colors.green,
            duration: const Duration(seconds: 2),
          )
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isConnected ? Colors.green.withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isConnected ? Colors.greenAccent : Colors.white24),
        ),
        child: Row(
          children: [
            Icon(isConnected ? LucideIcons.watch : LucideIcons.watch, color: isConnected ? Colors.greenAccent : Colors.white54, size: 18),
            const SizedBox(width: 8),
            Text(isConnected ? "Connected" : "Connect Device", style: TextStyle(color: isConnected ? Colors.greenAccent : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _handleCardTap(BuildContext context, WidgetRef ref, bool isConnected, String title, Function(String) onSave) {
    if (isConnected) {
      _showDeviceToast(context);
    } else {
      _showUpdateSheet(context, ref, title, onSave);
    }
  }

  void _showDeviceToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Reading from Smart Watch... Disable connection for manual input."),
        backgroundColor: Colors.blueGrey,
        duration: Duration(seconds: 2),
      )
    );
  }

  Color _getBmiColor(String status) {
    if (status == 'Normal') return Colors.greenAccent;
    if (status == 'Overweight') return Colors.orangeAccent;
    if (status == 'Obese') return Colors.redAccent;
    return Colors.blueAccent; 
  }

  void _showUpdateSheet(BuildContext context, WidgetRef ref, String title, Function(String) onSave) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF20002c),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Update $title", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter new value",
                hintStyle: const TextStyle(color: Colors.white30),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white30), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.purpleAccent), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    onSave(controller.text);
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text("SAVE"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _updateBP(BuildContext context, WidgetRef ref) {
     // Simplified BP update for now
     final sysCtrl = TextEditingController();
     final diaCtrl = TextEditingController();
     showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF20002c),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Text("Update Blood Pressure", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 15),
             Row(
               children: [
                 Expanded(child: TextField(controller: sysCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Systolic", labelStyle: TextStyle(color: Colors.white70)))),
                 const SizedBox(width: 15),
                 Expanded(child: TextField(controller: diaCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Diastolic", labelStyle: TextStyle(color: Colors.white70)))),
               ],
             ),
             const SizedBox(height: 20),
             SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (sysCtrl.text.isNotEmpty && diaCtrl.text.isNotEmpty) {
                    ref.read(vitalsProvider.notifier).updateBP(int.parse(sysCtrl.text), int.parse(diaCtrl.text));
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text("SAVE"),
              ),
            ),
             const SizedBox(height: 30),
          ],
        ),
      ));
  }

  Widget _buildChartCard(BuildContext context, WidgetRef ref, String title, String value, Color color, IconData icon, List<double> dataPoints, {VoidCallback? onTap, bool isLive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const Spacer(),
                if (isLive)
                  const Icon(LucideIcons.radio, size: 14, color: Colors.greenAccent).animate(onPlay: (c) => c.repeat()).fade()
                else
                  const Icon(LucideIcons.edit2, size: 14, color: Colors.white30),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Real Chart Visualization
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.2), 
                      ),
                    ),
                  ],
                  minX: 0,
                  maxX: dataPoints.length.toDouble() - 1,
                  minY: dataPoints.reduce((a, b) => a < b ? a : b) * 0.95,
                  maxY: dataPoints.reduce((a, b) => a > b ? a : b) * 1.05,
                ),
                duration: const Duration(milliseconds: 300), // Smooth transition
                curve: Curves.easeInOut,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideX(),
    );
  }

  Widget _buildBmiAvatar(String status) {
    String assetPath;
    if (status == 'Underweight') {
      assetPath = 'assets/images/bmi_underweight.png';
    } else if (status == 'Obese' || status == 'Overweight') {
      assetPath = 'assets/images/bmi_overweight.png';
    } else {
      assetPath = 'assets/images/bmi_normal.png'; // Default/Normal
    }

    return Column(
      children: [
        SizedBox(
          height: 280, // Generous height for the 3D character
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
            child: Container(
              key: ValueKey(status),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  height: 280,
                  width: 250, // Constrain width for a card look
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _getBmiColor(status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _getBmiColor(status), width: 2),
            boxShadow: [
              BoxShadow(
                color: _getBmiColor(status).withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status == 'Normal' ? LucideIcons.thumbsUp : (status == 'Underweight' ? LucideIcons.arrowDown : LucideIcons.arrowUp),
                color: _getBmiColor(status),
                size: 20
              ),
              const SizedBox(width: 8),
              Text(
                "Status: $status",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.3),
      ],
    );
  }
}
