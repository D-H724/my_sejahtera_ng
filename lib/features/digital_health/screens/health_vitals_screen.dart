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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getBmiColor(vitals.bmiStatus).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getBmiColor(vitals.bmiStatus)),
                  ),
                  child: Text("BMI Status: ${vitals.bmiStatus}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),
                _buildChartCard(context, ref, "Heart Rate", "${vitals.heartRate} bpm", Colors.redAccent, LucideIcons.heart, [70, 72, 75, 73, 78, 74, vitals.heartRate.toDouble()], 
                  onTap: () => _showUpdateSheet(context, ref, "Heart Rate", (val) => ref.read(vitalsProvider.notifier).updateHeartRate(int.parse(val)))),
                const SizedBox(height: 20),
                _buildChartCard(context, ref, "Blood Pressure", "${vitals.systolicBP}/${vitals.diastolicBP} mmHg", Colors.blueAccent, LucideIcons.activity, [118, 120, 119, 121, 122, 120, vitals.systolicBP.toDouble()],
                  onTap: () => _updateBP(context, ref)), // Special case for BP
                const SizedBox(height: 20),
                 _buildChartCard(context, ref, "Weight", "${vitals.weight} kg", Colors.orangeAccent, LucideIcons.scale, [66, 65.8, 65.5, 65.3, 65.1, 65.0, vitals.weight],
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

  Widget _buildChartCard(BuildContext context, WidgetRef ref, String title, String value, Color color, IconData icon, List<double> dataPoints, {VoidCallback? onTap}) {
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
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideX(),
    );
  }
}
