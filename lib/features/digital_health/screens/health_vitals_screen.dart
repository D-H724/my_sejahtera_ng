import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HealthVitalsScreen extends StatelessWidget {
  const HealthVitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(""), // Title moved to body for better visibility
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
                const SizedBox(height: 24),
                _buildChartCard("Heart Rate", "74 bpm", Colors.redAccent, LucideIcons.heart, [70, 72, 75, 73, 78, 74, 72])
                    .animate().fadeIn().slideX(),
                const SizedBox(height: 20),
                _buildChartCard("Blood Pressure", "120/80 mmHg", Colors.blueAccent, LucideIcons.activity, [118, 120, 119, 121, 122, 120, 119])
                    .animate().fadeIn(delay: 200.ms).slideX(),
                const SizedBox(height: 20),
                 _buildChartCard("Weight", "65 kg", Colors.orangeAccent, LucideIcons.scale, [66, 65.8, 65.5, 65.3, 65.1, 65.0, 65.0])
                    .animate().fadeIn(delay: 400.ms).slideX(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        backgroundColor: Colors.purpleAccent,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildChartCard(String title, String value, Color color, IconData icon, List<double> dataPoints) {
    return GlassContainer(
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
              Text("Today", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
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
    );
  }
}
