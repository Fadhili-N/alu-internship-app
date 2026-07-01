import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _startupNameController = TextEditingController();
  final _startupDescController = TextEditingController();
  final _startupIndustryController = TextEditingController();

  String _selectedRole = 'student';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _startupNameController.dispose();
    _startupDescController.dispose();
    _startupIndustryController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(authNotifierProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          displayName: _nameController.text.trim(),
          role: _selectedRole,
        );

    if (!mounted) return;

    if (!success) {
      setState(() => _isLoading = false);
      final error = ref.read(authNotifierProvider);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
      return;
    }

    if (_selectedRole == 'startup_admin') {
      final user = await ref.read(authServiceProvider).getUserById(
            ref.read(authStateProvider).value!.uid,
          );

      if (!mounted) return;

      if (user != null) {
        await ref.read(startupNotifierProvider.notifier).createStartup(
              adminUid: user.uid,
              name: _startupNameController.text.trim(),
              description: _startupDescController.text.trim(),
              industry: _startupIndustryController.text.trim(),
            );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacementNamed('/startup-pending');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_selectedRole == 'student') {
      Navigator.of(context).pushReplacementNamed('/student-home');
    } else if (_selectedRole == 'ventures_lab_admin') {
      Navigator.of(context).pushReplacementNamed('/admin-home');
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
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushReplacementNamed('/login'),
                  child: const Icon(Icons.arrow_back,
                      color: AppTheme.textDark),
                ),

                const SizedBox(height: 24),

                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join the ALU startup ecosystem',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGrey,
                      ),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: _nameController,
                  validator: (v) =>
                      Validators.validateRequired(v, 'Full name'),
                  decoration: const InputDecoration(
                    labelText: AppStrings.fullName,
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                ),

                const SizedBox(height: 16),

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

                const SizedBox(height: 24),

                Text(
                  AppStrings.selectRole,
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _RoleCard(
                      label: 'Student',
                      icon: Icons.school_outlined,
                      isSelected: _selectedRole == 'student',
                      onTap: () => setState(() => _selectedRole = 'student'),
                    ),
                    const SizedBox(width: 12),
                    _RoleCard(
                      label: 'Startup',
                      icon: Icons.rocket_launch_outlined,
                      isSelected: _selectedRole == 'startup_admin',
                      onTap: () =>
                          setState(() => _selectedRole = 'startup_admin'),
                    ),
                    const SizedBox(width: 12),
                    _RoleCard(
                      label: 'Ventures Lab',
                      icon: Icons.verified_outlined,
                      isSelected: _selectedRole == 'ventures_lab_admin',
                      onTap: () => setState(
                          () => _selectedRole = 'ventures_lab_admin'),
                    ),
                  ],
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedRole == 'startup_admin'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              'Startup Details',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _startupNameController,
                              validator: (v) =>
                                  _selectedRole == 'startup_admin'
                                      ? Validators.validateRequired(
                                          v, 'Startup name')
                                      : null,
                              decoration: const InputDecoration(
                                labelText: AppStrings.startupName,
                                prefixIcon: Icon(Icons.business_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _startupDescController,
                              maxLines: 3,
                              validator: (v) =>
                                  _selectedRole == 'startup_admin'
                                      ? Validators.validateRequired(
                                          v, 'Description')
                                      : null,
                              decoration: const InputDecoration(
                                labelText: AppStrings.startupDescription,
                                prefixIcon:
                                    Icon(Icons.description_outlined),
                                alignLabelWithHint: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _startupIndustryController,
                              validator: (v) =>
                                  _selectedRole == 'startup_admin'
                                      ? Validators.validateRequired(
                                          v, 'Industry')
                                      : null,
                              decoration: const InputDecoration(
                                labelText: AppStrings.industry,
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(AppStrings.register),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.hasAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed('/login'),
                        child: Text(
                          AppStrings.signIn,
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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.backgroundDark
                : AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryRed
                  : const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryRed : AppTheme.textGrey,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? Colors.white : AppTheme.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}