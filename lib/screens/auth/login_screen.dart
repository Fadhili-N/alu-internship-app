import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final user = await ref.read(authServiceProvider).getUserById(
            ref.read(authServiceProvider).currentUser!.uid,
          );

      if (!mounted) return;
      if (user == null) return;

      if (user.role == 'student') {
        Navigator.of(context).pushReplacementNamed('/student-home');
      } else if (user.role == 'startup_admin') {
        final startup = await ref
            .read(startupServiceProvider)
            .getStartupByAdminUid(user.uid);
        if (!mounted) return;
        if (startup == null) {
          Navigator.of(context).pushReplacementNamed('/startup-setup');
        } else {
          Navigator.of(context).pushReplacementNamed('/startup-home');
        }
      } else if (user.role == 'ventures_lab_admin') {
        Navigator.of(context).pushReplacementNamed('/admin-home');
      }
    } else {
      final error = ref.read(authNotifierProvider);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (Validators.validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email above first.')),
      );
      return;
    }
    try {
      await ref.read(authServiceProvider).sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: AppTheme.primaryRed,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.tagline,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGrey,
                      ),
                ),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(AppStrings.login),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: Text(
                      'Forgot password?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.noAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed('/register'),
                        child: Text(
                          AppStrings.signUp,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme.primaryRed,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}