import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';

class HotspotScreen extends StatefulWidget {
  const HotspotScreen({super.key});

  @override
  State<HotspotScreen> createState() => _HotspotScreenState();
}

class _HotspotScreenState extends State<HotspotScreen> {
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _statusMessage = "Locating you...";
  final MapController _mapController = MapController();
  List<CircleMarker> _hotspots = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _statusMessage = "Location services are disabled.";
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _statusMessage = "Location permissions are denied";
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _statusMessage =
            "Location permissions are permanently denied, we cannot request permissions.";
        _isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = latLng;
        _isLoading = false;
        _hotspots = _generateRandomHotspots(latLng);
      });
      
      // Move map to location
    } catch (e) {
      setState(() {
        _statusMessage = "Error getting location: $e";
        _isLoading = false;
      });
    }
  }

  List<CircleMarker> _generateRandomHotspots(LatLng center) {
    final random = Random();
    return List.generate(5, (index) {
      // Generate random offset within ~1km
      final latOffset = (random.nextDouble() - 0.5) * 0.02;
      final lngOffset = (random.nextDouble() - 0.5) * 0.02;
      
      return CircleMarker(
        point: LatLng(center.latitude + latOffset, center.longitude + lngOffset),
        radius: 100 + random.nextDouble() * 200, // 100-300m radius
        useRadiusInMeter: true,
        color: Colors.red.withValues(alpha: 0.3),
        borderColor: Colors.red,
        borderStrokeWidth: 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Hotspot Tracker"),
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? Container(
              color: const Color(0xFF0F2027),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.blueAccent),
                    const SizedBox(height: 20),
                    Text(_statusMessage,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition ?? const LatLng(3.1390, 101.6869), // Fallback to KL
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.mysj.nextgen',
                    ),
                    // Hotspots Layer
                    CircleLayer(circles: _hotspots),
                    // User Location Layer
                    if (_currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentPosition!,
                            width: 60,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(LucideIcons.user,
                                  color: Colors.white, size: 30),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                
                // Overlays
                SafeArea(
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E), // Solid dark color
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Search location...",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              icon: Icon(LucideIcons.search,
                                  color: Colors.white54),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      
                      // FAB to recenter
                      Padding(
                        padding: const EdgeInsets.only(right: 20, bottom: 20),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FloatingActionButton(
                            backgroundColor: Colors.blueAccent,
                            child: const Icon(LucideIcons.crosshair, color: Colors.white),
                            onPressed: () {
                              if (_currentPosition != null) {
                                _mapController.move(_currentPosition!, 15);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Glass Overlay Controls
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: GlassContainer(
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(20),
                    color: Colors.black.withOpacity(0.6), // Dark glass
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.alertTriangle, color: Colors.redAccent),
                            const SizedBox(width: 10),
                            Text("High Risk Areas Detected", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "You are currently in a generic safe zone. However, there are ${_hotspots.length} hotspots reported within 10km radius.",
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (){},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(vertical: 15)
                            ),
                            child: const Text("View Details"),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
