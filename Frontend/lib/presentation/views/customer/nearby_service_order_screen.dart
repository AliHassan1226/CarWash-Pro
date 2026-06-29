import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/customer_viewmodel.dart';

class NearbyServiceOrderScreen extends StatefulWidget {
  final String placeName;
  final String serviceType;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String initialPackage;

  const NearbyServiceOrderScreen({
    super.key,
    required this.placeName,
    required this.serviceType,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.initialPackage,
  });

  @override
  State<NearbyServiceOrderScreen> createState() => _NearbyServiceOrderScreenState();
}

class _NearbyServiceOrderScreenState extends State<NearbyServiceOrderScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedPackage = 'full_service';

  static const double _fullServicePrice = 1500;
  static const double _halfServicePrice = 900;

  @override
  void initState() {
    super.initState();
    _selectedPackage = widget.initialPackage;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 45)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _acceptService() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select service date and time')),
      );
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter service address')),
      );
      return;
    }

    final totalAmount =
        _selectedPackage == 'half_service' ? _halfServicePrice : _fullServicePrice;
    final viewModel = context.read<CustomerViewModel>();
    final syntheticId =
        'nearby_${widget.latitude.toStringAsFixed(4)}_${widget.longitude.toStringAsFixed(4)}';

    final success = await viewModel.placeOrder(
      serviceId: syntheticId,
      vendorId: 'nearby_ai_vendor',
      serviceName: widget.placeName,
      vendorName: 'Nearby Service Partner',
      totalAmount: totalAmount,
      scheduledDate: _selectedDate!,
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      selectedServices: [widget.serviceType, _selectedPackage],
      latitude: widget.latitude,
      longitude: widget.longitude,
      servicePackage: _selectedPackage,
      metadata: {
        'source': 'ai_nearby',
        'distance_m': widget.distanceMeters,
        'service_type': widget.serviceType,
      },
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service accepted and order created')),
      );
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to create order')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Nearby Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.placeName, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppTheme.spacing8),
                  Text('Type: ${widget.serviceType.replaceAll('_', ' ')}'),
                  Text('Distance: ${widget.distanceMeters.toStringAsFixed(0)} m'),
                  Text(
                    'Lat/Lng: ${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text('Choose Package', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTheme.spacing8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'half_service',
                  label: Text('Half Service'),
                  icon: Icon(Icons.tune),
                ),
                ButtonSegment<String>(
                  value: 'full_service',
                  label: Text('Full Service'),
                  icon: Icon(Icons.auto_awesome),
                ),
              ],
              selected: {_selectedPackage},
              onSelectionChanged: (selection) {
                setState(() => _selectedPackage = selection.first);
              },
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              _selectedPackage == 'half_service'
                  ? 'Selected: Half Service - Rs 900'
                  : 'Selected: Full Service - Rs 1500',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacing12),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.schedule),
              label: Text(
                _selectedDate == null
                    ? 'Select Date & Time'
                    : _selectedDate.toString(),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Enter service address',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _acceptService,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Accept Service'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
