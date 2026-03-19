import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProgressCard {
  final String title;
  final String subtitle;
  final double progress;
  final Color color;

  ProgressCard(this.title, this.subtitle, this.progress, this.color);
}

class ContinueLearningWidget extends StatelessWidget {
  ContinueLearningWidget({super.key});

  final List<ProgressCard> items = [
    ProgressCard('Aptitude Practice', 'Quantitative Data', 0.65, const Color(0xFF4F46E5)),
    ProgressCard('Technical Quiz', 'Java OOPs', 0.30, const Color(0xFF10b981)),
    ProgressCard('Interview Prep', 'Software Engineering', 0.85, const Color(0xFF0ea5e9)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continue Learning',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.play_arrow_rounded, color: item.color, size: 18),
                        ),
                      ],
                    ),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${(item.progress * 100).toInt()}%',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: item.color),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.progress,
                            backgroundColor: item.color.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(item.color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (400 + index * 100).ms).slideX(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }
}
