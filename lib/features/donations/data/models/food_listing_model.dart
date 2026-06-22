import '../../domain/entities/food_listing_entity.dart';

class FoodListingModel extends FoodListingEntity {
  FoodListingModel({
    required super.id,
    required super.donorId,
    super.organizationId,
    required super.foodName,
    super.category,
    super.description,
    super.quantityKg,
    super.estimatedServings,
    super.pickupStartTime,
    super.pickupEndTime,
    super.expiryTime,
    super.pickupAddress,
    super.latitude,
    super.longitude,
    required super.status,
    super.createdAt,
    super.imageUrls,
  });

  factory FoodListingModel.fromJson(Map<String, dynamic> json) {
    return FoodListingModel(
      id: json['id'],
      donorId: json['donor_id'],
      organizationId: json['organization_id'],
      foodName: json['food_name'],
      category: json['category'],
      description: json['description'],
      quantityKg: json['quantity_kg'] != null ? (json['quantity_kg'] as num).toDouble() : null,
      estimatedServings: json['estimated_servings'],
      pickupStartTime: json['pickup_start_time'] != null ? DateTime.parse(json['pickup_start_time']) : null,
      pickupEndTime: json['pickup_end_time'] != null ? DateTime.parse(json['pickup_end_time']) : null,
      expiryTime: json['expiry_time'] != null ? DateTime.parse(json['expiry_time']) : null,
      pickupAddress: json['pickup_address'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      status: json['status'] ?? 'available',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      imageUrls: json['food_images'] != null 
          ? (json['food_images'] as List).map((e) => e['image_url'] as String).toList() 
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'organization_id': organizationId,
      'food_name': foodName,
      'category': category,
      'description': description,
      'quantity_kg': quantityKg,
      'estimated_servings': estimatedServings,
      'pickup_start_time': pickupStartTime?.toIso8601String(),
      'pickup_end_time': pickupEndTime?.toIso8601String(),
      'expiry_time': expiryTime?.toIso8601String(),
      'pickup_address': pickupAddress,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
