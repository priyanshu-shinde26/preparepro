import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../viewmodels/interview_viewmodel.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({super.key});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final _jobRoleCtrl = TextEditingController();
  String _selectedType = AppConstants.interviewTypes[1]; // Technical
  bool _generated = false;

  @override
  void dispose() {
    _jobRoleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewProvider);
    final notifier = ref.read(interviewProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Preparation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (_generated) {
              setState(() => _generated = false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: !_generated
          ? _InputView(
        jobRoleCtrl: _jobRoleCtrl,
        selectedType: _selectedType,
        onTypeChanged: (v) => setState(() => _selectedType = v),
        isLoading: state.isLoading,
        onGenerate: () async {
          if (_jobRoleCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a job role')),
            );
            return;
          }
          await notifier.generate(
            jobRole: _jobRoleCtrl.text.trim(),
            interviewType: _selectedType,
          );
          if (state.error == null && mounted) {
            setState(() => _generated = true);
          }
        },
      )
          : state.isLoading
          ? const LoadingWidget(message: 'Generating interview questions...')
          : state.error != null
          ? AppErrorWidget(message: state.error!, onRetry: () {
        notifier.generate(
          jobRole: _jobRoleCtrl.text.trim(),
          interviewType: _selectedType,
        );
      })
          : _QuestionView(state: state, notifier: notifier),
    );
  }
}

class _InputView extends StatelessWidget {
  final TextEditingController jobRoleCtrl;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final bool isLoading;
  final VoidCallback onGenerate;

  const _InputView({
    required this.jobRoleCtrl,
    required this.selectedType,
    required this.onTypeChanged,
    required this.isLoading,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero illustration
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.cardGradients[1]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(Icons.record_voice_over_rounded, size: 52, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  'AI Interview Coach',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Get 10 tailored questions with expert tips for your dream role',
                  style: GoogleFonts.sora(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.2),

          const SizedBox(height: 32),

          Text('Job Role', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15, color: cs.onBackground)),
          const SizedBox(height: 8),
          TextField(
            controller: jobRoleCtrl,
            decoration: InputDecoration(
              hintText: 'e.g., Software Engineer, Data Analyst',
              hintStyle: GoogleFonts.sora(color: cs.onSurface.withOpacity(0.4)),
              prefixIcon: Icon(Icons.work_outline_rounded, color: cs.primary),
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),
          Text('Interview Type', style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 15, color: cs.onBackground)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.interviewTypes.map((type) {
              final selected = type == selectedType;
              return GestureDetector(
                onTap: () => onTypeChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(colors: [AppTheme.primaryPurple, Color(0xFFEC4899)])
                        : null,
                    color: selected ? null : cs.surface,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: selected ? Colors.transparent : cs.outline.withOpacity(0.3),
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: AppTheme.primaryPurple.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
                        : null,
                  ),
                  child: Text(
                    type,
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : cs.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: 'Generate Questions',
              icon: Icons.auto_awesome_rounded,
              isLoading: isLoading,
              onTap: onGenerate,
              gradient: AppTheme.cardGradients[1],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final InterviewState state;
  final InterviewNotifier notifier;

  const _QuestionView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final q = state.currentQuestion!;
    final cs = Theme.of(context).colorScheme;
    final total = state.questions.length;
    final current = state.currentIndex + 1;

    return Column(
      children: [
        // Header info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(bottom: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.jobRole} • ${state.interviewType}',
                style: GoogleFonts.sora(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Q $current/$total',
                style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
            ],
          ),
        ),

        // Swipeable question
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (d) {
              if (d.primaryVelocity! < -300) notifier.nextQuestion();
              if (d.primaryVelocity! > 300) notifier.previousQuestion();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Progress dots
                  SizedBox(
                    height: 8,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: total,
                      separatorBuilder: (_, __) => const SizedBox(width: 4),
                      itemBuilder: (_, i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: i == state.currentIndex ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == state.currentIndex ? cs.primary : cs.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Question card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppTheme.cardGradients[1]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              q.category,
                              style: GoogleFonts.sora(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          q.question,
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate(key: ValueKey(state.currentIndex)).fadeIn(duration: 300.ms).slideX(begin: 0.15),

                  const SizedBox(height: 20),

                  // Reveal Answer button
                  if (!state.answerRevealed)
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: 'Reveal Answer',
                        icon: Icons.visibility_rounded,
                        onTap: notifier.revealAnswer,
                        gradient: [AppTheme.accentGreen, const Color(0xFF059669)],
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                  // Answer + Tip
                  if (state.answerRevealed) ...[
                    _AnswerCard(answer: q.answer),
                    const SizedBox(height: 14),
                    _TipCard(tip: q.tip),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: notifier.hideAnswer,
                      child: Text('Hide Answer', style: GoogleFonts.sora(color: cs.outline)),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Navigation
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.currentIndex > 0 ? notifier.previousQuestion : null,
                          icon: const Icon(Icons.chevron_left_rounded),
                          label: const Text('Prev'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: state.currentIndex < total - 1 ? notifier.nextQuestion : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Swipe hint
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.swipe_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text('Swipe to navigate', style: GoogleFonts.sora(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String answer;
  const _AnswerCard({required this.answer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 18),
              const SizedBox(width: 8),
              Text('Model Answer', style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: AppTheme.accentGreen, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Text(answer, style: GoogleFonts.sora(fontSize: 14, height: 1.6, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: AppTheme.accentOrange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pro Tip', style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: AppTheme.accentOrange, fontSize: 13)),
                const SizedBox(height: 4),
                Text(tip, style: GoogleFonts.sora(fontSize: 13, height: 1.5, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2);
  }
}