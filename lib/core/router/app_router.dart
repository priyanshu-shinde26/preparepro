import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/aptitude/screens/aptitude_screen.dart';
import '../../features/interview/screens/interview_screen.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/resume/screens/resume_screen.dart';
import '../../features/company/screens/company_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
//import '../../features/bookmarks/screens/bookmarks_screen.dart';
//import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isOnAuth) return '/login';
      if (isLoggedIn && state.matchedLocation == '/login') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/aptitude', builder: (_, __) => const AptitudeScreen()),
      GoRoute(path: '/interview', builder: (_, __) => const InterviewScreen()),
      GoRoute(path: '/quiz', builder: (_, __) => const QuizScreen()),
      GoRoute(path: '/resume', builder: (_, __) => const ResumeScreen()),
      GoRoute(path: '/company', builder: (_, __) => const CompanyScreen()),
      GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
      //GoRoute(path: '/bookmarks', builder: (_, __) => const BookmarksScreen()),
      //GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
    ],
  );
});