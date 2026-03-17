import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

class ResumeState {
  final bool isGenerating;
  final String? generatedResume;
  final String? error;
  final bool exported;

  const ResumeState({
    this.isGenerating = false,
    this.generatedResume,
    this.error,
    this.exported = false,
  });

  ResumeState copyWith({
    bool? isGenerating,
    String? generatedResume,
    String? error,
    bool? exported,
  }) =>
      ResumeState(
        isGenerating: isGenerating ?? this.isGenerating,
        generatedResume: generatedResume ?? this.generatedResume,
        error: error,
        exported: exported ?? this.exported,
      );
}

class ResumeNotifier extends StateNotifier<ResumeState> {
  final ApiService _api;
  ResumeNotifier(this._api) : super(const ResumeState());

  Future<void> generate({
    required String name,
    required String email,
    required String phone,
    required String skills,
    required String education,
    required String experience,
    required String projects,
    required String targetRole,
    required String targetCompany,
    required String summary,
  }) async {
    state = state.copyWith(isGenerating: true, error: null);
    try {
      final resume = await _api.generateResume(resumeData: {
        'name': name,
        'email': email,
        'phone': phone,
        'skills': skills,
        'education': education,
        'experience': experience,
        'projects': projects,
        'targetRole': targetRole,
        'targetCompany': targetCompany,
        'summary': summary,
      });
      state = state.copyWith(isGenerating: false, generatedResume: resume);
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
    }
  }

  void reset() => state = const ResumeState();
}

final resumeProvider = StateNotifierProvider<ResumeNotifier, ResumeState>(
      (ref) => ResumeNotifier(ApiService()),
);