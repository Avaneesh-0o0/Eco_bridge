import '../repositories/donation_repository.dart';

class AcceptDonationUseCase {
  final DonationRepository repository;

  AcceptDonationUseCase(this.repository);

  Future<void> call({
    required String listingId,
    required String ngoProfileId,
  }) async {
    return await repository.acceptDonation(
      listingId: listingId,
      ngoProfileId: ngoProfileId,
    );
  }
}
