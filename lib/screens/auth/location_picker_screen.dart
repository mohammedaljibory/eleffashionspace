import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
  }) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;
  String _address = 'جاري تحديد الموقع...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _isLoading = true;
    });

    final address = await LocationService.getAddressFromCoordinates(
      location.latitude,
      location.longitude,
    );

    setState(() {
      _address = address;
      _isLoading = false;
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'address': _address,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر موقع التوصيل'),
        backgroundColor: const Color(0xFF513E35),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: _onMapTapped,
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? const LatLng(21.3891, 39.8579), // Mecca as default
              zoom: 15,
            ),
            markers: _selectedLocation != null
                ? {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation!,
              ),
            }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // Address display
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'العنوان المحدد:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF513E35),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_isLoading)
                    const LinearProgressIndicator(
                      color: Color(0xFF513E35),
                    ),
                ],
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _selectedLocation != null ? _confirmLocation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF513E35),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'تأكيد الموقع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}