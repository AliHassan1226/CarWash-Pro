import 'package:flutter/material.dart';

/// Order model for reference
class Order {
  final String id;
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final String vendorName;
  final String status;
  final double totalAmount;
  final String? address;
  final String? carNumber;
  final String? carDetails;
  final String? carColor;
  final DateTime? scheduledDate;
  final String? notes;
  final bool isRated;
  final double? rating;
  final String? review;

  Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.vendorName,
    required this.status,
    required this.totalAmount,
    this.address,
    this.carNumber,
    this.carDetails,
    this.carColor,
    this.scheduledDate,
    this.notes,
    this.isRated = false,
    this.rating,
    this.review,
  });
}

/// Order Card Widget - Displays order information in an expandable card
/// 
/// Features:
/// - Complete order header with status badge
/// - Customer and service information
/// - Amount and date/time display
/// - Expandable detailed view
/// - Action buttons (Accept, Reject, Cancel)
/// - Status-based color coding
class OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final bool showActions;
  final bool isExpanded;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final double elevation;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.showActions = true,
    this.isExpanded = false,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor,
    this.elevation = 2,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _expandController.forward();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.elevation,
      color: widget.backgroundColor ?? Colors.white,
      margin: widget.padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _toggleExpanded();
            widget.onTap?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                _buildOrderHeader(),
                const SizedBox(height: 12),

                // Customer Info
                _buildOrderInfo(),
                const SizedBox(height: 12),

                // Amount and Date
                _buildOrderFooter(),

                // Expanded Content
                if (_isExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildExpandedContent(),
                  if (widget.showActions &&
                      _getAvailableActions().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${widget.order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.order.serviceName,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (widget.order.status) {
      case 'pending':
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.schedule;
        break;
      case 'confirmed':
        bgColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        icon = Icons.check_circle;
        break;
      case 'in_progress':
        bgColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        icon = Icons.hourglass_bottom;
        break;
      case 'completed':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        bgColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
        icon = Icons.help_outline;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            widget.order.status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order.customerName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.order.customerPhone,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.order.address ?? 'No address',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rs ${widget.order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A73E8),
              ),
            ),
            if (widget.order.scheduledDate != null)
              Text(
                _formatDateTime(widget.order.scheduledDate!),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Car Details
        if (widget.order.carNumber != null) ...[
          const Text(
            'Car Details',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Number', widget.order.carNumber ?? 'N/A'),
          _buildDetailRow('Model', widget.order.carDetails ?? 'N/A'),
          _buildDetailRow('Color', widget.order.carColor ?? 'N/A'),
          const SizedBox(height: 12),
        ],

        // Service Details
        const Text(
          'Service Details',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Vendor', widget.order.vendorName),
        _buildDetailRow('Service', widget.order.serviceName),
        if (widget.order.scheduledDate != null)
          _buildDetailRow('Date & Time', _formatDateTime(widget.order.scheduledDate!)),

        // Order Notes
        if (widget.order.notes != null && widget.order.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.order.notes!,
            style: const TextStyle(fontSize: 12),
          ),
        ],

        // Review (if completed and rated)
        if (widget.order.isRated) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${widget.order.rating} - ${widget.order.review}',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final actions = _getAvailableActions();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions.map((action) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildActionButton(
              action['label'] as String,
              action['color'] as Color,
              action['onTap'] as VoidCallback,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailableActions() {
    final actions = <Map<String, dynamic>>[];

    if (widget.order.status == 'pending') {
      if (widget.onAccept != null) {
        actions.add({
          'label': 'Accept',
          'color': const Color(0xFF34A853),
          'onTap': widget.onAccept!,
        });
      }
      if (widget.onReject != null) {
        actions.add({
          'label': 'Reject',
          'color': const Color(0xFFEA4335),
          'onTap': widget.onReject!,
        });
      }
    } else if (widget.order.status == 'confirmed') {
      if (widget.onAccept != null) {
        actions.add({
          'label': 'Start',
          'color': Colors.blue,
          'onTap': widget.onAccept!,
        });
      }
    }

    if (widget.onCancel != null &&
        (widget.order.status == 'pending' ||
            widget.order.status == 'confirmed')) {
      actions.add({
        'label': 'Cancel',
        'color': Colors.orange,
        'onTap': widget.onCancel!,
      });
    }

    return actions;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}