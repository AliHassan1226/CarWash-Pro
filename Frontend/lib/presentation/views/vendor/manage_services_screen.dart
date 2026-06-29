import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/data/models/order.dart';
import 'package:car_wash_app/presentation/viewmodels/vendor_viewmodel.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionSubscription;
  LatLng? _vendorLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorViewModel>().getVendorOrders();
    });
    _startLiveLocationTracking();
  }

  Future<void> _startLiveLocationTracking() async {
    if (!mounted) return;
    setState(() {});

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      return;
    }

    try {
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      if (mounted) {
        final currentLocation = LatLng(
          currentPosition.latitude,
          currentPosition.longitude,
        );
        setState(() {
          _vendorLocation = currentLocation;
        });
        _mapController.move(currentLocation, 15);
      }
    } catch (_) {
      if (mounted) {
        setState(() {});
      }
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
          _vendorLocation = currentLocation;
        });
        _mapController.move(currentLocation, 13);
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        elevation: 0,
      ),
      body: Consumer<VendorViewModel>(
        builder: (context, vendorViewModel, _) {
          return Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: SizedBox.expand(
              child: _buildVendorMapCard(context, vendorViewModel.vendorOrders),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorMapCard(BuildContext context, List<Order> vendorOrders) {
    final stationOrders = vendorOrders
        .where((order) => order.latitude != null && order.longitude != null)
        .toList();
    final ordersByLocation = <String, List<Order>>{};
    for (final order in stationOrders) {
      final key = _locationKey(order.latitude!, order.longitude!);
      ordersByLocation.putIfAbsent(key, () => <Order>[]).add(order);
    }
    final groupedStationOrders = ordersByLocation.values.toList();

    final initialCenter = groupedStationOrders.isNotEmpty
        ? LatLng(
            groupedStationOrders.first.first.latitude!,
            groupedStationOrders.first.first.longitude!,
          )
        : (_vendorLocation ?? const LatLng(31.5204, 74.3587));

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: const [AppTheme.shadowSmall],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.car_wash_app',
              ),
              MarkerLayer(
                markers: <Marker>[
                  ...groupedStationOrders.map(
                    (locationOrders) => Marker(
                      point: LatLng(
                        locationOrders.first.latitude!,
                        locationOrders.first.longitude!,
                      ),
                      width: 150,
                      height: 68,
                      child: GestureDetector(
                        onTap: () => _showLocationOrdersSheet(context, locationOrders),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 130),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSmall,
                                  ),
                                  boxShadow: const [AppTheme.shadowSmall],
                                ),
                                child: Text(
                                  (locationOrders.first.serviceName == null ||
                                          locationOrders.first.serviceName!
                                              .trim()
                                              .isEmpty)
                                      ? 'Service Station'
                                      : locationOrders.first.serviceName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Icon(
                              Icons.location_on,
                              color: AppTheme.errorColor,
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (groupedStationOrders.isEmpty)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(AppTheme.spacing12),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing12,
                  vertical: AppTheme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  boxShadow: const [AppTheme.shadowSmall],
                ),
                child: Text(
                  'No saved station locations found in orders.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _locationKey(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
  }

  Future<void> _showLocationOrdersSheet(
    BuildContext context,
    List<Order> locationOrders,
  ) async {
    if (locationOrders.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final stationLabel = (locationOrders.first.serviceName == null ||
                locationOrders.first.serviceName!.trim().isEmpty)
            ? 'Service Station'
            : locationOrders.first.serviceName!;
        final lat = locationOrders.first.latitude!;
        final lng = locationOrders.first.longitude!;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$stationLabel (${locationOrders.length} orders)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: locationOrders.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppTheme.spacing8),
                      itemBuilder: (context, index) {
                        final order = locationOrders[index];
                        return InkWell(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          onTap: () {
                            _showIndividualOrderDetails(context, order);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacing12),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                              boxShadow: const [AppTheme.shadowSmall],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: AppTheme.spacing4),
                                Text('Customer: ${order.customerName}'),
                                Text(
                                  'Amount: Rs ${order.totalAmount.toStringAsFixed(0)}',
                                ),
                                Text('Status: ${order.statusDisplay}'),
                                const SizedBox(height: AppTheme.spacing8),
                                Text(
                                  'Tap to view full details',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showIndividualOrderDetails(
    BuildContext context,
    Order order,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id.substring(0, 8).toUpperCase()}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailItem('Customer', order.customerName),
              _detailItem(
                'Service',
                (order.serviceName == null || order.serviceName!.trim().isEmpty)
                    ? order.serviceId
                    : order.serviceName!,
              ),
              _detailItem('Status', order.statusDisplay),
              _detailItem(
                'Amount',
                'Rs ${order.totalAmount.toStringAsFixed(0)}',
              ),
              _detailItem('Phone', order.customerPhone),
              _detailItem(
                'Address',
                (order.address == null || order.address!.trim().isEmpty)
                    ? 'Not provided'
                    : order.address!,
              ),
              _detailItem(
                'Date',
                '${order.scheduledDate.day}/${order.scheduledDate.month}/${order.scheduledDate.year}',
              ),
              if (order.selectedServices != null &&
                  order.selectedServices!.isNotEmpty)
                _detailItem(
                  'Selected Services',
                  order.selectedServices!.join(', '),
                ),
              if (order.notes != null && order.notes!.trim().isNotEmpty)
                _detailItem('Notes', order.notes!),
              if (order.latitude != null && order.longitude != null)
                _detailItem(
                  'Coordinates',
                  '${order.latitude!.toStringAsFixed(6)}, ${order.longitude!.toStringAsFixed(6)}',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}