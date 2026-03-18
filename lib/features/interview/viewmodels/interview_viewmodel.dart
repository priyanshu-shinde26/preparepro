import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/interview_question_model.dart';
import '../../../services/api_service.dart';
import '../../../services/rtdb_service.dart';

class InterviewState {
  final List<InterviewQuestionModel> questions;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final bool answerRevealed;
  final String jobRole;
  final String interviewType;
  final int masteredCount;

  const InterviewState({
    this.questions = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
    this.answerRevealed = false,
    this.jobRole = '',
    this.interviewType = 'Technical Round',
    this.masteredCount = 0,
  });

  InterviewState copyWith({
    List<InterviewQuestionModel>? questions,
    int? currentIndex,
    bool? isLoading,
    String? error,
    bool? answerRevealed,
    String? jobRole,
    String? interviewType,
    int? masteredCount,
  }) =>
      InterviewState(
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        answerRevealed: answerRevealed ?? this.answerRevealed,
        jobRole: jobRole ?? this.jobRole,
        interviewType: interviewType ?? this.interviewType,
        masteredCount: masteredCount ?? this.masteredCount,
      );

  InterviewQuestionModel? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;
}

class InterviewNotifier extends StateNotifier<InterviewState> {
  final ApiService _api;
  final RTDBService _rtdb;
  InterviewNotifier(this._api, this._rtdb) : super(const InterviewState());

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
        masteredCount: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void revealAnswer() => state = state.copyWith(answerRevealed: true);
  void hideAnswer() => state = state.copyWith(answerRevealed: false);

  void nextQuestion() {
    int newMastered = state.masteredCount;
    if (!state.answerRevealed) {
      newMastered++;
    }

    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        answerRevealed: false,
        masteredCount: newMastered,
      );
    } else {
      // Reached the end
      state = state.copyWith(masteredCount: newMastered);
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
  @override
  void dispose() {
    if (state.masteredCount > 0) {
      _rtdb.saveInterviewProgress(state.masteredCount);
    }
    super.dispose();
  }
}

final interviewProvider = StateNotifierProvider.autoDispose<InterviewNotifier, InterviewState>(
      (ref) => InterviewNotifier(ApiService(), RTDBService()),
);