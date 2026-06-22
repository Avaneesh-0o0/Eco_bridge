import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.volunteer_activism,
                size: 120,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSizes.p32),
              Text(
                'Transforming Surplus Food into Social Impact',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSizes.p16),
              Text(
                'Join our community to help reduce food waste and feed those in need.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryText,
                    ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Get Started',
                onPressed: () {
                  context.push(RouteNames.roleSelection);
                },
              ),
              const SizedBox(height: AppSizes.p16),
              CustomButton(
                text: 'I already have an account',
                isSecondary: true,
                onPressed: () {
                  context.push(RouteNames.login);
                },
              ),
              const SizedBox(height: AppSizes.p16),
            ],
          ),
        ),
      ),
    );
  }
}
