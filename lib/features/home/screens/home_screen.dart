import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../widgets/gradient_card.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _firestoreService = FirestoreService();
  final _apiService = ApiService();
  bool _serverReady = false;
  bool _serverPinging = true;

  @override
  void initState() {
    super.initState();
    _wakeUpServer();
  }

  Future<void> _wakeUpServer() async {
    setState(() => _serverPinging = true);
    final ok = await _apiService.pingServer();
    if (mounted) {
      setState(() {
        _serverReady = ok;
        _serverPinging = false;
      });
    }
  }

  final List<_FeatureItem> _features = [
    _FeatureItem(
      title: 'Aptitude\nPractice',
      subtitle: 'Sharpen problem-solving',
      icon: Icons.calculate_rounded,
      gradient: AppTheme.cardGradients[0],
      route: '/aptitude',
    ),
    _FeatureItem(
      title: 'Interview\nPrep',
      subtitle: 'AI-generated Q&A',
      icon: Icons.record_voice_over_rounded,
      gradient: AppTheme.cardGradients[1],
      route: '/interview',
    ),
    _FeatureItem(
      title: 'Technical\nQuiz',
      subtitle: 'Timed coding tests',
      icon: Icons.code_rounded,
      gradient: AppTheme.cardGradients[2],
      route: '/quiz',
    ),
    _FeatureItem(
      title: 'Resume\nBuilder',
      subtitle: 'ATS-optimized resume',
      icon: Icons.description_rounded,
      gradient: AppTheme.cardGradients[3],
      route: '/resume',
    ),
    _FeatureItem(
      title: 'Company\nPrep',
      subtitle: 'Company-specific guide',
      icon: Icons.business_rounded,
      gradient: AppTheme.cardGradients[4],
      route: '/company',
    ),
    _FeatureItem(
      title: 'Progress\nTracking',
      subtitle: 'Charts & analytics',
      icon: Icons.bar_chart_rounded,
      gradient: AppTheme.cardGradients[5],
      route: '/progress',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final themeNotifier = ref.watch(themeModeProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: cs.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                        : [AppTheme.primaryBlue, AppTheme.primaryPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Avatar + Greeting
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white24,
                                  backgroundImage: user?.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : null,
                                  child: user?.photoURL == null
                                      ? Text(
                                    (user?.displayName ?? 'U')[0].toUpperCase(),
                                    style: GoogleFonts.sora(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _greeting(),
                                      style: GoogleFonts.sora(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      user?.displayName ?? 'Learner',
                                      style: GoogleFonts.sora(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Theme toggle
                                IconButton(
                                  icon: Icon(
                                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: themeNotifier.toggleTheme,
                                ),
                                // Logout
                                IconButton(
                                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                                  onPressed: () async {
                                    await ref.read(authServiceProvider).signOut();
                                    if (context.mounted) context.go('/login');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ready to crack\nyour placement? 💪',
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Server status banner
                  if (_serverPinging)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Waking up AI server... first load takes ~30 sec',
                              style: GoogleFonts.sora(fontSize: 12, color: AppTheme.accentOrange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!_serverPinging && !_serverReady)
                    GestureDetector(
                      onTap: _wakeUpServer,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentRed.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_rounded, color: AppTheme.accentRed, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Backend offline. Tap to retry.',
                                style: GoogleFonts.sora(fontSize: 12, color: AppTheme.accentRed),
                              ),
                            ),
                            const Icon(Icons.refresh_rounded, color: AppTheme.accentRed, size: 16),
                          ],
                        ),
                      ),
                    ),
                  if (!_serverPinging && _serverReady)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 16),
                          const SizedBox(width: 10),
                          Text(
                            'AI server is ready!',
                            style: GoogleFonts.sora(fontSize: 12, color: AppTheme.accentGreen),
                          ),
                        ],
                      ),
                    ),
                  // Stats Row
                  _buildStatsRow(),
                  const SizedBox(height: 28),

                  // Daily Challenge Banner
                  _DailyChallengeBanner(
                    onTap: () => context.go('/quiz'),
                  ),
                  const SizedBox(height: 28),

                  // Section title
                  Text(
                    'Practice Modules',
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 4),
                  Text(
                    'AI-powered tools for complete placement prep',
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),

                  // Cards grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: _features.length,
                    itemBuilder: (context, i) {
                      final f = _features[i];
                      return GradientCard(
                        title: f.title,
                        subtitle: f.subtitle,
                        icon: f.icon,
                        gradient: f.gradient,
                        onTap: () => context.go(f.route),
                        index: i,
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom FAB
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'leaderboard',
            mini: true,
            onPressed: () => context.go('/leaderboard'),
            backgroundColor: AppTheme.accentOrange,
            foregroundColor: Colors.white,
            child: const Icon(Icons.leaderboard_rounded),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'bookmarks',
            mini: true,
            onPressed: () => context.go('/bookmarks'),
            backgroundColor: AppTheme.primaryPurple,
            foregroundColor: Colors.white,
            child: const Icon(Icons.bookmark_rounded),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'progress',
            onPressed: () => context.go('/progress'),
            icon: const Icon(Icons.insights_rounded),
            label: Text('My Progress', style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _firestoreService.getUserStats(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final quizzes = data['totalQuizzesTaken'] ?? 0;
        final aptitude = data['totalAptitudeSolved'] ?? 0;
        final streak = data['streak'] ?? 0;

        return Row(
          children: [
            _StatChip(label: 'Quizzes', value: '$quizzes', icon: Icons.quiz_rounded, color: AppTheme.primaryBlue),
            const SizedBox(width: 10),
            _StatChip(label: 'Aptitude', value: '$aptitude', icon: Icons.calculate_rounded, color: AppTheme.primaryPurple),
            const SizedBox(width: 10),
            _StatChip(label: 'Streak', value: '${streak}d', icon: Icons.local_fire_department_rounded, color: AppTheme.accentOrange),
          ],
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3);
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.sora(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.sora(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChallengeBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _DailyChallengeBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daily Challenge 🔥",
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Complete today's quiz to maintain your streak!",
                    style: GoogleFonts.sora(color: Colors.white.withOpacity(0.85), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
          ],
        ),
      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
    );
  }
}

class _FeatureItem {
  final String title, subtitle, route;
  final IconData icon;
  final List<Color> gradient;
  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.route,
  });
}