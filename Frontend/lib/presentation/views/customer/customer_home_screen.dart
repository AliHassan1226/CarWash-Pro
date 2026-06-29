import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/customer_viewmodel.dart';
import 'package:car_wash_app/presentation/views/auth/login_screen.dart';
import 'package:car_wash_app/presentation/views/customer/order_history_screen.dart';
import 'package:car_wash_app/presentation/views/customer/track_order_screen.dart';
import 'package:car_wash_app/presentation/views/customer/customer_profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerViewModel>().fetchNearbyServices();
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
    final user = context.watch<AuthViewModel>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CarWash Pro'),
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
          // Home/Services Tab
          _buildHomeTab(),
          // My Orders Tab
          const OrderHistoryScreen(),
          // Track Order Tab
          const TrackOrderScreen(),
          // Profile Tab
          _buildProfileTab(user),
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_outlined),
            activeIcon: Icon(Icons.list),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Track',
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

  Widget _buildHomeTab() {
    return Consumer<CustomerViewModel>(
      builder: (context, customerViewModel, _) {
        return RefreshIndicator(
          onRefresh: () => customerViewModel.fetchNearbyServices(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: AppTheme.spacing12),

                  Wrap(
                    spacing: AppTheme.spacing12,
                    runSpacing: AppTheme.spacing12,
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width -
                                (AppTheme.spacing16 * 2) -
                                AppTheme.spacing12) /
                            2,
                        child: _buildQuickActionCard(
                          icon: Icons.history,
                          label: 'Order History',
                          color: AppTheme.primaryColor,
                          onTap: () {
                            setState(() {
                              _currentIndex = 1;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width -
                                (AppTheme.spacing16 * 2) -
                                AppTheme.spacing12) /
                            2,
                        child: _buildQuickActionCard(
                          icon: Icons.person_outline,
                          label: 'Profile',
                          color: AppTheme.secondaryColor,
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

                  // Services List
                  Text(
                    'Available Services',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: AppTheme.spacing12),

                  if (customerViewModel.isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (customerViewModel.services.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing32,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.local_car_wash,
                              size: 48,
                              color: AppTheme.lightGrey,
                            ),
                            const SizedBox(height: AppTheme.spacing12),
                            Text(
                              'No services available',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: customerViewModel.services.length,
                      itemBuilder: (context, index) {
                        final service =
                            customerViewModel.services[index];
                        return _buildServiceCard(context, service);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, dynamic service) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: const [AppTheme.shadowSmall],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Service Image
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMedium),
                topRight: Radius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: const Icon(
              Icons.local_car_wash,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          // Service Details
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            service.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs ${service.price.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: AppTheme.warningColor,
                            ),
                            const SizedBox(width: AppTheme.spacing4),
                            Text(
                              service.rating.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                    child: const Text('View on Map'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(dynamic user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: const [AppTheme.shadowSmall],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            // Menu Items
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacing12),
            _buildMenuItem(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerProfileScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'My Addresses',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () {},
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              'Support',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacing12),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacing12,
          horizontal: AppTheme.spacing12,
        ),
        margin: const EdgeInsets.only(bottom: AppTheme.spacing8),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: const [AppTheme.shadowSmall],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}