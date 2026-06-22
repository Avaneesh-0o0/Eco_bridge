import '../entities/food_listing_entity.dart';
import '../repositories/donation_repository.dart';

class GetNgoAcceptedDonationsUseCase {
  final DonationRepository repository;

  GetNgoAcceptedDonationsUseCase(this.repository);

  Future<List<FoodListingEntity>> call(String ngoProfileId) {
    return repository.getNgoAcceptedDonations(ngoProfileId);
  }
}
