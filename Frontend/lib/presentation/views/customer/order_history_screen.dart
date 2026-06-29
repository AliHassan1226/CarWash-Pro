import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/customer_viewmodel.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  Future<void> _showOrderDetails(dynamic order) async {
    final orderId = order.id?.toString() ?? '';
    final shortOrderId = orderId.length >= 8 ? orderId.substring(0, 8) : orderId;
    final serviceName = order.serviceName?.toString() ?? 'Car Wash Service';
    final status = order.status?.toString() ?? 'pending';
    final vendorName = order.vendorName?.toString() ?? 'Nearby Service Partner';
    final address = order.address?.toString() ?? 'Not provided';
    final totalAmount = (order.totalAmount as num?)?.toDouble() ?? 0.0;
    final selectedServices = order.selectedServices is List
        ? (order.selectedServices as List).map((e) => e.toString()).toList()
        : <String>[];

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${shortOrderId.toUpperCase()}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Service: $serviceName'),
              const SizedBox(height: AppTheme.spacing8),
              Text('Status: ${_formatStatus(status)}'),
              const SizedBox(height: AppTheme.spacing8),
              Text('Vendor: $vendorName'),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Date: ${order.scheduledDate.day}/${order.scheduledDate.month}/${order.scheduledDate.year}',
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text('Address: $address'),
              const SizedBox(height: AppTheme.spacing8),
              if (selectedServices.isNotEmpty)
                Text('Selected: ${selectedServices.join(', ')}'),
              const SizedBox(height: AppTheme.spacing8),
              Text('Total: Rs ${totalAmount.toStringAsFixed(2)}'),
              if (order.rating != null) ...[
                const SizedBox(height: AppTheme.spacing8),
                Text('Rating: ${order.rating}/5'),
              ],
              if (order.review != null &&
                  order.review.toString().trim().isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing8),
                Text('Review: ${order.review}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRatingDialog(dynamic order, dynamic customerViewModel) async {
    double selectedRating = 5;
    final reviewController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Service'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How was your service for ${order.serviceName ?? 'this order'}?'),
                const SizedBox(height: AppTheme.spacing12),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: 5,
                        divisions: 4,
                        value: selectedRating,
                        label: selectedRating.toStringAsFixed(0),
                        onChanged: (value) {
                          setDialogState(() => selectedRating = value);
                        },
                      ),
                    ),
                    Text(selectedRating.toStringAsFixed(1)),
                  ],
                ),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write a short review',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(this.context);
              final dialogNavigator = Navigator.of(context);
              final success = await customerViewModel.rateService(
                orderId: order.id,
                rating: selectedRating,
                review: reviewController.text.trim(),
              );
              dialogNavigator.pop();
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Rating saved successfully'
                      : customerViewModel.errorMessage ?? 'Failed to save rating'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerViewModel>().getMyOrders();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'in_progress':
        return AppTheme.primaryColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.mediumGrey;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
      ),
      body: Consumer<CustomerViewModel>(
        builder: (context, customerViewModel, _) {
          if (customerViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (customerViewModel.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: AppTheme.lightGrey,
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                    Text(
                      'No Orders Yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      'Start by booking your first car wash service',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to booking screen
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Book Service'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => customerViewModel.getMyOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: customerViewModel.orders.length,
              itemBuilder: (context, index) {
                final order = customerViewModel.orders[index];
                return _buildOrderCard(context, order, customerViewModel);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    dynamic order,
    dynamic customerViewModel,
  ) {
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: const [AppTheme.shadowSmall],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      '${order.scheduledDate.day}/${order.scheduledDate.month}/${order.scheduledDate.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing12,
                    vertical: AppTheme.spacing12,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _formatStatus(order.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Details
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      order.serviceName ?? 'Car Wash Service',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: Text(
                        order.address ?? 'Not provided',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Rs ${order.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Actions
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showOrderDetails(order);
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing8),
                if (order.status == 'completed' && order.rating == null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showRatingDialog(order, customerViewModel);
                      },
                      icon: const Icon(Icons.star_outline),
                      label: const Text('Rate'),
                    ),
                  )
                else if (order.status == 'pending' || order.status == 'confirmed')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Show cancel confirmation
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cancel Order'),
                            content: const Text(
                              'Are you sure you want to cancel this order?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final messenger =
                                      ScaffoldMessenger.of(this.context);
                                  final dialogNavigator = Navigator.of(context);
                                  final success = await customerViewModel
                                      .cancelOrder(order.id);
                                  dialogNavigator.pop();
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Order removed successfully'
                                            : customerViewModel.errorMessage ??
                                                'Failed to remove order',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Yes, Cancel'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}