import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  final TextEditingController _searchController = TextEditingController();
  List<CircleMarker> _hotspots = [];
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _determinePosition();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _showProximityAlert() async {
    const androidDetails = AndroidNotificationDetails(
      'hotspot_alerts',
      'Hotspot Alerts',
      channelDescription: 'Alerts when near COVID-19 hotspots',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    
    await _notificationsPlugin.show(
      0,
      'High Risk Area Detected',
      'You are within 500m of a reported hotspot. Please maintain social distancing.',
      details,
    );
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
      
      // Check for proximity (simulated check)
      if (_hotspots.isNotEmpty) {
        _showProximityAlert();
      }
      
    } catch (e) {
      setState(() {
        _statusMessage = "Error getting location: $e";
        _isLoading = false;
      });
    }
  }
  
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    // 1. Try Native Geocoding
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        _moveToLocation(locations.first.latitude, locations.first.longitude);
        return;
      }
    } catch (e) {
      debugPrint("Native geocoding failed: $e");
    }

    // 2. Fallback to OpenStreetMap Nominatim API
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
      final response = await http.get(url, headers: {'User-Agent': 'com.mysj.nextgen'});
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          _moveToLocation(lat, lon);
          return;
        }
      }
    } catch (e) {
      debugPrint("Nominatim geocoding failed: $e");
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location not found: $query")));
    }
  }

  void _moveToLocation(double lat, double lng) {
    final latLng = LatLng(lat, lng);
    _mapController.move(latLng, 15);
    setState(() {
        // Generate new fictional hotspots for the searched area
        _hotspots = _generateRandomHotspots(latLng);
    });
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
    // Count hotspots "near" the center of the map
    int riskCount = _hotspots.length; 

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
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            onSubmitted: _searchLocation,
                            decoration: InputDecoration(
                              hintText: "Search location...",
                              hintStyle: const TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              icon: const Icon(LucideIcons.search,
                                  color: Colors.white54),
                              suffixIcon: IconButton(
                                icon: const Icon(LucideIcons.arrowRight, color: Colors.blueAccent),
                                onPressed: () => _searchLocation(_searchController.text),
                              )
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

                // Improved Glass Overlay Controls
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: GlassContainer(
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(24),
                    color: Colors.black.withOpacity(0.85), // Darker for better contrast
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.2),
                                shape: BoxShape.circle
                              ),
                              child: const Icon(LucideIcons.alertTriangle, color: Colors.redAccent, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("High Risk Areas Nearby", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text("$riskCount Active Hotspots", style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "You are currently entering a zone with reported cases. Please wear a mask and sanitize frequently.",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, height: 1.4), // Increased size and contrast
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: (){},
                            icon: const Icon(LucideIcons.mapPin),
                            label: const Text("View Detailed Map"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
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
