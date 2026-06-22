import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).register(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: widget.role,
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join as ${widget.role.toUpperCase()}',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSizes.p32),
              CustomTextField(
                label: 'Full Name / Organization Name',
                hint: 'Enter name',
                controller: _nameController,
                validator: (val) => val != null && val.isNotEmpty ? null : 'Required field',
              ),
              const SizedBox(height: AppSizes.p16),
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
                hint: 'Create a password',
                controller: _passwordController,
                isPassword: true,
                validator: (val) => val != null && val.length >= 6 ? null : 'Password must be at least 6 characters',
              ),
              const SizedBox(height: AppSizes.p32),
              CustomButton(
                text: 'Register',
                isLoading: _isLoading,
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
