import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/delivery_task_model.dart';

abstract class VolunteerRemoteDataSource {
  Future<List<DeliveryTaskModel>> getAvailableDeliveries();
  Future<List<DeliveryTaskModel>> getActiveDeliveries(String volunteerProfileId);
  
  Future<void> acceptDelivery({
    required String donationRequestId,
    required String volunteerProfileId,
    required String listingId,
  });

  Future<void> updateDeliveryStatus({
    required String deliveryTaskId,
    required String donationRequestId,
    required String listingId,
    required String volunteerProfileId,
    required String newStatus, // 'picked_up' or 'delivered'
  });
}

class VolunteerRemoteDataSourceImpl implements VolunteerRemoteDataSource {
  final SupabaseClient client;

  VolunteerRemoteDataSourceImpl(this.client);

  Future<String> _getOrCreateVolunteerId(String profileId) async {
    final response = await client
        .from('volunteers')
        .select('id')
        .eq('profile_id', profileId)
        .maybeSingle();

    if (response != null) {
      return response['id'] as String;
    }

    final newVol = await client
        .from('volunteers')
        .insert({'profile_id': profileId})
        .select('id')
        .single();
    
    return newVol['id'] as String;
  }

  @override
  Future<List<DeliveryTaskModel>> getAvailableDeliveries() async {
    final response = await client
        .from('donation_requests')
        .select('''
          *,
          food_listings(*, food_images(image_url)),
          ngo_details(organizations(organization_name))
        ''')
        .filter('volunteer_id', 'is', 'null')
        .eq('status', 'accepted')
        .order('requested_at', ascending: false);

    return (response as List).map((e) => DeliveryTaskModel.fromJson(e)).toList();
  }

  @override
  Future<List<DeliveryTaskModel>> getActiveDeliveries(String volunteerProfileId) async {
    final volId = await _getOrCreateVolunteerId(volunteerProfileId);

    final response = await client
        .from('donation_requests')
        .select('''
          *,
          food_listings(*, food_images(image_url)),
          ngo_details(organizations(organization_name)),
          delivery_tasks(*)
        ''')
        .eq('volunteer_id', volId)
        .neq('status', 'delivered')
        .order('requested_at', ascending: false);

    return (response as List).map((e) => DeliveryTaskModel.fromJson(e)).toList();
  }

  @override
  Future<void> acceptDelivery({
    required String donationRequestId,
    required String volunteerProfileId,
    required String listingId,
  }) async {
    final volId = await _getOrCreateVolunteerId(volunteerProfileId);

    // Update donation_request with volunteer
    await client
        .from('donation_requests')
        .update({'volunteer_id': volId})
        .eq('id', donationRequestId);

    // Create delivery_task
    await client.from('delivery_tasks').insert({
      'donation_request_id': donationRequestId,
      'volunteer_id': volId,
      'task_status': 'accepted',
    });

    // Update food_listing status
    await client
        .from('food_listings')
        .update({'status': 'pickup_assigned'})
        .eq('id', listingId);

    // Tracking event
    await client.from('tracking_events').insert({
      'listing_id': listingId,
      'event_type': 'pickup_assigned',
      'event_description': 'A volunteer has accepted the delivery task',
      'created_by': volunteerProfileId,
    });
  }

  @override
  Future<void> updateDeliveryStatus({
    required String deliveryTaskId,
    required String donationRequestId,
    required String listingId,
    required String volunteerProfileId,
    required String newStatus,
  }) async {
    // Update delivery_tasks
    final updateData = {'task_status': newStatus};
    if (newStatus == 'picked_up') {
      updateData['picked_up_at'] = DateTime.now().toIso8601String();
    } else if (newStatus == 'delivered') {
      updateData['delivered_at'] = DateTime.now().toIso8601String();
    }

    await client
        .from('delivery_tasks')
        .update(updateData)
        .eq('id', deliveryTaskId);

    if (newStatus == 'delivered') {
      // Update donation_requests
      await client
          .from('donation_requests')
          .update({
            'status': 'delivered',
            'delivered_at': DateTime.now().toIso8601String()
          })
          .eq('id', donationRequestId);

      // Update food_listings
      await client
          .from('food_listings')
          .update({'status': 'delivered'})
          .eq('id', listingId);
    } else if (newStatus == 'picked_up') {
      await client
          .from('food_listings')
          .update({'status': 'picked_up'})
          .eq('id', listingId);
    }

    // Add tracking event
    await client.from('tracking_events').insert({
      'listing_id': listingId,
      'event_type': newStatus,
      'event_description': newStatus == 'picked_up' 
          ? 'Food picked up by volunteer' 
          : 'Food delivered to NGO',
      'created_by': volunteerProfileId,
    });
  }
}
