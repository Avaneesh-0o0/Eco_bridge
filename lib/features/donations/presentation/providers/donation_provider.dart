import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/donation_remote_datasource.dart';
import '../../data/repositories/donation_repository_impl.dart';
import '../../domain/entities/food_listing_entity.dart';
import '../../domain/repositories/donation_repository.dart';
import '../../domain/usecases/create_donation_usecase.dart';
import '../../domain/usecases/get_donor_donations_usecase.dart';
import '../../domain/usecases/get_available_donations_usecase.dart';
import '../../domain/usecases/get_ngo_accepted_donations_usecase.dart';
import '../../domain/usecases/accept_donation_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'dart:io';

import '../../data/datasources/mock_donation_remote_datasource.dart';

final donationRemoteDataSourceProvider = Provider<DonationRemoteDataSource>((ref) {
  return MockDonationRemoteDataSource();
});

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return DonationRepositoryImpl(ref.read(donationRemoteDataSourceProvider));
});

final createDonationUseCaseProvider = Provider<CreateDonationUseCase>((ref) {
  return CreateDonationUseCase(ref.read(donationRepositoryProvider));
});

final getDonorDonationsUseCaseProvider = Provider<GetDonorDonationsUseCase>((ref) {
  return GetDonorDonationsUseCase(ref.read(donationRepositoryProvider));
});

final getAvailableDonationsUseCaseProvider = Provider<GetAvailableDonationsUseCase>((ref) {
  return GetAvailableDonationsUseCase(ref.read(donationRepositoryProvider));
});

final getNgoAcceptedDonationsUseCaseProvider = Provider<GetNgoAcceptedDonationsUseCase>((ref) {
  return GetNgoAcceptedDonationsUseCase(ref.read(donationRepositoryProvider));
});

final acceptDonationUseCaseProvider = Provider<AcceptDonationUseCase>((ref) {
  return AcceptDonationUseCase(ref.read(donationRepositoryProvider));
});

// StateNotifier for Create Donation
final createDonationProvider = AsyncNotifierProvider<CreateDonationNotifier, void>(() {
  return CreateDonationNotifier();
});

class CreateDonationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> createDonation({
    required String foodName,
    String? category,
    String? description,
    int? estimatedServings,
    String? pickupAddress,
    DateTime? expiryTime,
    List<File> images = const [],
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not logged in');

      await ref.read(createDonationUseCaseProvider).execute(
            donorId: user.id,
            foodName: foodName,
            category: category,
            description: description,
            estimatedServings: estimatedServings,
            pickupAddress: pickupAddress,
            expiryTime: expiryTime,
            images: images,
          );
      
      // Refresh the list of donations
      ref.invalidate(donorDonationsProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final donorDonationsProvider = FutureProvider<List<FoodListingEntity>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  
  return ref.read(getDonorDonationsUseCaseProvider).execute(user.id);
});

// FutureProvider for fetching available donations (for NGO)
final availableDonationsProvider = FutureProvider<List<FoodListingEntity>>((ref) async {
  return ref.read(getAvailableDonationsUseCaseProvider).call();
});

// FutureProvider for fetching accepted donations (for NGO dispatch)
final ngoAcceptedDonationsProvider = FutureProvider<List<FoodListingEntity>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  return ref.read(getNgoAcceptedDonationsUseCaseProvider).call(user.id);
});

// AsyncNotifier for Accept Donation
final acceptDonationProvider = AsyncNotifierProvider<AcceptDonationNotifier, void>(() {
  return AcceptDonationNotifier();
});

class AcceptDonationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> acceptDonation(String listingId) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not logged in');

      await ref.read(acceptDonationUseCaseProvider).call(
        listingId: listingId,
        ngoProfileId: user.id,
      );
      
      // Refresh available donations
      ref.invalidate(availableDonationsProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
