import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../viewmodels/aptitude_viewmodel.dart';

class AptitudeScreen extends ConsumerStatefulWidget {
  const AptitudeScreen({super.key});

  @override
  ConsumerState<AptitudeScreen> createState() => _AptitudeScreenState();
}

class _AptitudeScreenState extends ConsumerState<AptitudeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(aptitudeProvider.notifier).loadQuestions());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aptitudeProvider);
    final notifier = ref.read(aptitudeProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aptitude Practice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Score badge
          if (state.questions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${state.correctCount}/${state.questions.length}',
                style: GoogleFonts.sora(
                  color: AppTheme.accentGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Topic selector
          _TopicSelector(
            selectedTopic: state.selectedTopic,
            onChanged: notifier.changeTopic,
          ),

          Expanded(
            child: state.isLoading
                ? const LoadingWidget(message: 'Generating questions with AI...')
                : state.error != null
                ? AppErrorWidget(
              message: state.error!,
              onRetry: notifier.loadQuestions,
            )
                : state.questions.isEmpty
                ? const Center(child: Text('No questions found'))
                : _QuestionView(state: state, notifier: notifier),
          ),
        ],
      ),
    );
  }
}

class _TopicSelector extends StatelessWidget {
  final String selectedTopic;
  final ValueChanged<String> onChanged;

  const _TopicSelector({required this.selectedTopic, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: AptitudeNotifier.topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final topic = AptitudeNotifier.topics[i];
          final selected = topic == selectedTopic;
          return GestureDetector(
            onTap: () => onChanged(topic),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryPurple])
                    : null,
                color: selected ? null : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.transparent : Theme.of(context).dividerColor,
                ),
              ),
              child: Text(
                topic,
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final AptitudeState state;
  final AptitudeNotifier notifier;

  const _QuestionView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final q = state.currentQuestion!;
    final cs = Theme.of(context).colorScheme;
    final total = state.questions.length;
    final current = state.currentIndex + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Text(
                'Q $current of $total',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: current / total,
                    backgroundColor: cs.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppTheme.cardGradients[0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    q.topic,
                    style: GoogleFonts.sora(color: Colors.white70, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  q.question,
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

          const SizedBox(height: 24),

          // Options
          ...List.generate(q.options.length, (i) {
            return _OptionTile(
              option: q.options[i],
              index: i,
              selectedIndex: state.selectedOption,
              correctIndex: q.correctIndex,
              answered: state.answered,
              onTap: () => notifier.selectOption(i),
              animDelay: 100 + i * 80,
            );
          }),

          // Explanation (shown after answering)
          if (state.answered) ...[
            const SizedBox(height: 20),
            _ExplanationCard(explanation: q.explanation),
          ],

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.currentIndex > 0 ? notifier.previousQuestion : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Prev'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.currentIndex < total - 1
                      ? notifier.nextQuestion
                      : () => notifier.loadQuestions(),
                  icon: Icon(
                    state.currentIndex < total - 1
                        ? Icons.chevron_right_rounded
                        : Icons.refresh_rounded,
                  ),
                  label: Text(
                    state.currentIndex < total - 1 ? 'Next' : 'New Set',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final int index, animDelay;
  final int? selectedIndex;
  final int correctIndex;
  final bool answered;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.answered,
    required this.onTap,
    required this.animDelay,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color? bg;
    Color? border;
    Color? textColor;

    if (answered) {
      if (index == correctIndex) {
        bg = AppTheme.accentGreen.withOpacity(0.15);
        border = AppTheme.accentGreen;
        textColor = AppTheme.accentGreen;
      } else if (index == selectedIndex) {
        bg = AppTheme.accentRed.withOpacity(0.12);
        border = AppTheme.accentRed;
        textColor = AppTheme.accentRed;
      }
    }

    final labels = ['A', 'B', 'C', 'D'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: answered ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bg ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border ?? (isDark ? const Color(0xFF334155) : Colors.grey.shade200),
              width: answered && (index == correctIndex || index == selectedIndex) ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (bg ?? cs.primary.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w700,
                    color: textColor ?? cs.primary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? cs.onSurface,
                  ),
                ),
              ),
              if (answered && index == correctIndex)
                const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 20),
              if (answered && index == selectedIndex && index != correctIndex)
                const Icon(Icons.cancel_rounded, color: AppTheme.accentRed, size: 20),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: animDelay)).slideX(begin: 0.2),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final String explanation;
  const _ExplanationCard({required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppTheme.accentCyan, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explanation',
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentCyan,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }
}