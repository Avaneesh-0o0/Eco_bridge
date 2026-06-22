import '../entities/delivery_task_entity.dart';
import '../repositories/volunteer_repository.dart';

class GetActiveDeliveriesUseCase {
  final VolunteerRepository repository;

  GetActiveDeliveriesUseCase(this.repository);

  Future<List<DeliveryTaskEntity>> call(String volunteerProfileId) async {
    return await repository.getActiveDeliveries(volunteerProfileId);
  }
}
