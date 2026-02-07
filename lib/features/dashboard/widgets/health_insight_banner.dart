import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_sejahtera_ng/core/theme/app_themes.dart';
import 'package:my_sejahtera_ng/core/providers/theme_provider.dart';

class HealthInsightBanner extends ConsumerStatefulWidget {
  const HealthInsightBanner({super.key});

  @override
  ConsumerState<HealthInsightBanner> createState() => _HealthInsightBannerState();
}

class _HealthInsightBannerState extends ConsumerState<HealthInsightBanner> with SingleTickerProviderStateMixin {
  late AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final themeColor = AppThemes.getPrimaryColor(currentTheme);

    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 260, // Fixed height for chart
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeColor.withOpacity(0.1),
                themeColor.withOpacity(0.8),
                themeColor.withOpacity(0.1),
              ],
              stops: [
                0.0,
                (_borderController.value),
                1.0
              ],
              transform: const GradientRotation(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: themeColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8), // Darker for chart contrast
              borderRadius: BorderRadius.circular(22),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Weekly Health Score",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "You're doing great!",
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.trendingUp, color: Colors.greenAccent, size: 14),
                              const SizedBox(width: 4),
                              const Text("+12%", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Chart
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) {
                                  const style = TextStyle(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  );
                                  String text;
                                  switch (value.toInt()) {
                                    case 0: text = 'Mon'; break;
                                    case 1: text = 'Tue'; break;
                                    case 2: text = 'Wed'; break;
                                    case 3: text = 'Thu'; break;
                                    case 4: text = 'Fri'; break;
                                    case 5: text = 'Sat'; break;
                                    case 6: text = 'Sun'; break;
                                    default: return Container();
                                  }
                                  return Text(text, style: style);
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: _getTooltipColor,
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              tooltipPadding: const EdgeInsets.all(8),
                              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  String guidance = _getGuidance(barSpot.x.toInt());
                                  return LineTooltipItem(
                                    'Score: ${barSpot.y.toInt()}\n$guidance',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '\nTap for details',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 3) // Mon
                                ,FlSpot(1, 4) // Tue
                                ,FlSpot(2, 3.5) // Wed
                                ,FlSpot(3, 5) // Thu
                                ,FlSpot(4, 4.5) // Fri
                                ,FlSpot(5, 6) // Sat
                                ,FlSpot(6, 6.5) // Sun
                              ],
                              isCurved: true,
                              color: themeColor,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: themeColor.withOpacity(0.2),
                                gradient: LinearGradient(
                                  colors: [
                                    themeColor.withOpacity(0.4),
                                    themeColor.withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(LucideIcons.moon, "7h 30m", "Sleep", Colors.purpleAccent),
                        _buildStatItem(LucideIcons.footprints, "8,432", "Steps", Colors.orangeAccent),
                        _buildStatItem(LucideIcons.activity, "72 bpm", "Vitals", Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getGuidance(int dayIndex) {
    switch (dayIndex) {
      case 0: return "Improvement: Walk +2k steps.";
      case 1: return "Improvement: Sleep by 11 PM.";
      case 2: return "Improvement: Drink more water.";
      case 3: return "Great! Keep it up.";
      case 4: return "Improvement: Lower sodium.";
      case 5: return "Improvement: 30m Cardio.";
      case 6: return "Excellent!";
      default: return "";
    }
  }

  static Color _getTooltipColor(LineBarSpot _) => Colors.blueGrey.withOpacity(0.8);

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ],
      ),
    );
  }
}
