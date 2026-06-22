import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;

  void _handleContinue() async {
    if (_selectedRole == null) return;

    // Simulate login for the selected role
    await ref.read(authStateProvider.notifier).login(
      '${_selectedRole!}@example.com',
      'password',
    );

    if (!mounted) return;

    // Route to appropriate dashboard
    switch (_selectedRole) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join FoodBridge AI')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How would you like to participate?',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: AppSizes.p32),
            _buildRoleCard(
              title: 'Food Donor',
              description: 'I have surplus food to donate (Restaurant, Hotel, Event).',
              icon: Icons.restaurant,
              role: 'donor',
            ),
            const SizedBox(height: AppSizes.p16),
            _buildRoleCard(
              title: 'NGO / Shelter',
              description: 'I want to rescue food for my community.',
              icon: Icons.health_and_safety,
              role: 'ngo',
            ),
            const SizedBox(height: AppSizes.p16),
            _buildRoleCard(
              title: 'Volunteer',
              description: 'I can help transport food from donors to NGOs.',
              icon: Icons.directions_car,
              role: 'volunteer',
            ),
            const Spacer(),
            CustomButton(
              text: 'Continue',
              onPressed: _selectedRole == null ? () {} : _handleContinue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required String role,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.secondaryText,
              ),
            ),
            const SizedBox(width: AppSizes.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.darkText,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
