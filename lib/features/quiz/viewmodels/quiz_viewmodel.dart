import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/question_model.dart';
import '../../../services/api_service.dart';
import '../../../services/firestore_service.dart';

enum QuizPhase { setup, loading, inProgress, result }

class QuizAnswer {
  final int questionIndex;
  final int? selectedOption;
  final bool isCorrect;
  final bool timedOut;
  QuizAnswer({required this.questionIndex, this.selectedOption, required this.isCorrect, this.timedOut = false});
}

class QuizState {
  final QuizPhase phase;
  final List<QuestionModel> questions;
  final int currentIndex;
  final List<QuizAnswer> answers;
  final String subject;
  final String subtopic;
  final String customTopic;
  final int timerSeconds;
  final String? error;

  const QuizState({
    this.phase = QuizPhase.setup,
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const [],
    this.subject = '',
    this.subtopic = '',
    this.customTopic = '',
    this.timerSeconds = AppConstants.quizTimerSeconds,
    this.error,
  });

  QuizState copyWith({
    QuizPhase? phase,
    List<QuestionModel>? questions,
    int? currentIndex,
    List<QuizAnswer>? answers,
    String? subject,
    String? subtopic,
    String? customTopic,
    int? timerSeconds,
    String? error,
  }) =>
      QuizState(
        phase: phase ?? this.phase,
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        answers: answers ?? this.answers,
        subject: subject ?? this.subject,
        subtopic: subtopic ?? this.subtopic,
        customTopic: customTopic ?? this.customTopic,
        timerSeconds: timerSeconds ?? this.timerSeconds,
        error: error,
      );

  QuestionModel? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  int get score => answers.where((a) => a.isCorrect).length;
  double get scorePercent => questions.isEmpty ? 0 : score / questions.length;
  bool get isComplete => currentIndex >= questions.length && questions.isNotEmpty;
}

class QuizNotifier extends StateNotifier<QuizState> {
  final ApiService _api;
  final FirestoreService _firestore;
  Timer? _timer;

  QuizNotifier(this._api, this._firestore) : super(const QuizState());

  void selectSubject(String s) => state = state.copyWith(subject: s, subtopic: '');
  void selectSubtopic(String s) => state = state.copyWith(subtopic: s);
  void setCustomTopic(String s) => state = state.copyWith(customTopic: s);

  Future<void> startQuiz() async {
    final topic = state.customTopic.isNotEmpty ? state.customTopic : state.subtopic;
    if (state.subject.isEmpty || topic.isEmpty) return;

    state = state.copyWith(phase: QuizPhase.loading, error: null);
    try {
      final raw = await _api.generateQuiz(
        subject: state.subject,
        subtopic: topic,
        count: AppConstants.questionsPerSession,
      );
      final questions = raw.map((j) => QuestionModel.fromJson(j)).toList();
      state = state.copyWith(
        phase: QuizPhase.inProgress,
        questions: questions,
        currentIndex: 0,
        answers: [],
        timerSeconds: AppConstants.quizTimerSeconds,
      );
      _startTimer();
    } catch (e) {
      state = state.copyWith(phase: QuizPhase.setup, error: e.toString());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(timerSeconds: AppConstants.quizTimerSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.timerSeconds <= 1) {
        _autoSubmit();
      } else {
        state = state.copyWith(timerSeconds: state.timerSeconds - 1);
      }
    });
  }

  void _autoSubmit() {
    _recordAnswer(null, timedOut: true);
  }

  void submitAnswer(int selectedIndex) {
    _timer?.cancel();
    _recordAnswer(selectedIndex);
  }

  void _recordAnswer(int? selectedIndex, {bool timedOut = false}) {
    final q = state.currentQuestion;
    if (q == null) return;

    final isCorrect = selectedIndex != null && selectedIndex == q.correctIndex;
    final answers = [...state.answers, QuizAnswer(
      questionIndex: state.currentIndex,
      selectedOption: selectedIndex,
      isCorrect: isCorrect,
      timedOut: timedOut,
    )];

    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      // Quiz complete
      state = state.copyWith(
        answers: answers,
        currentIndex: nextIndex,
        phase: QuizPhase.result,
      );
      _saveResult(answers);
    } else {
      state = state.copyWith(answers: answers, currentIndex: nextIndex);
      _startTimer();
    }
  }

  Future<void> _saveResult(List<QuizAnswer> answers) async {
    final answerMaps = answers.map((a) => {
      'questionIndex': a.questionIndex,
      'selectedOption': a.selectedOption,
      'isCorrect': a.isCorrect,
      'timedOut': a.timedOut,
    }).toList();

    await _firestore.saveQuizResult(
      subject: state.subject,
      subtopic: state.subtopic.isNotEmpty ? state.subtopic : state.customTopic,
      score: state.score,
      total: state.questions.length,
      answers: answerMaps,
    );
  }

  void reset() {
    _timer?.cancel();
    state = const QuizState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
      (ref) => QuizNotifier(ApiService(), FirestoreService()),
);