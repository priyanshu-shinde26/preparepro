import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/question_model.dart';
import '../../../services/api_service.dart';
import '../../../services/firestore_service.dart';

class AptitudeState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final int? selectedOption;
  final bool answered;
  final int correctCount;
  final String selectedTopic;

  const AptitudeState({
    this.questions = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
    this.selectedOption,
    this.answered = false,
    this.correctCount = 0,
    this.selectedTopic = 'General Aptitude',
  });

  AptitudeState copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    bool? isLoading,
    String? error,
    int? selectedOption,
    bool? answered,
    int? correctCount,
    String? selectedTopic,
  }) =>
      AptitudeState(
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        selectedOption: selectedOption ?? this.selectedOption,
        answered: answered ?? this.answered,
        correctCount: correctCount ?? this.correctCount,
        selectedTopic: selectedTopic ?? this.selectedTopic,
      );

  QuestionModel? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;
}

class AptitudeNotifier extends StateNotifier<AptitudeState> {
  final ApiService _api;
  final FirestoreService _firestore;

  AptitudeNotifier(this._api, this._firestore) : super(const AptitudeState());

  static const List<String> topics = [
    'General Aptitude',
    'Quantitative Aptitude',
    'Logical Reasoning',
    'Verbal Ability',
    'Data Interpretation',
    'Number Series',
    'Probability',
    'Time & Work',
    'Speed & Distance',
  ];

  Future<void> loadQuestions({String? topic}) async {
    final t = topic ?? state.selectedTopic;
    state = state.copyWith(isLoading: true, error: null, selectedTopic: t);
    try {
      final raw = await _api.generateAptitudeQuestions(topic: t, count: 10);
      final questions = raw.map((j) => QuestionModel.fromJson(j)).toList();
      state = state.copyWith(
        questions: questions,
        isLoading: false,
        currentIndex: 0,
        selectedOption: null,
        answered: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectOption(int index) {
    if (state.answered) return;
    final isCorrect = index == state.currentQuestion?.correctIndex;
    state = state.copyWith(
      selectedOption: index,
      answered: true,
      correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
    );
    // Save to Firestore
    _firestore.saveAptitudeResult(
      isCorrect: isCorrect,
      topic: state.selectedTopic,
    );
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        selectedOption: null,
        answered: false,
      );
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
        selectedOption: null,
        answered: false,
      );
    }
  }

  void changeTopic(String topic) {
    state = state.copyWith(selectedTopic: topic);
    loadQuestions(topic: topic);
  }
}

final aptitudeProvider =
StateNotifierProvider<AptitudeNotifier, AptitudeState>((ref) {
  return AptitudeNotifier(ApiService(), FirestoreService());
});