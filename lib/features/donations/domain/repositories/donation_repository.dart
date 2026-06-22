import '../entities/food_listing_entity.dart';
import 'dart:io';

abstract class DonationRepository {
  Future<FoodListingEntity> createDonation({
    required String donorId,
    required String foodName,
    String? category,
    String? description,
    int? estimatedServings,
    String? pickupAddress,
    DateTime? expiryTime,
    List<File> images = const [],
  });

  Future<List<FoodListingEntity>> getDonorDonations(String donorId);

  Future<List<FoodListingEntity>> getAvailableDonations();

  Future<List<FoodListingEntity>> getNgoAcceptedDonations(String ngoProfileId);

  Future<void> acceptDonation({
    required String listingId,
    required String ngoProfileId,
  });
}
