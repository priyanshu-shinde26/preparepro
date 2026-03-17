import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../viewmodels/quiz_viewmodel.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _customTopicCtrl = TextEditingController();

  @override
  void dispose() {
    _customTopicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final notifier = ref.read(quizProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technical Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            notifier.reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: switch (state.phase) {
        QuizPhase.setup => _SetupView(notifier: notifier, customCtrl: _customTopicCtrl),
        QuizPhase.loading => const LoadingWidget(message: 'Generating quiz with AI...'),
        QuizPhase.inProgress => _QuizView(state: state, notifier: notifier),
        QuizPhase.result => _ResultView(state: state, onRetry: notifier.reset),
      },
    );
  }
}

// ── Setup ─────────────────────────────────────────────────────────────────────
class _SetupView extends ConsumerWidget {
  final QuizNotifier notifier;
  final TextEditingController customCtrl;

  const _SetupView({required this.notifier, required this.customCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizProvider);
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.cardGradients[2]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.code_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Technical Quiz', style: GoogleFonts.sora(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('45 sec/question • AI-generated', style: GoogleFonts.sora(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.2),

          if (state.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.accentRed.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(state.error!, style: GoogleFonts.sora(color: AppTheme.accentRed, fontSize: 13)),
            ),
          ],

          const SizedBox(height: 28),
          Text('Select Subject', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.subjects.map((s) {
              final selected = s == state.subject;
              return GestureDetector(
                onTap: () => notifier.selectSubject(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(colors: [AppTheme.accentCyan, AppTheme.primaryBlue])
                        : null,
                    color: selected ? null : cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? Colors.transparent : cs.outline.withOpacity(0.3)),
                    boxShadow: selected ? [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.3), blurRadius: 8)] : null,
                  ),
                  child: Text(
                    s,
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : cs.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 100.ms),

          if (state.subject.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Select Subtopic', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (AppConstants.subtopics[state.subject] ?? []).map((st) {
                final selected = st == state.subtopic;
                return GestureDetector(
                  onTap: () => notifier.selectSubtopic(st),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryBlue.withOpacity(0.15) : cs.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppTheme.primaryBlue : cs.outline.withOpacity(0.3)),
                    ),
                    child: Text(
                      st,
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppTheme.primaryBlue : cs.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 150.ms),
          ],

          const SizedBox(height: 24),
          Text('Or Enter Custom Topic', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: customCtrl,
            onChanged: notifier.setCustomTopic,
            decoration: const InputDecoration(
              hintText: 'e.g., Binary Trees, REST APIs...',
              prefixIcon: Icon(Icons.edit_rounded),
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: 'Start Quiz',
              icon: Icons.play_arrow_rounded,
              onTap: () {
                if (state.subject.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a subject')),
                  );
                  return;
                }
                if (state.subtopic.isEmpty && state.customTopic.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select or enter a topic')),
                  );
                  return;
                }
                notifier.startQuiz();
              },
              gradient: AppTheme.cardGradients[2],
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── In Progress ───────────────────────────────────────────────────────────────
class _QuizView extends StatefulWidget {
  final QuizState state;
  final QuizNotifier notifier;

