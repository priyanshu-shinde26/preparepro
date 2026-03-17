import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/loading_widget.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Tracking')),
      body: _ProgressBody(),
    );
  }
}

class _ProgressBody extends StatefulWidget {
  @override
  State<_ProgressBody> createState() => _ProgressBodyState();
}

class _ProgressBodyState extends State<_ProgressBody> {
  final _firestoreService = FirestoreService();
  Map<String, dynamic> _userStats = {};
  Map<String, int> _subjectScores = {};
  Map<String, int> _aptitudeStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _firestoreService.getUserStats(),
        _firestoreService.getSubjectScores(),
        _firestoreService.getAptitudeStats(),
      ]);
      setState(() {
        _userStats = results[0] as Map<String, dynamic>;
        _subjectScores = results[1] as Map<String, int>;
        _aptitudeStats = results[2] as Map<String, int>;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget(message: 'Loading your progress...');

    final quizTotal = _userStats['totalQuizzesTaken'] ?? 0;
    final aptTotal = _userStats['totalAptitudeSolved'] ?? 0;
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                _SummaryCard(label: 'Quizzes\nTaken', value: '$quizTotal', icon: Icons.quiz_rounded, gradient: AppTheme.cardGradients[0]),
                const SizedBox(width: 12),
                _SummaryCard(label: 'Aptitude\nSolved', value: '$aptTotal', icon: Icons.calculate_rounded, gradient: AppTheme.cardGradients[1]),
                const SizedBox(width: 12),
                _SummaryCard(label: 'Subjects\nCovered', value: '${_subjectScores.length}', icon: Icons.book_rounded, gradient: AppTheme.cardGradients[2]),
              ],
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 28),

            // Subject performance bar chart
            if (_subjectScores.isNotEmpty) ...[
              _SectionHeader('Subject Performance', Icons.bar_chart_rounded),
              const SizedBox(height: 14),
              _SubjectBarChart(scores: _subjectScores),
              const SizedBox(height: 28),
            ],

            // Aptitude pie chart
            if (aptTotal > 0) ...[
              _SectionHeader('Aptitude Accuracy', Icons.pie_chart_rounded),
              const SizedBox(height: 14),
              _AptitudePieChart(stats: _aptitudeStats),
              const SizedBox(height: 28),
            ],

            // Subject score list
            if (_subjectScores.isNotEmpty) ...[
              _SectionHeader('Score Breakdown', Icons.list_alt_rounded),
              const SizedBox(height: 14),
              ..._subjectScores.entries.toList().asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                final pct = e.value;
                final color = pct >= 80 ? AppTheme.accentGreen : pct >= 60 ? AppTheme.accentCyan : pct >= 40 ? AppTheme.accentOrange : AppTheme.accentRed;
                return _ScoreRow(
                  subject: e.key,
                  percentage: pct,
                  color: color,
                  index: i,
                );
              }),
              const SizedBox(height: 28),
            ],

            // Empty state
            if (_subjectScores.isEmpty && aptTotal == 0)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Icon(Icons.bar_chart_rounded, size: 80, color: cs.onSurface.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'No data yet!',
                      style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take some quizzes to see your progress here.',
                      style: GoogleFonts.sora(fontSize: 13, color: cs.onSurface.withOpacity(0.35)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final List<Color> gradient;

  const _SummaryCard({required this.label, required this.value, required this.icon, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 10),
            Text(value, style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22)),
            Text(label, style: GoogleFonts.sora(color: Colors.white70, fontSize: 11, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: cs.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onBackground)),
      ],
    );
  }
}

class _SubjectBarChart extends StatelessWidget {
  final Map<String, int> scores;
  const _SubjectBarChart({required this.scores});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keys = scores.keys.toList();
    final values = scores.values.toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: BarChart(
        BarChartData(
          barGroups: List.generate(keys.length, (i) {
            final colors = AppTheme.cardGradients[i % AppTheme.cardGradients.length];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i].toDouble(),
                  gradient: LinearGradient(colors: colors, begin: Alignment.bottomCenter, end: Alignment.topCenter),
                  width: 20,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: GoogleFonts.sora(fontSize: 9, color: Colors.grey)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i >= keys.length) return const SizedBox.shrink();
                  final label = keys[i].length > 4 ? keys[i].substring(0, 4) : keys[i];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(label, style: GoogleFonts.sora(fontSize: 8, color: Colors.grey)),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
            drawVerticalLine: false,
          ),
          maxY: 100,
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }
}

class _AptitudePieChart extends StatelessWidget {
  final Map<String, int> stats;
  const _AptitudePieChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final correct = stats['correct'] ?? 0;
    final incorrect = stats['incorrect'] ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 44,
                sections: [
                  PieChartSectionData(
                    value: correct.toDouble(),
                    color: AppTheme.accentGreen,
                    title: '$correct',
                    radius: 52,
                    titleStyle: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  if (incorrect > 0)
                    PieChartSectionData(
                      value: incorrect.toDouble(),
                      color: AppTheme.accentRed,
                      title: '$incorrect',
                      radius: 44,
                      titleStyle: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendItem('Correct', AppTheme.accentGreen, '$correct'),
                const SizedBox(height: 10),
                _LegendItem('Incorrect', AppTheme.accentRed, '$incorrect'),
                const SizedBox(height: 10),
                Text(
                  'Accuracy: ${correct + incorrect == 0 ? 0 : (correct / (correct + incorrect) * 100).round()}%',
                  style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 13, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }
}

class _LegendItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _LegendItem(this.label, this.color, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: $value', style: GoogleFonts.sora(fontSize: 12, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String subject;
  final int percentage;
  final Color color;
  final int index;

  const _ScoreRow({required this.subject, required this.percentage, required this.color, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject, style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '$percentage%',
              style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 16, color: color),
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideX(begin: 0.1),
    );
  }
}