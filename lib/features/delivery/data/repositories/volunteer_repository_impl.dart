import '../../domain/entities/delivery_task_entity.dart';
import '../../domain/repositories/volunteer_repository.dart';
import '../datasources/volunteer_remote_datasource.dart';

class VolunteerRepositoryImpl implements VolunteerRepository {
  final VolunteerRemoteDataSource remoteDataSource;

  VolunteerRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DeliveryTaskEntity>> getAvailableDeliveries() {
    return remoteDataSource.getAvailableDeliveries();
  }

  @override
  Future<List<DeliveryTaskEntity>> getActiveDeliveries(String volunteerProfileId) {
    return remoteDataSource.getActiveDeliveries(volunteerProfileId);
  }

  @override
  Future<void> acceptDelivery({
    required String donationRequestId,
    required String volunteerProfileId,
    required String listingId,
  }) {
    return remoteDataSource.acceptDelivery(
      donationRequestId: donationRequestId,
      volunteerProfileId: volunteerProfileId,
      listingId: listingId,
    );
  }

  @override
  Future<void> updateDeliveryStatus({
    required String deliveryTaskId,
    required String donationRequestId,
    required String listingId,
    required String volunteerProfileId,
    required String newStatus,
  }) {
    return remoteDataSource.updateDeliveryStatus(
      deliveryTaskId: deliveryTaskId,
      donationRequestId: donationRequestId,
      listingId: listingId,
      volunteerProfileId: volunteerProfileId,
      newStatus: newStatus,
    );
  }
}
