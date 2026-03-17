import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
                  const SizedBox(height: 40),
                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 40),
                    ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome Back 👋',
                    style: GoogleFonts.sora(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue your placement journey',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 36),

                  // Email field
                  _buildField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                    v!.contains('@') ? null : 'Enter a valid email',
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                  const SizedBox(height: 16),

                  // Password field
                  _buildField(
                    controller: _passCtrl,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) =>
                    v!.length >= 6 ? null : 'Min 6 characters',
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
                  const SizedBox(height: 8),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotDialog(context, vm),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.sora(
                          color: AppTheme.accentCyan,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'Login',
                      isLoading: state.isLoading,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          final error = await vm.signInWithEmail(
                            email: _emailCtrl.text.trim(),
                            password: _passCtrl.text,
                          );
                          if (error != null && mounted) {
                            _showError(error);
                          } else if (mounted) {
                            context.go('/home');
                          }
                        }
                      },
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: GoogleFonts.sora(color: Colors.white38, fontSize: 12),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Sign In
                  SizedBox(
                    width: double.infinity,
                    child: _GoogleButton(
                      onTap: () async {
                        final error = await vm.signInWithGoogle();
                        if (error != null && mounted) {
                          _showError(error);
                        } else if (mounted) {
                          context.go('/home');
                        }
                      },
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(height: 32),

                  // Register link
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/register'),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: GoogleFonts.sora(color: Colors.white54),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
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
    );
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

  void _showForgotDialog(BuildContext ctx, AuthViewModelNotifier vm) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text('Reset Password', style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: GoogleFonts.sora(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await vm.resetPassword(ctrl.text.trim());
              if (c.mounted) Navigator.pop(c);
              _showError('Reset email sent!');
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G icon (simplified)
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'G',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}