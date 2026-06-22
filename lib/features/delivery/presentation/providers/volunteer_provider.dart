import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/volunteer_remote_datasource.dart';
import '../../data/datasources/mock_volunteer_remote_datasource.dart';
import '../../data/repositories/volunteer_repository_impl.dart';
import '../../domain/entities/delivery_task_entity.dart';
import '../../domain/repositories/volunteer_repository.dart';
import '../../domain/usecases/get_available_deliveries_usecase.dart';
import '../../domain/usecases/get_active_deliveries_usecase.dart';
import '../../domain/usecases/accept_delivery_usecase.dart';
import '../../domain/usecases/update_delivery_status_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final volunteerRemoteDataSourceProvider = Provider<VolunteerRemoteDataSource>((ref) {
  return MockVolunteerRemoteDataSource();
});

final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) {
  return VolunteerRepositoryImpl(ref.read(volunteerRemoteDataSourceProvider));
});

final getAvailableDeliveriesUseCaseProvider = Provider<GetAvailableDeliveriesUseCase>((ref) {
  return GetAvailableDeliveriesUseCase(ref.read(volunteerRepositoryProvider));
});

final getActiveDeliveriesUseCaseProvider = Provider<GetActiveDeliveriesUseCase>((ref) {
  return GetActiveDeliveriesUseCase(ref.read(volunteerRepositoryProvider));
});

final acceptDeliveryUseCaseProvider = Provider<AcceptDeliveryUseCase>((ref) {
  return AcceptDeliveryUseCase(ref.read(volunteerRepositoryProvider));
});

final updateDeliveryStatusUseCaseProvider = Provider<UpdateDeliveryStatusUseCase>((ref) {
  return UpdateDeliveryStatusUseCase(ref.read(volunteerRepositoryProvider));
});

final availableDeliveriesProvider = FutureProvider<List<DeliveryTaskEntity>>((ref) async {
  return ref.read(getAvailableDeliveriesUseCaseProvider).call();
});

final activeDeliveriesProvider = FutureProvider<List<DeliveryTaskEntity>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  return ref.read(getActiveDeliveriesUseCaseProvider).call(user.id);
});

final volunteerActionProvider = AsyncNotifierProvider<VolunteerActionNotifier, void>(() {
  return VolunteerActionNotifier();
});

class VolunteerActionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> acceptDelivery({
    required String donationRequestId,
    required String listingId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not logged in');

      await ref.read(acceptDeliveryUseCaseProvider).call(
        donationRequestId: donationRequestId,
        volunteerProfileId: user.id,
        listingId: listingId,
      );
      
      ref.invalidate(availableDeliveriesProvider);
      ref.invalidate(activeDeliveriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateDeliveryStatus({
    required String deliveryTaskId,
    required String donationRequestId,
    required String listingId,
    required String newStatus,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not logged in');

      await ref.read(updateDeliveryStatusUseCaseProvider).call(
        deliveryTaskId: deliveryTaskId,
        donationRequestId: donationRequestId,
        listingId: listingId,
        volunteerProfileId: user.id,
        newStatus: newStatus,
      );
      
      ref.invalidate(availableDeliveriesProvider);
      ref.invalidate(activeDeliveriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
