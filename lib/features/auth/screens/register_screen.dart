import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(authViewModelProvider.notifier);
    final state = ref.watch(authViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
                    onPressed: () => context.go('/login'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Account 🚀',
                    style: GoogleFonts.sora(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                  const SizedBox(height: 8),
                  Text(
                    'Start your AI-powered placement prep today',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),

                  _buildField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    delay: 300,
                    validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    delay: 400,
                    validator: (v) => v!.contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _passCtrl,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    delay: 500,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) => v!.length >= 6 ? null : 'Min 6 characters',
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _confirmCtrl,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscureConfirm,
                    delay: 600,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) => v == _passCtrl.text ? null : 'Passwords do not match',
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'Create Account',
                      isLoading: state.isLoading,
                      icon: Icons.arrow_forward_rounded,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          final error = await vm.signUpWithEmail(
                            email: _emailCtrl.text.trim(),
                            password: _passCtrl.text,
                            name: _nameCtrl.text.trim(),
                          );
                          if (error != null && mounted) {
                            _showError(error);
                          } else if (mounted) {
                            context.go('/home');
                          }
                        }
                      },
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: GoogleFonts.sora(color: Colors.white54),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: GoogleFonts.sora(
                                color: AppTheme.accentCyan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int delay = 0,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.sora(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.sora(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.accentRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.accentRed, width: 1.5),
        ),
        errorStyle: GoogleFonts.sora(color: AppTheme.accentRed, fontSize: 12),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.3);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.sora()),
        backgroundColor: AppTheme.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}