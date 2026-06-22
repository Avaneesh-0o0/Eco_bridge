class FoodListingEntity {
  final String id;
  final String donorId;
  final String? organizationId;
  final String foodName;
  final String? category;
  final String? description;
  final double? quantityKg;
  final int? estimatedServings;
  final DateTime? pickupStartTime;
  final DateTime? pickupEndTime;
  final DateTime? expiryTime;
  final String? pickupAddress;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime? createdAt;
  final List<String> imageUrls;

  FoodListingEntity({
    required this.id,
    required this.donorId,
    this.organizationId,
    required this.foodName,
    this.category,
    this.description,
    this.quantityKg,
    this.estimatedServings,
    this.pickupStartTime,
    this.pickupEndTime,
    this.expiryTime,
    this.pickupAddress,
    this.latitude,
    this.longitude,
    required this.status,
    this.createdAt,
    this.imageUrls = const [],
  });
}
