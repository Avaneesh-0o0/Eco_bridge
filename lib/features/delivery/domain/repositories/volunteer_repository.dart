import '../entities/delivery_task_entity.dart';

abstract class VolunteerRepository {
  Future<List<DeliveryTaskEntity>> getAvailableDeliveries();
  
  Future<List<DeliveryTaskEntity>> getActiveDeliveries(String volunteerProfileId);
  
  Future<void> acceptDelivery({
    required String donationRequestId,
    required String volunteerProfileId,
    required String listingId,
  });

  Future<void> updateDeliveryStatus({
    required String deliveryTaskId,
    required String donationRequestId,
    required String listingId,
    required String volunteerProfileId,
    required String newStatus,
  });
}
