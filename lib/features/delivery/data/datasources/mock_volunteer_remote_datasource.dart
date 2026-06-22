import 'package:uuid/uuid.dart';
import '../models/delivery_task_model.dart';
import 'volunteer_remote_datasource.dart';

class MockVolunteerRemoteDataSource implements VolunteerRemoteDataSource {
  final List<DeliveryTaskModel> _tasks = [
    DeliveryTaskModel(
      id: const Uuid().v4(),
      listingId: 'mock_listing_1',
      foodName: 'Wedding Feast Leftovers',
      category: 'Cooked Food',
      pickupAddress: 'Grand Palace Hotel, 123 Main St, Indore',
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80',
      ngoName: 'Asha Foundation',
      requestStatus: 'accepted',
      deliveryTaskId: null,
      taskStatus: null,
    ),
    DeliveryTaskModel(
      id: const Uuid().v4(),
      listingId: 'mock_listing_2',
      foodName: 'Fresh Baked Bread',
      category: 'Bakery',
      pickupAddress: 'Sunny Bakery, 456 Oak St, Indore',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
      ngoName: 'Jeevan Seva',
      requestStatus: 'accepted',
      deliveryTaskId: null,
      taskStatus: null,
    ),
  ];

  final List<DeliveryTaskModel> _activeTasks = [];

  @override
  Future<List<DeliveryTaskModel>> getAvailableDeliveries() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _tasks.where((t) => t.deliveryTaskId == null && t.requestStatus == 'accepted').toList();
  }

  @override
  Future<List<DeliveryTaskModel>> getActiveDeliveries(String volunteerProfileId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _activeTasks;
  }

  @override
  Future<void> acceptDelivery({
    required String donationRequestId,
    required String volunteerProfileId,
    required String listingId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final index = _tasks.indexWhere((t) => t.id == donationRequestId);
    if (index != -1) {
      final old = _tasks[index];
      final acceptedTask = DeliveryTaskModel(
        id: old.id,
        listingId: old.listingId,
        foodName: old.foodName,
        category: old.category,
        pickupAddress: old.pickupAddress,
        imageUrl: old.imageUrl,
        ngoName: old.ngoName,
        requestStatus: 'accepted',
        deliveryTaskId: const Uuid().v4(),
        taskStatus: 'accepted',
      );
      
      _tasks.removeAt(index);
      _activeTasks.insert(0, acceptedTask);
    }
  }

  @override
  Future<void> updateDeliveryStatus({
    required String deliveryTaskId,
    required String donationRequestId,
    required String listingId,
    required String volunteerProfileId,
    required String newStatus,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final index = _activeTasks.indexWhere((t) => t.id == donationRequestId);
    if (index != -1) {
      final old = _activeTasks[index];
      final updatedTask = DeliveryTaskModel(
        id: old.id,
        listingId: old.listingId,
        foodName: old.foodName,
        category: old.category,
        pickupAddress: old.pickupAddress,
        imageUrl: old.imageUrl,
        ngoName: old.ngoName,
        requestStatus: newStatus == 'delivered' ? 'delivered' : 'accepted',
        deliveryTaskId: old.deliveryTaskId,
        taskStatus: newStatus,
      );
      
      if (newStatus == 'delivered') {
        _activeTasks.removeAt(index);
      } else {
        _activeTasks[index] = updatedTask;
      }
    }
  }
}
