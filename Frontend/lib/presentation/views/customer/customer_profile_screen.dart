import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/customer_viewmodel.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<CustomerViewModel>();
      await viewModel.fetchCustomerProfile();
      if (mounted) {
        _initializeControllers(viewModel);
      }
    });
  }

  void _initializeControllers(CustomerViewModel viewModel) {
    // We also need base user info. viewModel.customerProfile only has customer-specific info.
    // However, for simplicity, we can get user info from AuthViewModel or AuthRepository.
    final authViewModel = context.read<AuthViewModel>();
    final user = authViewModel.currentUser;
    
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber;
      _emailController.text = user.email;
    }
    setState(() {});
  }

  Future<void> _saveProfile() async {
    try {
      final success = await context.read<CustomerViewModel>().updateProfile({
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
      });

      if (success && mounted) {
        // Also update AuthViewModel's user if needed, but fetchCustomerProfile in VM 
        // usually only refreshes the Customer doc. 
        // We might want to refresh Auth state too.
        await context.read<AuthViewModel>().initializeAuth();
        
        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _initializeControllers(context.read<CustomerViewModel>());
                });
              },
            ),
        ],
      ),
      body: Consumer2<CustomerViewModel, AuthViewModel>(
        builder: (context, customerVM, authVM, child) {
          final user = authVM.currentUser;
          final customer = customerVM.customerProfile;

          if (customerVM.isLoading && customer == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    user?.initials ?? '?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),

                // Form
                if (_isEditing) ...[
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  TextField(
                    controller: _emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Changes'),
                    ),
                  ),
                ] else ...[
                  _buildInfoTile('Full Name', user?.name ?? 'Not set', Icons.person_outline),
                  _buildInfoTile('Phone', user?.phoneNumber ?? 'Not set', Icons.phone_android_outlined),
                  _buildInfoTile('Email', user?.email ?? 'Not set', Icons.email_outlined),
                  
                  const SizedBox(height: AppTheme.spacing24),
                  const Divider(),
                  const SizedBox(height: AppTheme.spacing24),
                  
                  // Customer Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Orders', customer?.totalOrders.toString() ?? '0'),
                      _buildStatColumn('Saved', customer?.favoriteServices.length.toString() ?? '0'),
                      _buildStatColumn('Spent', 'Rs ${customer?.totalSpent.toStringAsFixed(0) ?? '0'}'),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacing32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => authVM.logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: const [AppTheme.shadowSmall],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.mediumGrey),
            const SizedBox(width: AppTheme.spacing16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.mediumGrey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.mediumGrey,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
