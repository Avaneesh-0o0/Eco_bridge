import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_listing_model.dart';
import 'package:path/path.dart' as p;

abstract class DonationRemoteDataSource {
  Future<FoodListingModel> createDonation({
    required String donorId,
    required String foodName,
    String? category,
    String? description,
    int? estimatedServings,
    String? pickupAddress,
    DateTime? expiryTime,
    List<File> images = const [],
  });

  Future<List<FoodListingModel>> getDonorDonations(String donorId);

  Future<List<FoodListingModel>> getAvailableDonations();
  Future<List<FoodListingModel>> getNgoAcceptedDonations(String ngoProfileId);

  Future<void> acceptDonation({
    required String listingId,
    required String ngoProfileId,
  });
}

class DonationRemoteDataSourceImpl implements DonationRemoteDataSource {
  final SupabaseClient client;

  DonationRemoteDataSourceImpl(this.client);

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
    // 1. Insert listing
    final listingData = {
      'donor_id': donorId,
      'food_name': foodName,
      'category': category,
      'description': description,
      'estimated_servings': estimatedServings,
      'pickup_address': pickupAddress,
      'expiry_time': expiryTime?.toIso8601String(),
      'status': 'available',
    };

    final listingResponse = await client
        .from('food_listings')
        .insert(listingData)
        .select()
        .single();
        
    final listingId = listingResponse['id'] as String;
    
    // 2. Upload images
    List<String> imageUrls = [];
    for (var image in images) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
      final path = '$donorId/$listingId/$fileName';
      
      await client.storage.from('food-images').upload(path, image);
      final imageUrl = client.storage.from('food-images').getPublicUrl(path);
      
      await client.from('food_images').insert({
        'listing_id': listingId,
        'image_url': imageUrl,
      });
      
      imageUrls.add(imageUrl);
    }
    
    listingResponse['food_images'] = imageUrls.map((e) => {'image_url': e}).toList();

    return FoodListingModel.fromJson(listingResponse);
  }

  @override
  Future<List<FoodListingModel>> getDonorDonations(String donorId) async {
    final response = await client
        .from('food_listings')
        .select('*, food_images(image_url)')
        .eq('donor_id', donorId)
        .order('created_at', ascending: false);
        
    return (response as List).map((e) => FoodListingModel.fromJson(e)).toList();
  }

  @override
  Future<List<FoodListingModel>> getAvailableDonations() async {
    final response = await client
        .from('food_listings')
        .select('*, food_images(image_url), profiles(full_name, phone)')
        .eq('status', 'available')
        .order('created_at', ascending: false);
        
    return (response as List).map((e) => FoodListingModel.fromJson(e)).toList();
  }

  @override
  Future<void> acceptDonation({
    required String listingId,
    required String ngoProfileId,
  }) async {
    // 1. Get or create NGO organization and ngo_details
    // First, check if organization_members exists for this profile
    final memberResponse = await client
        .from('organization_members')
        .select('organization_id')
        .eq('profile_id', ngoProfileId)
        .maybeSingle();

    String? orgId;
    if (memberResponse != null) {
      orgId = memberResponse['organization_id'] as String;
    } else {
      // Create organization
      final orgResponse = await client.from('organizations').insert({
        'organization_name': 'My NGO',
        'organization_type': 'ngo',
      }).select().single();
      
      orgId = orgResponse['id'] as String;
      
      // Link member
      await client.from('organization_members').insert({
        'organization_id': orgId,
        'profile_id': ngoProfileId,
        'role_name': 'admin',
      });
    }

    // Ensure ngo_details exists
    final ngoDetailsResponse = await client
        .from('ngo_details')
        .select('id')
        .eq('organization_id', orgId)
        .maybeSingle();

    String? ngoId;
    if (ngoDetailsResponse != null) {
      ngoId = ngoDetailsResponse['id'] as String;
    } else {
      final detailsResponse = await client.from('ngo_details').insert({
        'organization_id': orgId,
      }).select().single();
      ngoId = detailsResponse['id'] as String;
    }

    // 2. Create donation request
    await client.from('donation_requests').insert({
      'listing_id': listingId,
      'ngo_id': ngoId,
      'status': 'accepted',
    });

    // 3. Update listing status
    await client
        .from('food_listings')
        .update({'status': 'accepted'})
        .eq('id', listingId);
        
    // 4. Create tracking event
    await client.from('tracking_events').insert({
      'listing_id': listingId,
      'event_type': 'accepted',
      'event_description': 'Donation accepted by NGO',
      'created_by': ngoProfileId,
    });
  }

  @override
  Future<List<FoodListingModel>> getNgoAcceptedDonations(String ngoProfileId) async {
    // This is just a placeholder since we mainly use the mock data anyway
    final response = await client
        .from('food_listings')
        .select('*, donation_requests!inner(*)')
        .eq('donation_requests.status', 'accepted')
        .eq('donation_requests.ngo_id', ngoProfileId) // simplistic check
        .order('created_at', ascending: false);

    return (response as List).map((json) => FoodListingModel.fromJson(json)).toList();
  }
}
