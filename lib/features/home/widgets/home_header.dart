import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../services/auth_service.dart';

class HomeHeader extends ConsumerWidget {
  final User? user;
  final int streak;
  const HomeHeader({super.key, required this.user, required this.streak});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFF1F5F9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()},',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: cs.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                    const SizedBox(height: 4),
                    Text(
                      user?.displayName ?? 'Learner',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '$streak',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: cs.onSurface.withOpacity(0.7),
                      size: 22,
                    ),
                    onPressed: ref.read(themeModeProvider.notifier).toggleTheme,
                  ),
                  IconButton(
                    icon: Icon(Icons.logout_rounded, color: cs.onSurface.withOpacity(0.7), size: 22),
                    onPressed: () async {
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) context.replace('/login');
                    },
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: cs.primary.withOpacity(0.1),
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? Text(
                            (user?.displayName ?? 'U')[0].toUpperCase(),
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: cs.primary),
                          )
                        : null,
                  ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ready to crack placements today? 🚀',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: cs.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}
