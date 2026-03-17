import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.backendBaseUrl,
      // Long timeouts — Render free tier needs up to 50s to wake from sleep
      connectTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 120),
      sendTimeout:    const Duration(seconds: 90),
      headers: {
        'Content-Type': 'application/json',
        'Accept':       'application/json',
      },
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken(true);
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
        } catch (e) {
          print('Token fetch error (non-fatal): $e');
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('Dio error: ${error.type} — ${error.message}');
        handler.next(error);
      },
    ),
  );

  // ── Wake up Render server ─────────────────────────────────────────────────
  // Call this from HomeScreen initState so the server is warm before user acts
  Future<bool> pingServer() async {
    try {
      final response = await _dio.get(
        '/',
        options: Options(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout:    const Duration(seconds: 90),
        ),
      );
      print('Backend awake: ${response.data}');
      return true;
    } catch (e) {
      print('Backend ping failed: $e');
      return false;
    }
  }

  // ── Generic POST with auto-retry on timeout ───────────────────────────────
  Future<Response> _post(
      String path,
      Map<String, dynamic> data, {
        int retries = 2,
      }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        return await _dio.post(path, data: data);
      } on DioException catch (e) {
        final isTimeout = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout;

        // Retry on timeout (Render waking up)
        if (isTimeout && attempt < retries) {
          print('Timeout on attempt $attempt — retrying in 5 seconds...');
          await Future.delayed(const Duration(seconds: 5));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('All retry attempts failed.');
  }

  // ── Aptitude Questions ────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> generateAptitudeQuestions({
    required String topic,
    int count = 5,
  }) async {
    try {
      final response = await _post(
        AppConstants.generateAptitudeEndpoint,
        {'topic': topic, 'count': count},
      );
      final List data = response.data['questions'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ── Technical Quiz ────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> generateQuiz({
    required String subject,
    required String subtopic,
    int count = 10,
  }) async {
    try {
      final response = await _post(
        AppConstants.generateQuizEndpoint,
        {'subject': subject, 'subtopic': subtopic, 'count': count},
      );
      final List data = response.data['questions'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ── Interview Questions ───────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> generateInterviewQuestions({
    required String jobRole,
    required String interviewType,
  }) async {
    try {
      final response = await _post(
        AppConstants.generateInterviewEndpoint,
        {'jobRole': jobRole, 'interviewType': interviewType},
      );
      final List data = response.data['questions'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ── Resume ────────────────────────────────────────────────────────────────
  Future<String> generateResume({
    required Map<String, dynamic> resumeData,
  }) async {
    try {
      final response = await _post(
        AppConstants.generateResumeEndpoint,
        resumeData,
      );
      return response.data['resume'] ?? '';
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ── Company Prep ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> generateCompanyPrep({
    required String company,
    required String role,
  }) async {
    try {
      final response = await _post(
        AppConstants.generateCompanyEndpoint,
        {'company': company, 'role': role},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ── Error handler ─────────────────────────────────────────────────────────
  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return 'Server is waking up (takes ~30 sec on free plan).\n'
            'Please tap Retry in a moment.';

      case DioExceptionType.receiveTimeout:
        return 'AI is taking longer than usual.\n'
            'Please tap Retry.';

      case DioExceptionType.connectionError:
        return 'Cannot reach backend server.\n\n'
            'Please check:\n'
            '1. Your Render service is deployed\n'
            '2. The URL in app_constants.dart is correct\n'
            '3. Your internet connection\n\n'
            'Current URL: ${AppConstants.backendBaseUrl}';

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final msg = e.response?.data is Map
            ? e.response?.data['error'] ?? 'Unknown error'
            : e.response?.data?.toString() ?? 'Unknown error';

        if (status == 401) {
          return 'Session expired. Please log out and log in again.';
        }
        if (status == 403) {
          return 'Access denied. Please log in again.';
        }
        if (status == 500) {
          return 'Server error: $msg\n\nCheck Render logs for details.';
        }
        return 'Server error ($status): $msg';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      default:
        return 'Network error: ${e.message ?? "Unknown"}\n\n'
            'Make sure you are connected to the internet and '
            'your Render backend is running.';
    }
  }
}