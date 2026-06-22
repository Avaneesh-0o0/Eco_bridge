import 'dart:io';
import '../../domain/entities/food_listing_entity.dart';
import '../../domain/repositories/donation_repository.dart';
import '../datasources/donation_remote_datasource.dart';

class DonationRepositoryImpl implements DonationRepository {
  final DonationRemoteDataSource remoteDataSource;

  DonationRepositoryImpl(this.remoteDataSource);

  @override
  Future<FoodListingEntity> createDonation({
    required String donorId,
    required String foodName,
    String? category,
    String? description,
    int? estimatedServings,
    String? pickupAddress,
    DateTime? expiryTime,
    List<File> images = const [],
  }) {
    return remoteDataSource.createDonation(
      donorId: donorId,
      foodName: foodName,
      category: category,
      description: description,
      estimatedServings: estimatedServings,
      pickupAddress: pickupAddress,
      expiryTime: expiryTime,
      images: images,
    );
  }

  @override
  Future<List<FoodListingEntity>> getDonorDonations(String donorId) {
    return remoteDataSource.getDonorDonations(donorId);
  }

  @override
  Future<List<FoodListingEntity>> getAvailableDonations() {
    return remoteDataSource.getAvailableDonations();
  }

  @override
  Future<List<FoodListingEntity>> getNgoAcceptedDonations(String ngoProfileId) {
    return remoteDataSource.getNgoAcceptedDonations(ngoProfileId);
  }

  @override
  Future<void> acceptDonation({
    required String listingId,
    required String ngoProfileId,
  }) {
    return remoteDataSource.acceptDonation(
      listingId: listingId,
      ngoProfileId: ngoProfileId,
    );
  }
}
