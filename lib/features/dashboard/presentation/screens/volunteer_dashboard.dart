import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../delivery/presentation/providers/volunteer_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../ai_chat/presentation/screens/ai_chat_screen.dart';

class VolunteerDashboard extends ConsumerStatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  ConsumerState<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends ConsumerState<VolunteerDashboard> with SingleTickerProviderStateMixin {
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
    ref.listen(volunteerActionProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}'), backgroundColor: AppColors.error),
        );
      } else if (!next.isLoading && previous?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action successful!'), backgroundColor: AppColors.success),
        );
      }
    });

    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hi, ${user?.fullName.split(' ')[0] ?? 'Volunteer'}'),
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
            Tab(text: 'Available Deliveries'),
            Tab(text: 'My Active Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: const [
          _AvailableDeliveriesTab(),
          _ActiveDeliveriesTab(),
        ],
      ),
    );
  }
}

class _AvailableDeliveriesTab extends ConsumerWidget {
  const _AvailableDeliveriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref.watch(availableDeliveriesProvider);
    final actionState = ref.watch(volunteerActionProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Map mock
          Container(
            margin: const EdgeInsets.all(AppSizes.p16),
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_outlined, color: AppColors.secondary, size: 40),
                const SizedBox(width: 16),
                Text(
                  'Live Delivery Map\n(Available soon)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          available.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: AppColors.secondaryText.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('All clear! No available deliveries right now.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
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
                        if (task.imageUrl != null)
                          Image.network(
                            task.imageUrl!,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            height: 140,
                            width: double.infinity,
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            child: const Icon(Icons.delivery_dining, size: 64, color: AppColors.secondary),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(AppSizes.p24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.foodName, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.store, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('From: ${task.pickupAddress ?? "Unknown"}', style: Theme.of(context).textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.favorite, size: 16, color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('To NGO: ${task.ngoName}', style: Theme.of(context).textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: actionState.isLoading
                                      ? null
                                      : () {
                                          ref.read(volunteerActionProvider.notifier).acceptDelivery(
                                                donationRequestId: task.id,
                                                listingId: task.listingId,
                                              );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: actionState.isLoading
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text('Accept Delivery'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}

class _ActiveDeliveriesTab extends ConsumerWidget {
  const _ActiveDeliveriesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeDeliveriesProvider);
    final actionState = ref.watch(volunteerActionProvider);

    return active.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_bike, size: 80, color: AppColors.secondaryText.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No active tasks.', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
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
                        child: Text(task.foodName, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: task.taskStatus == 'accepted' ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          task.taskStatus?.replaceAll('_', ' ').toUpperCase() ?? 'UNKNOWN',
                          style: TextStyle(
                            color: task.taskStatus == 'accepted' ? AppColors.secondary : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
                      Expanded(child: Text('Pickup: ${task.pickupAddress ?? "Unknown"}', style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.arrow_downward, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Deliver To: ${task.ngoName}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Mock Optimize Route Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('✨ Smart Route Optimizer'),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map, size: 48, color: AppColors.primary),
                                SizedBox(height: 16),
                                Text('Calculating fastest route...'),
                                SizedBox(height: 8),
                                Text('Avoiding heavy traffic on MG Road.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('✨ Route optimized! Saved 14 mins of travel time.'), backgroundColor: AppColors.primary),
                                  );
                                },
                                child: const Text('Done'),
                              )
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.alt_route, color: AppColors.primary),
                      label: const Text('Optimize Route', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (task.taskStatus == 'accepted')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: actionState.isLoading || task.deliveryTaskId == null
                            ? null
                            : () {
                                ref.read(volunteerActionProvider.notifier).updateDeliveryStatus(
                                      deliveryTaskId: task.deliveryTaskId!,
                                      donationRequestId: task.id,
                                      listingId: task.listingId,
                                      newStatus: 'picked_up',
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Mark as Picked Up'),
                      ),
                    ),
                  if (task.taskStatus == 'picked_up')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: actionState.isLoading || task.deliveryTaskId == null
                            ? null
                            : () {
                                ref.read(volunteerActionProvider.notifier).updateDeliveryStatus(
                                      deliveryTaskId: task.deliveryTaskId!,
                                      donationRequestId: task.id,
                                      listingId: task.listingId,
                                      newStatus: 'delivered',
                                    );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Mark as Delivered'),
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
