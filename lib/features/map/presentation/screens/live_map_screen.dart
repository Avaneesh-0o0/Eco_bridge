import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

class LiveMapScreen extends StatelessWidget {
  const LiveMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Indore, India coordinates as base
    final baseLat = 22.7196;
    final baseLng = 75.8577;

    final markers = <Marker>[
      // NGOs
      _buildMarker(baseLat + 0.01, baseLng - 0.01, Icons.health_and_safety, Colors.green, 'Asha Foundation'),
      _buildMarker(baseLat - 0.015, baseLng + 0.02, Icons.health_and_safety, Colors.green, 'Jeevan Seva'),
      
      // Donors
      _buildMarker(baseLat + 0.02, baseLng + 0.01, Icons.restaurant, Colors.orange, 'Sharma Sweets'),
      _buildMarker(baseLat - 0.005, baseLng - 0.02, Icons.local_pizza, Colors.orange, 'Raju Dhaba'),
      _buildMarker(baseLat + 0.03, baseLng - 0.015, Icons.bakery_dining, Colors.orange, 'Indore Bakery'),
      
      // Volunteers (Active)
      _buildMarker(baseLat + 0.005, baseLng + 0.005, Icons.directions_car, Colors.blue, 'Rahul Singh'),
      _buildMarker(baseLat - 0.02, baseLng - 0.005, Icons.directions_bike, Colors.blue, 'Priya Patel'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Community Map'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(baseLat, baseLng),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.foodbridge.app',
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),
          // Legend
          Positioned(
            bottom: AppSizes.p24,
            left: AppSizes.p16,
            right: AppSizes.p16,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem(Icons.restaurant, Colors.orange, 'Donors'),
                  _buildLegendItem(Icons.health_and_safety, Colors.green, 'NGOs'),
                  _buildLegendItem(Icons.directions_car, Colors.blue, 'Volunteers'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Marker _buildMarker(double lat, double lng, IconData icon, Color color, String label) {
    return Marker(
      point: LatLng(lat, lng),
      width: 100,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Icon(icon, color: color, size: 36),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
