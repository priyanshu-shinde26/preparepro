import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';

class CompanyState {
  final bool isLoading;
  final Map<String, dynamic>? data;
  final String? error;
  final String company;
  final String role;

  const CompanyState({
    this.isLoading = false,
    this.data,
    this.error,
    this.company = '',
    this.role = '',
  });

  CompanyState copyWith({
    bool? isLoading,
    Map<String, dynamic>? data,
    String? error,
    String? company,
    String? role,
  }) =>
      CompanyState(
        isLoading: isLoading ?? this.isLoading,
        data: data ?? this.data,
        error: error,
        company: company ?? this.company,
        role: role ?? this.role,
      );
}

class CompanyNotifier extends StateNotifier<CompanyState> {
  final ApiService _api;
  CompanyNotifier(this._api) : super(const CompanyState());

  Future<void> generate({required String company, required String role}) async {
    state = state.copyWith(isLoading: true, error: null, company: company, role: role);
    try {
      final data = await _api.generateCompanyPrep(company: company, role: role);
      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const CompanyState();
}

final companyProvider = StateNotifierProvider<CompanyNotifier, CompanyState>(
      (ref) => CompanyNotifier(ApiService()),
);