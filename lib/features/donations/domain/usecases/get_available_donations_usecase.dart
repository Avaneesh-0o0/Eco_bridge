import '../entities/food_listing_entity.dart';
import '../repositories/donation_repository.dart';

class GetAvailableDonationsUseCase {
  final DonationRepository repository;

  GetAvailableDonationsUseCase(this.repository);

  Future<List<FoodListingEntity>> call() async {
    return await repository.getAvailableDonations();
  }
}
