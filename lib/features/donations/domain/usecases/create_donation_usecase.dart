import 'dart:io';
import '../entities/food_listing_entity.dart';
import '../repositories/donation_repository.dart';

class CreateDonationUseCase {
  final DonationRepository repository;

  CreateDonationUseCase(this.repository);

  Future<FoodListingEntity> execute({
    required String donorId,
    required String foodName,
    String? category,
    String? description,
    int? estimatedServings,
    String? pickupAddress,
    DateTime? expiryTime,
    List<File> images = const [],
  }) {
    return repository.createDonation(
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
}
