import '../repositories/volunteer_repository.dart';

class AcceptDeliveryUseCase {
  final VolunteerRepository repository;

  AcceptDeliveryUseCase(this.repository);

  Future<void> call({
    required String donationRequestId,
    required String volunteerProfileId,
    required String listingId,
  }) async {
    return await repository.acceptDelivery(
      donationRequestId: donationRequestId,
      volunteerProfileId: volunteerProfileId,
      listingId: listingId,
    );
  }
}
