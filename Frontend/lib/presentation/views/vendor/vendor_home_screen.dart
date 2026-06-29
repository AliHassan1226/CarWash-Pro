import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/vendor_viewmodel.dart';
import 'package:car_wash_app/presentation/views/auth/login_screen.dart';
import 'package:car_wash_app/presentation/views/vendor/manage_orders_screen.dart';
import 'package:car_wash_app/presentation/views/vendor/manage_services_screen.dart';
import 'package:car_wash_app/presentation/views/vendor/vendor_profile_screen.dart';
import 'package:car_wash_app/data/models/order.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorViewModel>().fetchDashboardData();
      context.read<VendorViewModel>().getVendorOrders();
      context.read<VendorViewModel>().getVendorServices();
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthViewModel>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          const ManageOrdersScreen(),
          const ManageServicesScreen(),
          const VendorProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services_outlined),
            activeIcon: Icon(Icons.miscellaneous_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Consumer<VendorViewModel>(
      builder: (context, vendorViewModel, _) {
        final allOrders = vendorViewModel.vendorOrders;
        final totalOrders = allOrders.length;
        final completedOrders =
            allOrders.where((order) => order.isCompleted).length;
        final pendingOrders = vendorViewModel.vendorOrders
            .where((order) => order.status == 'pending')
            .length;
        final completionPercentage = totalOrders == 0
            ? 0
            : ((completedOrders / totalOrders) * 100).round();
        final ratedCompletedOrders = allOrders
            .where((order) => order.isCompleted && (order.rating ?? 0) > 0)
            .toList();
        final totalRating = ratedCompletedOrders.fold<double>(
          0.0,
          (sum, order) => sum + (order.rating ?? 0),
        );
        final rating = ratedCompletedOrders.isEmpty
            ? 0.0
            : totalRating / ratedCompletedOrders.length;
        final reviewCount = ratedCompletedOrders.length;
        final totalEarnings = allOrders
            .where((order) => order.isCompleted)
            .fold<double>(0.0, (sum, order) => sum + order.totalAmount);
        final weeklyStats = _buildWeeklyStats(vendorViewModel.vendorOrders);

        return RefreshIndicator(
          onRefresh: () async {
            await vendorViewModel.fetchDashboardData();
            await vendorViewModel.getVendorOrders();
            await vendorViewModel.getVendorServices();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Orders',
                          value: totalOrders.toString(),
                          icon: Icons.assignment,
                          color: AppTheme.primaryColor,
                          subtitle: 'All time',
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Completed',
                          value: completedOrders.toString(),
                          icon: Icons.check_circle,
                          color: AppTheme.successColor,
                          subtitle: '$completionPercentage%',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacing12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Rating',
                          value: rating.toStringAsFixed(1),
                          icon: Icons.star,
                          color: AppTheme.warningColor,
                          subtitle: '($reviewCount reviews)',
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Earnings',
                          value: 'Rs ${totalEarnings.toStringAsFixed(0)}',
                          icon: Icons.wallet,
                          color: AppTheme.accentColor,
                          subtitle: 'Completed orders total',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacing24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: AppTheme.spacing12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.add_circle_outline,
                          label: 'Add Service',
                          color: AppTheme.primaryColor,
                          onTap: () {
                            setState(() {
                              _currentIndex = 2;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.assignment,
                          label: 'View Orders',
                          color: AppTheme.successColor,
                          onTap: () {
                            setState(() {
                              _currentIndex = 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.person,
                          label: 'My Profile',
                          color: AppTheme.accentColor,
                          onTap: () {
                            setState(() {
                              _currentIndex = 3;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacing24),

                  // Pending Orders Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pending Orders',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacing12),

                  if (vendorViewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: const [AppTheme.shadowSmall],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'New orders awaiting approval',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing8,
                                  vertical: AppTheme.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSmall,
                                  ),
                                ),
                                child: Text(
                                  pendingOrders.toString(),
                                  style: const TextStyle(
                                    color: AppTheme.warningColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentIndex = 1;
                                });
                              },
                              child: const Text('Review Orders'),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: AppTheme.spacing24),

                  // Performance Chart
                  Text(
                    'This Week Performance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: AppTheme.spacing12),

                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Column(
                      children: [
                        ...weeklyStats.entries.map(
                          (entry) => _buildPerformanceRow(
                            entry.key,
                            entry.value['total']!,
                            entry.value['completed']!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color: AppTheme.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String day, int total, int completed) {
    final safeTotal = total == 0 ? 1 : total;
    final displayTotal = total == 0 ? 0 : total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              day,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completed / safeTotal,
                    minHeight: 6,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          SizedBox(
            width: 40,
            child: Text(
              '$completed/$displayTotal',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Map<String, int>> _buildWeeklyStats(List<Order> vendorOrders) {
    final dayLabels = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final stats = <String, Map<String, int>>{
      for (final day in dayLabels) day: {'total': 0, 'completed': 0}
    };

    for (final order in vendorOrders) {
      final dayIndex = order.scheduledDate.weekday - 1;
      if (dayIndex < 0 || dayIndex >= dayLabels.length) {
        continue;
      }
      final day = dayLabels[dayIndex];
      stats[day]!['total'] = stats[day]!['total']! + 1;
      if (order.status == 'completed') {
        stats[day]!['completed'] = stats[day]!['completed']! + 1;
      }
    }

    return stats;
  }
}