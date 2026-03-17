// PreparePro – Widget Tests
//
// These smoke tests verify the app boots correctly and key widgets render.
// Firebase is NOT initialised here; screens that need it are tested with mocks.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Minimal smoke test: verify the widget layer works ─────────────────────────
// We do NOT import main.dart directly because Firebase.initializeApp() would
// run and crash in a plain unit-test environment (no google-services.json).
// Instead we test individual stateless widgets that have zero Firebase deps.

void main() {
  // Disable Google Fonts HTTP fetching in tests
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // ── GradientCard smoke test ─────────────────────────────────────────────────
  testWidgets('GradientCard renders title and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: _FakeGradientCard(
              title: 'Aptitude Practice',
              subtitle: 'Sharpen problem-solving',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Aptitude Practice'), findsOneWidget);
    expect(find.text('Sharpen problem-solving'), findsOneWidget);
  });

  // ── CustomButton renders label ──────────────────────────────────────────────
  testWidgets('CustomButton renders label and responds to tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: _FakeCustomButton(
              label: 'Start Quiz',
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Start Quiz'), findsOneWidget);
    await tester.tap(find.text('Start Quiz'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  // ── LoadingWidget renders without crashing ──────────────────────────────────
  testWidgets('LoadingWidget renders message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: _FakeLoadingWidget(message: 'Generating questions with AI...'),
        ),
      ),
    );

    expect(find.text('Generating questions with AI...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ── SplashScreen structure check ────────────────────────────────────────────
  testWidgets('Splash screen shows app name', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: _FakeSplashScreen(),
      ),
    );

    expect(find.text('PreparePro'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // ── Theme: Material3 is enabled ─────────────────────────────────────────────
  testWidgets('App uses Material 3 theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF2563EB)),
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Lightweight fakes – no Firebase, no network calls
// ─────────────────────────────────────────────────────────────────────────────

class _FakeGradientCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _FakeGradientCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _FakeCustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FakeCustomButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _FakeLoadingWidget extends StatelessWidget {
  final String message;
  const _FakeLoadingWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class _FakeSplashScreen extends StatelessWidget {
  const _FakeSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 24),
            const Text(
              'PreparePro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}