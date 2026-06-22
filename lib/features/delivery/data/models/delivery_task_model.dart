import '../../domain/entities/delivery_task_entity.dart';

class DeliveryTaskModel extends DeliveryTaskEntity {
  DeliveryTaskModel({
    required super.id,
    required super.listingId,
    required super.foodName,
    super.category,
    super.pickupAddress,
    super.imageUrl,
    required super.ngoName,
    required super.requestStatus,
    super.deliveryTaskId,
    super.taskStatus,
  });

  factory DeliveryTaskModel.fromJson(Map<String, dynamic> json) {
    // Navigate nested Supabase joins
    final listing = json['food_listings'] as Map<String, dynamic>?;
    final ngo = json['ngo_details'] as Map<String, dynamic>?;
    final org = ngo?['organizations'] as Map<String, dynamic>?;
    final images = listing?['food_images'] as List?;
    
    // We might have joined delivery_tasks if a volunteer accepted it
    final deliveryTasks = json['delivery_tasks'] as List?;
    final deliveryTask = deliveryTasks != null && deliveryTasks.isNotEmpty 
        ? deliveryTasks.first as Map<String, dynamic> 
        : null;

    return DeliveryTaskModel(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      foodName: listing?['food_name'] ?? 'Unknown',
      category: listing?['category'] as String?,
      pickupAddress: listing?['pickup_address'] as String?,
      imageUrl: (images != null && images.isNotEmpty) ? images.first['image_url'] as String? : null,
      ngoName: org?['organization_name'] ?? 'Unknown NGO',
      requestStatus: json['status'] as String,
      deliveryTaskId: deliveryTask?['id'] as String?,
      taskStatus: deliveryTask?['task_status'] as String?,
    );
  }
}
