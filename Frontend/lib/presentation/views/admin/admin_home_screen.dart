import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/admin_viewmodel.dart';
import 'package:car_wash_app/presentation/views/auth/login_screen.dart';
import 'package:car_wash_app/presentation/views/admin/manage_customers_screen.dart';
import 'package:car_wash_app/presentation/views/admin/manage_vendors_screen.dart';
import 'package:car_wash_app/presentation/views/admin/reports_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().fetchDashboardData();
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
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
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
          const ManageCustomersScreen(),
          const ManageVendorsScreen(),
          const ReportsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            context.read<AdminViewModel>().getAllUsers();
          } else if (index == 2) {
            context.read<AdminViewModel>().getAllVendors();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Vendors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, _) {
        final stats = adminViewModel.dashboardStats;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppTheme.spacing12,
                  mainAxisSpacing: AppTheme.spacing12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildDashboardCard(
                      title: 'Total Users',
                      value: stats['totalUsers']?.toString() ?? '0',
                      icon: Icons.people,
                      color: AppTheme.primaryColor,
                    ),
                    _buildDashboardCard(
                      title: 'Total Vendors',
                      value: stats['totalVendors']?.toString() ?? '0',
                      icon: Icons.business,
                      color: AppTheme.successColor,
                    ),
                    _buildDashboardCard(
                      title: 'Total Orders',
                      value: stats['totalOrders']?.toString() ?? '0',
                      icon: Icons.assignment,
                      color: AppTheme.warningColor,
                    ),
                    _buildDashboardCard(
                      title: 'Total Revenue',
                      value: 'Rs ${stats['totalRevenue']?.toStringAsFixed(0) ?? '0'}',
                      icon: Icons.wallet,
                      color: AppTheme.accentColor,
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacing24),

                // Active Orders
                Text(
                  'Platform Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: AppTheme.spacing12),

                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: const [AppTheme.shadowSmall],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Orders',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing8,
                              vertical: AppTheme.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSmall,
                              ),
                            ),
                            child: Text(
                              '${stats['activeOrders'] ?? 0}',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Orders currently being processed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}