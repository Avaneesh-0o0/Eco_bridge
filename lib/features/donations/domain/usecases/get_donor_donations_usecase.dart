import '../entities/food_listing_entity.dart';
import '../repositories/donation_repository.dart';

class GetDonorDonationsUseCase {
  final DonationRepository repository;

  GetDonorDonationsUseCase(this.repository);

  Future<List<FoodListingEntity>> execute(String donorId) {
    return repository.getDonorDonations(donorId);
  }
}
