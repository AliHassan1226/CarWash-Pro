import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/vendor_viewmodel.dart';
import 'package:car_wash_app/data/models/order.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorViewModel>().getVendorOrders();
    });
  }

  Future<void> _refreshOrders() {
    return context.read<VendorViewModel>().getVendorOrders(
          status: _selectedFilter == 'all' ? null : _selectedFilter,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        elevation: 0,
      ),
      body: Consumer<VendorViewModel>(
        builder: (context, vendorViewModel, _) {
          return Column(
            children: [
              // Filter Tabs
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: AppTheme.spacing8),
                      _buildFilterChip('Pending', 'pending'),
                      const SizedBox(width: AppTheme.spacing8),
                      _buildFilterChip('Confirmed', 'confirmed'),
                      const SizedBox(width: AppTheme.spacing8),
                      _buildFilterChip('In Progress', 'in_progress'),
                      const SizedBox(width: AppTheme.spacing8),
                      _buildFilterChip('Completed', 'completed'),
                    ],
                  ),
                ),
              ),
              // Orders List
              Expanded(
                child: vendorViewModel.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : vendorViewModel.vendorOrders.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppTheme.spacing32,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.assignment_outlined,
                                    size: 64,
                                    color: AppTheme.lightGrey,
                                  ),
                                  const SizedBox(height: AppTheme.spacing16),
                                  Text(
                                    'No Orders',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: AppTheme.spacing8),
                                  Text(
                                    'No orders in this category',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _refreshOrders,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing16,
                              ),
                              itemCount: vendorViewModel.vendorOrders.length,
                              itemBuilder: (context, index) {
                                final order =
                                    vendorViewModel.vendorOrders[index];
                                return _buildOrderCard(context, order);
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        context.read<VendorViewModel>().getVendorOrders(status: value);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
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
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusSmall),
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
                _buildDetailRow(context, 'Customer', order.customerName),
                const SizedBox(height: AppTheme.spacing8),
                _buildDetailRow(context, 'Service', order.serviceId),
                if (order.selectedServices != null && order.selectedServices!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacing8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: order.selectedServices!
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: AppTheme.spacing8),
                _buildDetailRow(context, 'Phone', order.customerPhone),
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Rs ${order.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
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

          // Location
          if (order.address != null)
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              color: AppTheme.lightGrey.withValues(alpha: 0.3),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: AppTheme.mediumGrey),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: Text(
                      order.address ?? 'No address provided',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            child: Row(
              children: [
                if (order.status == 'pending') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      onPressed: () {
                        _showRejectDialog(order.id);
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accept'),
                      onPressed: () {
                        _showAcceptDialog(order.id);
                      },
                    ),
                  ),
                ] else if (order.status == 'confirmed') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Start Service'),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await context
                            .read<VendorViewModel>()
                            .updateOrderStatus(order.id, 'in_progress');
                        await _refreshOrders();
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              success ? 'Service started' : 'Failed to start service',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else if (order.status == 'in_progress') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.done, size: 16),
                      label: const Text('Complete'),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await context
                            .read<VendorViewModel>()
                            .updateOrderStatus(order.id, 'completed');
                        await _refreshOrders();
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Service completed'
                                  : 'Failed to complete service',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('View Details'),
                      onPressed: () {
                        _showOrderDetailsDialog(context, order);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
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
      case 'confirmed':
        return AppTheme.secondaryColor;
      default:
        return AppTheme.mediumGrey;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  Future<void> _showAcceptDialog(String orderId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Order'),
        content: const Text(
          'Are you sure you want to accept this order? Please confirm you can complete it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              final messenger = ScaffoldMessenger.of(this.context);
              final success = await this
                  .context
                  .read<VendorViewModel>()
                  .updateOrderStatus(orderId, 'confirmed');
              await _refreshOrders();
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Order accepted' : 'Failed to accept order',
                  ),
                ),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectDialog(String orderId) async {
    final reasonController = TextEditingController();
    final parentMessenger = ScaffoldMessenger.of(context);
    final vendorViewModel = context.read<VendorViewModel>();

    try {
      final reason = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Reject Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: AppTheme.spacing12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = reasonController.text.trim();
                if (text.isEmpty) {
                  parentMessenger.showSnackBar(
                    const SnackBar(content: Text('Please enter rejection reason')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(text);
              },
              child: const Text('Reject'),
            ),
          ],
        ),
      );

      if (reason == null || reason.isEmpty) {
        return;
      }

      final success = await vendorViewModel.rejectOrder(orderId, reason);
      await _refreshOrders();
      if (!mounted) return;
      parentMessenger.showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Order rejected' : 'Failed to reject order',
          ),
        ),
      );
    } finally {
      reasonController.dispose();
    }
  }

  void _showOrderDetailsDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: AppTheme.spacing12),
                _buildDetailRow(context, 'Order ID', order.id),
                const SizedBox(height: AppTheme.spacing12),
                _buildDetailRow(context, 'Customer', order.customerName),
                const SizedBox(height: AppTheme.spacing12),
                _buildDetailRow(context, 'Service', order.serviceId),
                if (order.selectedServices != null && order.selectedServices!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacing12),
                  Text(
                    'Selected Services',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: order.selectedServices!
                        .map((s) => Chip(
                              label: Text(s),
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                              labelStyle: const TextStyle(color: AppTheme.primaryColor),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: AppTheme.spacing12),
                _buildDetailRow(context, 'Date', '${order.scheduledDate.day}/${order.scheduledDate.month}/${order.scheduledDate.year}'),
                const SizedBox(height: AppTheme.spacing12),
                _buildDetailRow(context, 'Amount', 'Rs ${order.totalAmount.toStringAsFixed(2)}'),
                const SizedBox(height: AppTheme.spacing12),
                _buildDetailRow(context, 'Status', _formatStatus(order.status)),
                const SizedBox(height: AppTheme.spacing12),
                _buildDetailRow(
                  context,
                  'Address',
                  (order.address == null || order.address!.trim().isEmpty)
                      ? 'Not provided'
                      : order.address!,
                ),
                if (order.notes != null) ...[
                  const SizedBox(height: AppTheme.spacing12),
                  Text(
                    'Customer Notes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    order.notes ?? 'No notes',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const SizedBox(height: AppTheme.spacing24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}