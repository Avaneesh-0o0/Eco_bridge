import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../donations/presentation/providers/donation_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

import '../../../ai_chat/presentation/screens/ai_chat_screen.dart';

class NgoDashboard extends ConsumerStatefulWidget {
  const NgoDashboard({super.key});

  @override
  ConsumerState<NgoDashboard> createState() => _NgoDashboardState();
}

class _NgoDashboardState extends ConsumerState<NgoDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    ref.listen(acceptDonationProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept: ${next.error}'), backgroundColor: AppColors.error),
        );
      } else if (!next.isLoading && previous?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation accepted! Managing dispatch...'), backgroundColor: AppColors.success),
        );
        _tabController.animateTo(1);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${user?.fullName ?? 'NGO'} Dashboard'),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Available Nearby'),
            Tab(text: 'My Dispatches'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: const [
          _AvailableNearbyTab(),
          _MyDispatchesTab(),
        ],
      ),
    );
  }
}

class _AvailableNearbyTab extends ConsumerWidget {
  const _AvailableNearbyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableDonations = ref.watch(availableDonationsProvider);
    final acceptState = ref.watch(acceptDonationProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          Container(
            margin: const EdgeInsets.all(AppSizes.p16),
            padding: const EdgeInsets.all(AppSizes.p24),
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.3),
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
                      Text('Total Rescued', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('850', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 40)),
                      Text('kg of food', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront, color: Colors.white, size: 40),
                )
              ],
            ),
          ),

          // Map Preview / Radar Mock
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.radar, color: AppColors.primary, size: 32),
                  const SizedBox(width: 16),
                  Text(
                    'Scanning for nearby donations...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.p24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            child: Text('Available Nearby', style: Theme.of(context).textTheme.displaySmall),
          ),
          const SizedBox(height: AppSizes.p16),

          availableDonations.when(
            data: (donations) {
              if (donations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.location_off, size: 64, color: AppColors.secondaryText.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('No available donations right now.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText)),
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
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            height: 160,
                            width: double.infinity,
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.fastfood, size: 64, color: AppColors.primary),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(donation.foodName, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: AppColors.secondaryText),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(donation.pickupAddress ?? 'No address', style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Quantity', style: Theme.of(context).textTheme.labelSmall),
                                      Text('${donation.quantityKg ?? "?"} kg', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Servings', style: Theme.of(context).textTheme.labelSmall),
                                      Text('${donation.estimatedServings ?? "?"}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Category', style: Theme.of(context).textTheme.labelSmall),
                                      Text(donation.category ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: acceptState.isLoading
                                      ? null
                                      : () {
                                          ref.read(acceptDonationProvider.notifier).acceptDonation(donation.id);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: acceptState.isLoading
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text('Accept & Request Pickup'),
                                ),
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
            error: (e, st) => Center(child: Text('Error loading donations: $e')),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MyDispatchesTab extends ConsumerWidget {
  const _MyDispatchesTab();

  void _showDispatchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Volunteers', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              const Text('Select a volunteer to dispatch for pickup.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
                title: const Text('Priya Patel', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('⭐ 4.9 • 2.1 km away'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispatched Priya Patel for pickup!'), backgroundColor: AppColors.success),
                    );
                  },
                  child: const Text('Dispatch'),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.secondary, child: Icon(Icons.person, color: Colors.white)),
                title: const Text('Rahul Singh', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('⭐ 4.7 • 3.5 km away'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispatched Rahul Singh for pickup!'), backgroundColor: AppColors.success),
                    );
                  },
                  child: const Text('Dispatch'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceptedDonations = ref.watch(ngoAcceptedDonationsProvider);

    return acceptedDonations.when(
      data: (donations) {
        if (donations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.secondaryText.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No active dispatches.', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: donations.length,
          itemBuilder: (context, index) {
            final donation = donations[index];
            return Container(
              margin: const EdgeInsets.only(bottom: AppSizes.p16),
              padding: const EdgeInsets.all(AppSizes.p24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(donation.foodName, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'NEEDS DISPATCH',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward, size: 20, color: AppColors.secondaryText),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Pickup: ${donation.pickupAddress ?? "Unknown"}', style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDispatchModal(context),
                      icon: const Icon(Icons.directions_run),
                      label: const Text('Dispatch Volunteer'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
