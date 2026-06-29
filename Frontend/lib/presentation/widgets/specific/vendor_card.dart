import 'package:flutter/material.dart';

/// Vendor model for reference
class Vendor {
  final String id;
  final String businessName;
  final String businessDescription;
  final String businessAddress;
  final String businessPhoneNumber;
  final String businessEmail;
  final bool isVerified;
  final bool isSuspended;
  final double rating;
  final int orderCount;
  final int completedOrders;
  final double totalEarnings;
  final double availableBalance;
  final DateTime createdAt;

  Vendor({
    required this.id,
    required this.businessName,
    required this.businessDescription,
    required this.businessAddress,
    required this.businessPhoneNumber,
    required this.businessEmail,
    this.isVerified = false,
    this.isSuspended = false,
    this.rating = 0.0,
    this.orderCount = 0,
    this.completedOrders = 0,
    this.totalEarnings = 0.0,
    this.availableBalance = 0.0,
    required this.createdAt,
  });
}

/// Vendor Card Widget - Displays vendor information with statistics
/// 
/// Features:
/// - Business name with verification badge
/// - Business description
/// - Statistics (rating, orders, completed)
/// - Contact information (address, phone)
/// - Suspension status indicator
/// - Action buttons (View Services, Contact)
/// - Professional card layout
class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback? onTap;
  final VoidCallback? onViewServices;
  final VoidCallback? onContact;
  final EdgeInsets padding;
  final Color? backgroundColor;

  const VendorCard({
    super.key,
    required this.vendor,
    this.onTap,
    this.onViewServices,
    this.onContact,
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
                // Vendor Header
                _buildVendorHeader(),
                const SizedBox(height: 12),

                // Description
                _buildDescription(),
                const SizedBox(height: 12),

                // Statistics
                _buildStats(),
                const SizedBox(height: 12),

                // Contact Info
                _buildContactInfo(),
                const SizedBox(height: 16),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVendorHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vendor.businessName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (vendor.isVerified)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (vendor.isSuspended)
          Container(
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Suspended',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      vendor.businessDescription,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStats() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Rating',
            vendor.rating.toStringAsFixed(1),
            Icons.star,
          ),
          _buildStatItem(
            'Orders',
            vendor.orderCount.toString(),
            Icons.shopping_bag_outlined,
          ),
          _buildStatItem(
            'Completed',
            vendor.completedOrders.toString(),
            Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                vendor.businessAddress,
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
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                vendor.businessPhoneNumber,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onViewServices != null)
          Expanded(
            child: ElevatedButton(
              onPressed: onViewServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'View Services',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        if (onContact != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: onContact,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Contact',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}