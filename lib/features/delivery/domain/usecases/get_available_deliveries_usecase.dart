import '../entities/delivery_task_entity.dart';
import '../repositories/volunteer_repository.dart';

class GetAvailableDeliveriesUseCase {
  final VolunteerRepository repository;

  GetAvailableDeliveriesUseCase(this.repository);

  Future<List<DeliveryTaskEntity>> call() async {
    return await repository.getAvailableDeliveries();
  }
}
