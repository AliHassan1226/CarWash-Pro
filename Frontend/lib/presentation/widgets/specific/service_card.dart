import 'package:flutter/material.dart';

/// Service model for reference
class Service {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final double estimatedDuration;
  final String category;
  final double rating;
  final int reviewCount;
  final int totalBookings;
  final bool isActive;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.estimatedDuration,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.totalBookings = 0,
    this.isActive = true,
    required this.createdAt,
  });
}

/// Service Card Widget - Displays service information with pricing and rating
/// 
/// Features:
/// - Service name and category badge
/// - Description with ellipsis
/// - Price and duration display
/// - Star rating with review count
/// - Active/Inactive status badge
/// - Action buttons (Book, Edit, Delete)
/// - Category-based color coding
class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onTap;
  final VoidCallback? onBook;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final EdgeInsets padding;
  final Color? backgroundColor;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onBook,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: backgroundColor ?? Colors.white,
      margin: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Header
                _buildServiceHeader(),
                const SizedBox(height: 12),

                // Description
                _buildDescription(),
                const SizedBox(height: 12),

                // Pricing Info
                _buildPricingInfo(),
                const SizedBox(height: 12),

                // Rating Info
                _buildRatingInfo(),

                // Action Buttons
                if (showActions) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: _getCategoryColor(service.category),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  service.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: service.isActive
                ? Colors.green[100]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            service.isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: service.isActive
                  ? Colors.green[800]
                  : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      service.description,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPricingInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rs ${service.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A73E8),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Duration',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${service.estimatedDuration.toStringAsFixed(0)} min',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingInfo() {
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          service.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${service.reviewCount} reviews)',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '${service.totalBookings} bookings',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      children: [
        if (onBook != null)
          ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Book',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (onEdit != null)
          OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (onDelete != null)
          OutlinedButton(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'basic':
        return Colors.blue;
      case 'standard':
        return Colors.green;
      case 'premium':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}