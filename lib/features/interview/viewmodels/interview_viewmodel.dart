import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/interview_question_model.dart';
import '../../../services/api_service.dart';

class InterviewState {
  final List<InterviewQuestionModel> questions;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final bool answerRevealed;
  final String jobRole;
  final String interviewType;

  const InterviewState({
    this.questions = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
    this.answerRevealed = false,
    this.jobRole = '',
    this.interviewType = 'Technical Round',
  });

  InterviewState copyWith({
    List<InterviewQuestionModel>? questions,
    int? currentIndex,
    bool? isLoading,
    String? error,
    bool? answerRevealed,
    String? jobRole,
    String? interviewType,
  }) =>
      InterviewState(
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        answerRevealed: answerRevealed ?? this.answerRevealed,
        jobRole: jobRole ?? this.jobRole,
        interviewType: interviewType ?? this.interviewType,
      );

  InterviewQuestionModel? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;
}

class InterviewNotifier extends StateNotifier<InterviewState> {
  final ApiService _api;
  InterviewNotifier(this._api) : super(const InterviewState());

  Future<void> generate({required String jobRole, required String interviewType}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      jobRole: jobRole,
      interviewType: interviewType,
    );
    try {
      final raw = await _api.generateInterviewQuestions(
        jobRole: jobRole,
        interviewType: interviewType,
      );
      final questions = raw.map((j) => InterviewQuestionModel.fromJson(j)).toList();
      state = state.copyWith(
        questions: questions,
        isLoading: false,
        currentIndex: 0,
        answerRevealed: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void revealAnswer() => state = state.copyWith(answerRevealed: true);
  void hideAnswer() => state = state.copyWith(answerRevealed: false);

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        answerRevealed: false,
      );
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
        answerRevealed: false,
      );
    }
  }

  void goToQuestion(int index) {
    state = state.copyWith(currentIndex: index, answerRevealed: false);
  }
}

final interviewProvider =
StateNotifierProvider<InterviewNotifier, InterviewState>(
      (ref) => InterviewNotifier(ApiService()),
);