  const _QuizView({required this.state, required this.notifier});

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> {
  int? _localSelected;

  @override
  void didUpdateWidget(_QuizView old) {
    super.didUpdateWidget(old);
    if (old.state.currentIndex != widget.state.currentIndex) {
      setState(() => _localSelected = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final q = state.currentQuestion!;
    final cs = Theme.of(context).colorScheme;
    final total = state.questions.length;
    final current = state.currentIndex + 1;
    final timerPct = state.timerSeconds / AppConstants.quizTimerSeconds;
    final timerColor = timerPct > 0.5 ? AppTheme.accentGreen : timerPct > 0.25 ? AppTheme.accentOrange : AppTheme.accentRed;
    final submitted = _localSelected != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress + timer row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Q $current of $total', style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: cs.primary)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: current / total,
                        backgroundColor: cs.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Timer circle
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: timerPct,
                      strokeWidth: 4,
                      backgroundColor: cs.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                    ),
                    Text(
                      '${state.timerSeconds}',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: timerColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.cardGradients[2]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Text(
              q.question,
              style: GoogleFonts.sora(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.5),
            ),
          ).animate(key: ValueKey(state.currentIndex)).fadeIn(duration: 300.ms).slideY(begin: 0.2),

          const SizedBox(height: 20),

          // Options
          ...List.generate(q.options.length, (i) {
            Color? bg;
            Color? border;
            Color? textColor;
            if (submitted) {
              if (i == q.correctIndex) {
                bg = AppTheme.accentGreen.withOpacity(0.15);
                border = AppTheme.accentGreen;
                textColor = AppTheme.accentGreen;
              } else if (i == _localSelected) {
                bg = AppTheme.accentRed.withOpacity(0.12);
                border = AppTheme.accentRed;
                textColor = AppTheme.accentRed;
              }
            }
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final labels = ['A', 'B', 'C', 'D'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: submitted
                    ? null
                    : () {
                  setState(() => _localSelected = i);
                  widget.notifier.submitAnswer(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bg ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: border ?? (isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                      width: submitted && (i == q.correctIndex || i == _localSelected) ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: (bg ?? cs.primary.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(labels[i], style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: textColor ?? cs.primary, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q.options[i],
                          style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w500, color: textColor ?? cs.onSurface),
                        ),
                      ),
                      if (submitted && i == q.correctIndex) const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 20),
                      if (submitted && i == _localSelected && i != q.correctIndex) const Icon(Icons.cancel_rounded, color: AppTheme.accentRed, size: 20),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 80 * i)).slideX(begin: 0.1),
              ),
            );
          }),

          if (submitted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: AppTheme.accentCyan, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(q.explanation, style: GoogleFonts.sora(fontSize: 12, height: 1.5, color: cs.onSurface)),
                  ),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.notifier.state.currentIndex < widget.state.questions.length - 1) {
                    setState(() => _localSelected = null);
                    widget.notifier.submitAnswer(-99); // Won't match correct; just move forward
                  }
                },
                child: const Text('Next Question'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Result ────────────────────────────────────────────────────────────────────
class _ResultView extends StatelessWidget {
  final QuizState state;
  final VoidCallback onRetry;

  const _ResultView({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = state.scorePercent;
    final grade = pct >= 0.8 ? '🏆 Excellent!' : pct >= 0.6 ? '👍 Good Job!' : pct >= 0.4 ? '📚 Keep Practicing' : '💪 Need More Practice';
    final gradeColor = pct >= 0.8 ? AppTheme.accentGreen : pct >= 0.6 ? AppTheme.accentCyan : pct >= 0.4 ? AppTheme.accentOrange : AppTheme.accentRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Score circle
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 12,
                    backgroundColor: cs.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${state.score}/${state.questions.length}',
                      style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, color: gradeColor),
                    ),
                    Text(
                      '${(pct * 100).round()}%',
                      style: GoogleFonts.sora(fontSize: 14, color: cs.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),

          const SizedBox(height: 20),
          Text(grade, style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: gradeColor))
              .animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          Text(
            '${state.subject} • ${state.subtopic.isNotEmpty ? state.subtopic : state.customTopic}',
            style: GoogleFonts.sora(fontSize: 13, color: cs.onSurface.withOpacity(0.55)),
          ),

          const SizedBox(height: 32),
          // Stats row
          Row(
            children: [
              _ResultStat(label: 'Correct', value: '${state.score}', color: AppTheme.accentGreen, icon: Icons.check_circle_outline_rounded),
              const SizedBox(width: 12),
              _ResultStat(
                label: 'Wrong',
                value: '${state.questions.length - state.score}',
                color: AppTheme.accentRed,
                icon: Icons.cancel_outlined,
              ),
              const SizedBox(width: 12),
              _ResultStat(
                label: 'Timed Out',
                value: '${state.answers.where((a) => a.timedOut).length}',
                color: AppTheme.accentOrange,
                icon: Icons.timer_off_rounded,
              ),
            ],
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: 'Try Another Quiz',
              icon: Icons.refresh_rounded,
              onTap: onRetry,
              gradient: AppTheme.cardGradients[2],
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: 'View Progress',
              icon: Icons.bar_chart_rounded,
              onTap: () => context.go('/progress'),
              outlined: true,
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _ResultStat({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 20, color: color)),
            Text(label, style: GoogleFonts.sora(fontSize: 11, color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}