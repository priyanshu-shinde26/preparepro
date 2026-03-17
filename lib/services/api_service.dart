import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.backendBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));

  // Attach Firebase ID Token on every request
  Future<String?> _getIdToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<Options> _authOptions() async {
    final token = await _getIdToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ── Aptitude ──────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> generateAptitudeQuestions({
    required String topic,
    int count = 5,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.generateAptitudeEndpoint,
        data: {'topic': topic, 'count': count},
        options: await _authOptions(),
      );
      final List data = response.data['questions'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Technical Quiz ────────────────────────────────────────
  Future<List<Map<String, dynamic>>> generateQuiz({
    required String subject,
    required String subtopic,
    int count = 10,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.generateQuizEndpoint,
        data: {'subject': subject, 'subtopic': subtopic, 'count': count},
        options: await _authOptions(),
      );
      final List data = response.data['questions'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Interview Questions ───────────────────────────────────
  Future<List<Map<String, dynamic>>> generateInterviewQuestions({
    required String jobRole,
    required String interviewType,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.generateInterviewEndpoint,
        data: {'jobRole': jobRole, 'interviewType': interviewType},
        options: await _authOptions(),
      );
      final List data = response.data['questions'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Resume ────────────────────────────────────────────────
  Future<String> generateResume({
    required Map<String, dynamic> resumeData,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.generateResumeEndpoint,
        data: resumeData,
        options: await _authOptions(),
      );
      return response.data['resume'] ?? '';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Company Prep ──────────────────────────────────────────
  Future<Map<String, dynamic>> generateCompanyPrep({
    required String company,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.generateCompanyEndpoint,
        data: {'company': company, 'role': role},
        options: await _authOptions(),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return 'Connection timeout. Please check your internet.';
    if (e.type == DioExceptionType.receiveTimeout) return 'Server is taking too long. Try again.';
    if (e.response != null) return e.response?.data['error'] ?? 'Server error occurred.';
    return 'Network error. Please try again.';
  }
}