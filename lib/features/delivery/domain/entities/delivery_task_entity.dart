class DeliveryTaskEntity {
  final String id; // donation_request_id
  final String listingId;
  final String foodName;
  final String? category;
  final String? pickupAddress;
  final String? imageUrl;
  final String ngoName;
  final String requestStatus;
  final String? deliveryTaskId; 
  final String? taskStatus;

  DeliveryTaskEntity({
    required this.id,
    required this.listingId,
    required this.foodName,
    this.category,
    this.pickupAddress,
    this.imageUrl,
    required this.ngoName,
    required this.requestStatus,
    this.deliveryTaskId,
    this.taskStatus,
  });
}
