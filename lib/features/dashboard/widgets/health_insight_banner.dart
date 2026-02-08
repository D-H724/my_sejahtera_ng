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
                          handleBuiltInTouches: true, // We still want tooltips
                            touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                              if (event is FlTapUpEvent && touchResponse != null && touchResponse.lineBarSpots != null) {
                                final spotIndex = touchResponse.lineBarSpots!.first.spotIndex;
                                _showDailyDetails(context, spotIndex);
                              }
                            },
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: _getTooltipColor,
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              tooltipPadding: const EdgeInsets.all(8),
                              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  // String guidance = _getGuidance(barSpot.x.toInt()); // Moved to modal
                                  return LineTooltipItem(
                                    'Score: ${barSpot.y.toInt()}',
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

  void _showDailyDetails(BuildContext context, int dayIndex) {
    // Mock Data for demonstration
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[dayIndex];
    final score = [3, 4, 3.5, 5, 4.5, 6, 6.5][dayIndex];
    
    // Mock specific stats based on score
    final steps = (score * 1500).toInt(); 
    final sleep = "${(score + 4).toInt()}h 30m";
    final bpm = 60 + (score * 2).toInt();
    final guidance = _getGuidance(dayIndex);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
             const SizedBox(height: 20),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(dayName, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                   decoration: BoxDecoration(color: AppThemes.getPrimaryColor(ref.read(themeProvider)).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                   child: Text("Score: $score", style: TextStyle(color: AppThemes.getPrimaryColor(ref.read(themeProvider)), fontWeight: FontWeight.bold)),
                 )
               ],
             ),
             const SizedBox(height: 10),
             Text(guidance, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
             const SizedBox(height: 24),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 _buildDetailCard(LucideIcons.footprints, "$steps", "Steps", Colors.orange),
                 _buildDetailCard(LucideIcons.moon, sleep, "Sleep", Colors.purple),
                 _buildDetailCard(LucideIcons.activity, "$bpm bpm", "Heart Rate", Colors.red),
               ],
             ),
             const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String value, String label, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
        ],
      ),
    );
  }

  String _getGuidance(int dayIndex) {
    switch (dayIndex) {
      case 0: return "Start the week strong! A bit more walking needed.";
      case 1: return "Good effort. Try to get to bed earlier.";
      case 2: return "Mid-week slump? Hydrate and stretch.";
      case 3: return "Great momentum! Keep it up.";
      case 4: return "Fri-yay! Watch the sodium intake.";
      case 5: return "Solid weekend activity. Cardio looking good.";
      case 6: return "Perfect Sunday recovery. You're ready for next week!";
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
