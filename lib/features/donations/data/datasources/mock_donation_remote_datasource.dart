import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/food_listing_model.dart';
import 'donation_remote_datasource.dart';

class MockDonationRemoteDataSource implements DonationRemoteDataSource {
  final List<FoodListingModel> _donations = [
    FoodListingModel(
      id: const Uuid().v4(),
      donorId: 'mock_donor_1',
      foodName: 'Wedding Feast Leftovers',
      category: 'Cooked Food',
      description: 'Rice, dal, paneer curry, and naan from a wedding.',
      quantityKg: 20.0,
      estimatedServings: 50,
      pickupStartTime: DateTime.now(),
      pickupEndTime: DateTime.now().add(const Duration(hours: 4)),
      expiryTime: DateTime.now().add(const Duration(hours: 6)),
      pickupAddress: 'Grand Palace Hotel, 123 Main St, Indore',
      latitude: 22.7196,
      longitude: 75.8577,
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      imageUrls: const [
        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80'
      ],
    ),
    FoodListingModel(
      id: const Uuid().v4(),
      donorId: 'mock_donor_1',
      foodName: 'Fresh Baked Bread & Buns',
      category: 'Bakery',
      description: 'Extra loaves of bread and pav from today\'s batch.',
      quantityKg: 5.0,
      estimatedServings: 20,
      pickupStartTime: DateTime.now(),
      pickupEndTime: DateTime.now().add(const Duration(hours: 2)),
      expiryTime: DateTime.now().add(const Duration(days: 2)),
      pickupAddress: 'Sunny Bakery, 456 Oak St, Indore',
      latitude: 22.7200,
      longitude: 75.8600,
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      imageUrls: const [
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80'
      ],
    ),
    FoodListingModel(
      id: const Uuid().v4(),
      donorId: 'mock_donor_2',
      foodName: 'Corporate Event Samosas',
      category: 'Snacks',
      description: 'Leftover samosas and kachoris from a corporate event.',
      quantityKg: 3.0,
      estimatedServings: 15,
      pickupStartTime: DateTime.now(),
      pickupEndTime: DateTime.now().add(const Duration(hours: 1)),
      expiryTime: DateTime.now().add(const Duration(hours: 3)),
      pickupAddress: 'Tech Park, Building 3, Indore',
      latitude: 22.7250,
      longitude: 75.8650,
      status: 'accepted',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      imageUrls: const [
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80'
      ],
    ),
    FoodListingModel(
      id: const Uuid().v4(),
      donorId: 'mock_donor_3',
      foodName: 'Fresh Vegetables Bundle',
      category: 'Raw Ingredients',
      description: 'Slightly bruised tomatoes, potatoes, and onions, perfectly edible.',
      quantityKg: 15.0,
      estimatedServings: 40,
      pickupStartTime: DateTime.now(),
      pickupEndTime: DateTime.now().add(const Duration(hours: 5)),
      expiryTime: DateTime.now().add(const Duration(days: 3)),
      pickupAddress: 'Choithram Mandi, Indore',
      latitude: 22.6860,
      longitude: 75.8560,
      status: 'available',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      imageUrls: const [
        'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=800&q=80'
      ],
    ),
  ];

  @override
  Future<FoodListingModel> createDonation({
    required String donorId,
    required String foodName,
    String? category,
    String? description,
    int? estimatedServings,
    String? pickupAddress,
    DateTime? expiryTime,
    List<File> images = const [],
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final newListing = FoodListingModel(
      id: const Uuid().v4(),
      donorId: donorId,
      foodName: foodName,
      category: category,
      description: description,
      estimatedServings: estimatedServings,
      pickupAddress: pickupAddress,
      expiryTime: expiryTime,
      status: 'available',
      createdAt: DateTime.now(),
      imageUrls: images.isNotEmpty 
          ? ['https://images.unsplash.com/photo-1493770348161-369560ae357d?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80']
          : [],
    );

    _donations.insert(0, newListing);
    return newListing;
  }

  @override
  Future<List<FoodListingModel>> getDonorDonations(String donorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _donations.where((d) => d.donorId == donorId).toList();
  }

  @override
  Future<List<FoodListingModel>> getAvailableDonations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _donations.where((d) => d.status == 'available').toList();
  }

  @override
  Future<List<FoodListingModel>> getNgoAcceptedDonations(String ngoProfileId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _donations.where((d) => d.status == 'accepted' && d.organizationId == ngoProfileId).toList();
  }

  @override
  Future<void> acceptDonation({
    required String listingId,
    required String ngoProfileId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _donations.indexWhere((d) => d.id == listingId);
    if (index != -1) {
      final old = _donations[index];
      _donations[index] = FoodListingModel(
        id: old.id,
        donorId: old.donorId,
        organizationId: ngoProfileId, // Mock usage
        foodName: old.foodName,
        category: old.category,
        description: old.description,
        quantityKg: old.quantityKg,
        estimatedServings: old.estimatedServings,
        pickupStartTime: old.pickupStartTime,
        pickupEndTime: old.pickupEndTime,
        expiryTime: old.expiryTime,
        pickupAddress: old.pickupAddress,
        latitude: old.latitude,
        longitude: old.longitude,
        status: 'accepted',
        createdAt: old.createdAt,
        imageUrls: old.imageUrls,
      );
    }
  }
}
