import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final List<Color> gradient;

  const FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.gradient,
  });
}

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  static const List<FeatureItem> features = [
    FeatureItem(
      title: 'Aptitude Practice',
      subtitle: 'Sharpen logic skills',
      icon: Icons.calculate_outlined,
      route: '/aptitude',
      gradient: [Color(0xFF4F46E5), Color(0xFF6366F1)], // Indigo
    ),
    FeatureItem(
      title: 'Interview Prep',
      subtitle: 'AI mock questions',
      icon: Icons.mic_none_rounded,
      route: '/interview',
      gradient: [Color(0xFF0ea5e9), Color(0xFF38bdf8)], // Sky
    ),
    FeatureItem(
      title: 'Technical Quiz',
      subtitle: 'Coding MCQ tests',
      icon: Icons.code_rounded,
      route: '/quiz',
      gradient: [Color(0xFF10b981), Color(0xFF34d399)], // Emerald
    ),
    FeatureItem(
      title: 'Resume Builder',
      subtitle: 'ATS-friendly edits',
      icon: Icons.description_outlined,
      route: '/resume',
      gradient: [Color(0xFFf59e0b), Color(0xFFfbbf24)], // Amber
    ),
    FeatureItem(
      title: 'Company Prep',
      subtitle: 'Role-specific guide',
      icon: Icons.business_rounded,
      route: '/company',
      gradient: [Color(0xFFec4899), Color(0xFFf472b6)], // Pink
    ),
    FeatureItem(
      title: 'Progress\nTracking',
      subtitle: 'View analytics',
      icon: Icons.insights_rounded,
      route: '/progress',
      gradient: [Color(0xFF8b5cf6), Color(0xFFa78bfa)], // Violet
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 2 columns on mobile, 3 on tablet/desktop
        final int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final f = features[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push(f.route),
                borderRadius: BorderRadius.circular(20),
                splashColor: f.gradient.first.withOpacity(0.2),
                highlightColor: f.gradient.first.withOpacity(0.1),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: f.gradient.first.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: f.gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(f.icon, color: Colors.white, size: 24),
                        ),
                        const Spacer(),
                        Text(
                          f.title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          f.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (200 + index * 50).ms).slideY(begin: 0.2);
          },
        );
      },
    );
  }
}
