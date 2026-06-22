import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/route_names.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Wait for auth provider to initialize
      final user = await ref.read(authStateProvider.future);
      // Wait for splash duration
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;

      if (user != null) {
        // Navigate to dashboard based on role
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
          default:
            context.go(RouteNames.login);
        }
      } else {
        context.go(RouteNames.onboarding);
      }
    } catch (e) {
      if (!mounted) return;
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.food_bank,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'FoodBridge AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
