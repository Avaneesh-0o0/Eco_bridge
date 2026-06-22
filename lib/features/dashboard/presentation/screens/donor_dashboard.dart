import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../routes/route_names.dart';
import '../../../donations/presentation/providers/donation_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../ai_chat/presentation/screens/ai_chat_screen.dart';

class DonorDashboard extends ConsumerWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(donorDonationsProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Welcome, ${user?.fullName.split(' ')[0] ?? 'Donor'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.purple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push('/live-map'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Stats Section
            Container(
              margin: const EdgeInsets.all(AppSizes.p16),
              padding: const EdgeInsets.all(AppSizes.p24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Impact', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('124', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 40)),
                        Text('Meals Saved', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 40),
                  )
                ],
              ),
            ),

            // AI Insight Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Insight', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('3 NGOs are actively looking for food near your location today.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkText)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.p24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Text('Your Donations', style: Theme.of(context).textTheme.displaySmall),
            ),
            const SizedBox(height: AppSizes.p16),

            donationsAsync.when(
              data: (donations) {
                if (donations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.secondaryText.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('No active donations yet.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final donation = donations[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.p16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (donation.imageUrls.isNotEmpty)
                            Image.network(
                              donation.imageUrls.first,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(
                              height: 180,
                              width: double.infinity,
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(Icons.fastfood, size: 64, color: AppColors.primary),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(AppSizes.p16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(donation.foodName, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: donation.status == 'available' ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        donation.status.toUpperCase(),
                                        style: TextStyle(
                                          color: donation.status == 'available' ? AppColors.secondary : AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(donation.description ?? 'No description provided.', style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline, size: 20, color: AppColors.secondaryText),
                                    const SizedBox(width: 8),
                                    Text('Serves approx. ${donation.estimatedServings ?? "N/A"} people', style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
            const SizedBox(height: 100), // Bottom padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.donorCreateDonation),
        label: const Text('Share Food', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.primary,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
