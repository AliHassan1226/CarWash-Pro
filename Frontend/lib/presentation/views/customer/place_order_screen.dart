import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/customer_viewmodel.dart';
import 'package:car_wash_app/presentation/views/customer/order_history_screen.dart';

class PlaceOrderScreen extends StatefulWidget {
  final String? serviceId;
  final String? serviceName;
  final String? vendorName;
  final double? servicePrice;
  final double? serviceLatitude;
  final double? serviceLongitude;
  final String? serviceLocationLabel;
  
  const PlaceOrderScreen({
    super.key,
    this.serviceId,
    this.serviceName,
    this.vendorName,
    this.servicePrice,
    this.serviceLatitude,
    this.serviceLongitude,
    this.serviceLocationLabel,
  });

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  late TextEditingController _addressController;
  late TextEditingController _carDetailsController;
  late TextEditingController _notesController;
  
  DateTime? _selectedDate;
  String? _selectedTime;
  bool _acceptTerms = false;
  final List<String> _selectedServices = [];
  static const String _defaultService = 'Washing';
  static const double _additionalServiceFee = 300;

  double _getBasePrice(dynamic service) {
    return service?.finalPrice ?? widget.servicePrice ?? 1000;
  }

  double _calculateTotalAmount(dynamic service) {
    final base = _getBasePrice(service);
    final additionalCount = _selectedServices
        .where((item) => item != _defaultService)
        .length;
    return base + (additionalCount * _additionalServiceFee);
  }

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _carDetailsController = TextEditingController();
    _notesController = TextEditingController();
    _selectedServices.add(_defaultService);
    if (widget.serviceLocationLabel != null &&
        widget.serviceLocationLabel!.isNotEmpty) {
      _addressController.text = widget.serviceLocationLabel!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _carDetailsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time.format(context);
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your address')),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms and conditions')),
      );
      return;
    }

    final viewModel = context.read<CustomerViewModel>();
    final matchingServices =
        viewModel.services.where((s) => s.id == widget.serviceId).toList();
    final service = matchingServices.isNotEmpty ? matchingServices.first : null;

    final orderServiceId =
        service?.id ??
        widget.serviceId ??
        'nearby_${DateTime.now().millisecondsSinceEpoch}';
    final orderVendorId = service?.vendorId ?? 'nearby_ai_vendor';
    final orderServiceName =
        service?.name ?? widget.serviceName ?? 'Nearby Car Wash Service';
    final orderVendorName = widget.vendorName ?? 'Nearby Service Partner';
    final orderAmount = _calculateTotalAmount(service);

    final success = await viewModel.placeOrder(
      serviceId: orderServiceId,
      vendorId: orderVendorId,
      serviceName: orderServiceName,
      vendorName: orderVendorName,
      totalAmount: orderAmount,
      scheduledDate: _selectedDate!,
      address: _addressController.text,
      carDetails: _carDetailsController.text,
      notes: _notesController.text,
      selectedServices: _selectedServices,
      latitude: widget.serviceLatitude,
      longitude: widget.serviceLongitude,
      metadata: {
        'from_map_marker': widget.serviceLatitude != null &&
            widget.serviceLongitude != null,
        if (widget.serviceLocationLabel != null)
          'service_location_label': widget.serviceLocationLabel,
      },
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully')),
      );
      // Refresh orders in VM
      await viewModel.getMyOrders();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to place order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Summary Card
              Consumer<CustomerViewModel>(
                builder: (context, viewModel, _) {
                  final matchingServices =
                      viewModel.services.where((s) => s.id == widget.serviceId).toList();
                  final service =
                      matchingServices.isNotEmpty ? matchingServices.first : null;

                  return Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                service?.name ?? widget.serviceName ?? 'Nearby Service',
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing8),
                            Text(
                              'Rs ${_calculateTotalAmount(service).toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 16, color: AppTheme.mediumGrey),
                            const SizedBox(width: AppTheme.spacing8),
                            Text(
                              service?.durationText ?? 'Based on your selected slot',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppTheme.spacing24),

              // Service Selection
              Text(
                'Select Service Type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacing12),
              Wrap(
                spacing: 8,
                children: [
                   _buildServiceChip('Washing'),
                   _buildServiceChip('Polishing'),
                   _buildServiceChip('Cleaning'),
                   _buildServiceChip('Drying'),
                ],
              ),

              const SizedBox(height: AppTheme.spacing24),

              // Booking Details
              Text(
                'Booking Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: AppTheme.spacing12),

              // Date Selection
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: _selectedDate != null
                          ? AppTheme.primaryColor
                          : AppTheme.lightGrey,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}'
                                  : 'Select Date',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing12),

              // Time Selection
              GestureDetector(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: _selectedTime != null
                          ? AppTheme.primaryColor
                          : AppTheme.lightGrey,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppTheme.primaryColor),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            Text(
                              _selectedTime ?? 'Select Time',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing24),

              // Additional Details
              Text(
                'Additional Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: AppTheme.spacing12),

              // Address
              if (widget.serviceLatitude != null &&
                  widget.serviceLongitude != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacing12),
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Service Location',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        widget.serviceLocationLabel ?? 'Nearby service from map',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        '${widget.serviceLatitude!.toStringAsFixed(6)}, ${widget.serviceLongitude!.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],

              // Address
              TextField(
                controller: _addressController,
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Service Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),

              const SizedBox(height: AppTheme.spacing12),

              // Car Details
              TextField(
                controller: _carDetailsController,
                decoration: const InputDecoration(
                  hintText: 'Car Model & Color (Optional)',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
              ),

              const SizedBox(height: AppTheme.spacing12),

              // Notes
              TextField(
                controller: _notesController,
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Special Requirements (Optional)',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
              ),

              const SizedBox(height: AppTheme.spacing24),

              // Terms & Conditions
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the terms and conditions',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacing24),

              // Total and Button
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Consumer<CustomerViewModel>(
                          builder: (context, viewModel, _) {
                            final matchingServices = viewModel.services
                                .where((s) => s.id == widget.serviceId)
                                .toList();
                            final service = matchingServices.isNotEmpty
                                ? matchingServices.first
                                : null;
                            return Text(
                              'Rs ${_calculateTotalAmount(service).toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _placeOrder,
                        child: const Text('Accept Order'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacing24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceChip(String label) {
    final isSelected = _selectedServices.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (label == _defaultService) {
          return;
        }
        setState(() {
          if (selected) {
            _selectedServices.add(label);
          } else {
            _selectedServices.remove(label);
          }
        });
      },
      showCheckmark: true,
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }
}