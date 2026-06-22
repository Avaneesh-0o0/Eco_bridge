import '../repositories/volunteer_repository.dart';

class UpdateDeliveryStatusUseCase {
  final VolunteerRepository repository;

  UpdateDeliveryStatusUseCase(this.repository);

  Future<void> call({
    required String deliveryTaskId,
    required String donationRequestId,
    required String listingId,
    required String volunteerProfileId,
    required String newStatus,
  }) async {
    return await repository.updateDeliveryStatus(
      deliveryTaskId: deliveryTaskId,
      donationRequestId: donationRequestId,
      listingId: listingId,
      volunteerProfileId: volunteerProfileId,
      newStatus: newStatus,
    );
  }
}
