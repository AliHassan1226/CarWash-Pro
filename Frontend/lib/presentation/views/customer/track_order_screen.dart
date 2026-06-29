import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:http/http.dart' as http;

import 'package:car_wash_app/core/constants/api_endpoints.dart';
import 'package:car_wash_app/presentation/views/customer/place_order_screen.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  late TextEditingController _serviceSearchController;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _customerLocation;
  static const LatLng _vendorLocation = LatLng(31.5297, 74.3436);
  String? _locationError;
  bool _isPermissionIssue = false;
  bool _isServiceDisabled = false;
  bool _isSearchingNearby = false;
  String? _searchError;
  List<String> _searchWarnings = [];
  List<NearbyServiceLocation> _nearbyMarkers = [];

  @override
  void initState() {
    super.initState();
    _serviceSearchController = TextEditingController();
    _startLiveLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _serviceSearchController.dispose();
    super.dispose();
  }

  Future<void> _startLiveLocationTracking() async {
    if (!mounted) return;
    setState(() {
      _locationError = null;
      _isPermissionIssue = false;
      _isServiceDisabled = false;
    });

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _locationError = 'Location permission is required to track your order.';
        _isPermissionIssue = true;
      });
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _locationError = 'Turn on location services to track your order.';
        _isServiceDisabled = true;
      });
      return;
    }

    try {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null && mounted) {
        final lastKnownLocation = LatLng(
          lastKnownPosition.latitude,
          lastKnownPosition.longitude,
        );
        setState(() {
          _customerLocation = lastKnownLocation;
          _locationError = null;
        });
        _mapController.move(lastKnownLocation, 14);
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      if (!mounted) return;

      final currentLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _customerLocation = currentLocation;
        _locationError = null;
      });
      _mapController.move(currentLocation, 15);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationError = 'Unable to fetch current location.';
      });
    }

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen(
      (position) {
        if (!mounted) return;
        final currentLocation = LatLng(position.latitude, position.longitude);
        setState(() {
          _customerLocation = currentLocation;
          _locationError = null;
        });
        _mapController.move(currentLocation, 15);
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _locationError = 'Unable to fetch live location right now.';
        });
      },
    );
  }

  Future<void> _handleLocationFixAction() async {
    if (_isServiceDisabled) {
      await Geolocator.openLocationSettings();
    } else if (_isPermissionIssue) {
      await Geolocator.openAppSettings();
    }
  }

  Future<void> _searchNearbyServices(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchError = 'Type a service query first.';
      });
      return;
    }

    if (_customerLocation == null) {
      await _startLiveLocationTracking();
    }

    if (_customerLocation == null) {
      setState(() {
        _searchError =
            'Unable to get your current location. Please enable location and try again.';
      });
      return;
    }

    setState(() {
      _isSearchingNearby = true;
      _searchError = null;
      _searchWarnings = [];
    });

    try {
      final uri = Uri.parse(
        '${ApiEndpoints.aiAgentBaseUrl}${ApiEndpoints.aiNearbyServices}',
      );
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': trimmedQuery,
          'user_lat': _customerLocation!.latitude,
          'user_lng': _customerLocation!.longitude,
          'radius_m': 3000,
          'max_results': 12,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _searchError =
              'Nearby search failed (${response.statusCode}). Check backend server.';
          _nearbyMarkers = [];
        });
        return;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final warnings = (decoded['warnings'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
      final places = (decoded['places'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((item) => NearbyServiceLocation.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      setState(() {
        _nearbyMarkers = places;
        _searchWarnings = warnings;
        _searchError = places.isEmpty ? 'No nearby services found for this query.' : null;
      });

      if (places.isNotEmpty) {
        _mapController.move(LatLng(places.first.lat, places.first.lng), 14);
      }
    } catch (_) {
      setState(() {
        _nearbyMarkers = [];
        _searchWarnings = [];
        _searchError = 'Unable to contact AI nearby service API.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingNearby = false;
        });
      }
    }
  }

  void _showMarkerInfo(NearbyServiceLocation place) {
    String selectedPackage = 'full_service';
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: StatefulBuilder(
            builder: (context, setModalState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text('Service: ${place.serviceType.replaceAll('_', ' ')}'),
                Text('Distance: ${place.distanceMeters.toStringAsFixed(0)} m'),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Lat/Lng: ${place.lat.toStringAsFixed(6)}, ${place.lng.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppTheme.spacing12),
                Text(
                  'Select Package',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Wrap(
                  spacing: AppTheme.spacing8,
                  children: [
                    ChoiceChip(
                      label: const Text('Half Service'),
                      selected: selectedPackage == 'half_service',
                      onSelected: (_) =>
                          setModalState(() => selectedPackage = 'half_service'),
                    ),
                    ChoiceChip(
                      label: const Text('Full Service'),
                      selected: selectedPackage == 'full_service',
                      onSelected: (_) =>
                          setModalState(() => selectedPackage = 'full_service'),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (_) => PlaceOrderScreen(
                            serviceId:
                                'nearby_${place.lat.toStringAsFixed(4)}_${place.lng.toStringAsFixed(4)}',
                            serviceName: place.name,
                            vendorName: 'Nearby Service Partner',
                            servicePrice:
                                selectedPackage == 'half_service' ? 900 : 1500,
                            serviceLatitude: place.lat,
                            serviceLongitude: place.lng,
                            serviceLocationLabel:
                                '${place.name} (${place.distanceMeters.toStringAsFixed(0)} m away)',
                          ),
                        ),
                      );
                    },
                    child: const Text('Proceed to Order'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _customerLocation == null
                ? _buildLocationPlaceholder(context)
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _customerLocation!,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.car_wash_app',
                      ),
                      MarkerLayer(markers: _buildMapMarkers()),
                    ],
                  ),
          ),
          if (_locationError != null)
            Positioned(
              bottom: AppTheme.spacing16,
              left: AppTheme.spacing16,
              right: AppTheme.spacing16,
              child: Material(
                color: AppTheme.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _locationError!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppTheme.spacing8,
                        runSpacing: AppTheme.spacing8,
                        children: [
                          ElevatedButton(
                            onPressed: _startLiveLocationTracking,
                            child: const Text('Retry'),
                          ),
                          if (_isServiceDisabled || _isPermissionIssue)
                            OutlinedButton(
                              onPressed: _handleLocationFixAction,
                              child: Text(
                                _isServiceDisabled
                                    ? 'Open Location Settings'
                                    : 'Open App Settings',
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: AppTheme.spacing16,
            left: AppTheme.spacing16,
            right: AppTheme.spacing16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: TextField(
                controller: _serviceSearchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchNearbyServices,
                decoration: InputDecoration(
                  hintText: 'Find washing, cleaning, polishing near me',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isSearchingNearby
                        ? null
                        : () => _searchNearbyServices(_serviceSearchController.text),
                  ),
                ),
              ),
            ),
          ),
          if (_isSearchingNearby)
            const Positioned(
              top: 84,
              left: 16,
              right: 16,
              child: LinearProgressIndicator(),
            ),
          if (_searchError != null)
            Positioned(
              top: 96,
              left: AppTheme.spacing16,
              right: AppTheme.spacing16,
              child: Material(
                elevation: 2,
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing12,
                    vertical: AppTheme.spacing8,
                  ),
                  child: Text(
                    _searchError!,
                    style: const TextStyle(color: AppTheme.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          if (_searchWarnings.isNotEmpty)
            Positioned(
              top: _searchError != null ? 154 : 96,
              left: AppTheme.spacing16,
              right: AppTheme.spacing16,
              child: Material(
                elevation: 2,
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _searchWarnings
                        .map(
                          (warning) => Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
                            child: Text(
                              '• $warning',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Marker> _buildMapMarkers() {
    final markers = <Marker>[
      Marker(
        point: _customerLocation!,
        width: 44,
        height: 44,
        child: const Icon(
          Icons.my_location,
          color: AppTheme.primaryColor,
          size: 34,
        ),
      ),
      const Marker(
        point: _vendorLocation,
        width: 44,
        height: 44,
        child: Icon(
          Icons.location_on,
          color: AppTheme.errorColor,
          size: 36,
        ),
      ),
    ];

    for (final place in _nearbyMarkers) {
      markers.add(
        Marker(
          point: LatLng(place.lat, place.lng),
          width: 64,
          height: 64,
          child: GestureDetector(
            onTap: () => _showMarkerInfo(place),
            child: const _RippleMarkerIcon(),
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildLocationPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_locationError == null) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Fetching your live location...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else ...[
              const Icon(
                Icons.location_off,
                color: AppTheme.errorColor,
                size: 34,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                _locationError!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NearbyServiceLocation {
  final String name;
  final String serviceType;
  final double lat;
  final double lng;
  final double distanceMeters;

  NearbyServiceLocation({
    required this.name,
    required this.serviceType,
    required this.lat,
    required this.lng,
    required this.distanceMeters,
  });

  factory NearbyServiceLocation.fromJson(Map<String, dynamic> json) {
    return NearbyServiceLocation(
      name: (json['name'] ?? 'Nearby Car Service').toString(),
      serviceType: (json['service_type'] ?? 'car_wash').toString(),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      distanceMeters: (json['distance_m'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class _RippleMarkerIcon extends StatefulWidget {
  const _RippleMarkerIcon();

  @override
  State<_RippleMarkerIcon> createState() => _RippleMarkerIconState();
}

class _RippleMarkerIconState extends State<_RippleMarkerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final wave = _controller.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 46 + (wave * 14),
              height: 46 + (wave * 14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryColor.withValues(alpha: 0.22 * (1 - wave)),
              ),
            ),
            const Icon(
              Icons.local_car_wash,
              color: AppTheme.secondaryColor,
              size: 34,
            ),
          ],
        );
      },
    );
  }
}
