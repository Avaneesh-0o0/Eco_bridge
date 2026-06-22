import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
          
      if (!mounted) return;
      
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        switch (user.role) {
          case 'donor':
            context.go(RouteNames.donorDashboard);
            break;
          case 'ngo':
            context.go(RouteNames.ngoDashboard);
            break;
          case 'volunteer':
            context.go(RouteNames.volunteerDashboard);
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      'Sign in to continue making an impact.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                    ),
                    const SizedBox(height: AppSizes.p32),
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val != null && val.contains('@') ? null : 'Enter a valid email',
                    ),
                    const SizedBox(height: AppSizes.p16),
                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      isPassword: true,
                      validator: (val) => val != null && val.length >= 6 ? null : 'Password must be at least 6 characters',
                    ),
                    const SizedBox(height: AppSizes.p32),
                    CustomButton(
                      text: 'Login',
                      isLoading: _isLoading,
                      onPressed: _login,
                    ),
                    const SizedBox(height: AppSizes.p24),
                    const Center(child: Text('--- Fast Login (Testing) ---', style: TextStyle(color: Colors.grey))),
                    const SizedBox(height: AppSizes.p8),
                    Center(
                      child: Wrap(
                        spacing: AppSizes.p8,
                        alignment: WrapAlignment.center,
                        children: [
                          ActionChip(
                            label: const Text('Login: Donor'),
                            onPressed: () {
                              _emailController.text = 'donor@example.com';
                              _passwordController.text = 'password123';
                              _login();
                            },
                          ),
                          ActionChip(
                            label: const Text('Login: NGO'),
                            onPressed: () {
                              _emailController.text = 'ngo@example.com';
                              _passwordController.text = 'password123';
                              _login();
                            },
                          ),
                          ActionChip(
                            label: const Text('Login: Volunteer'),
                            onPressed: () {
                              _emailController.text = 'volunteer@example.com';
                              _passwordController.text = 'password123';
                              _login();
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () => context.push(RouteNames.roleSelection),
                          child: const Text('Sign Up', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
