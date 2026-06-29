import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/vendor_viewmodel.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  late TextEditingController _businessNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _bankAccountController;
  late TextEditingController _ifscCodeController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _bankAccountController = TextEditingController();
    _ifscCodeController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<VendorViewModel>();
      await viewModel.fetchVendorProfile();
      await viewModel.getVendorOrders();
      if (mounted) {
        _initializeControllers(viewModel);
      }
    });
  }

  void _initializeControllers(VendorViewModel viewModel) {
    final profile = viewModel.vendorProfile;
    final user = context.read<AuthViewModel>().currentUser;
    
    if (profile != null) {
      _businessNameController.text = profile.businessName ?? "";
      _descriptionController.text = profile.businessDescription ?? "";
      _phoneController.text = user?.phoneNumber ?? "";
      _emailController.text = user?.email ?? "";
      _addressController.text = profile.serviceAreas?.join(", ") ?? "";
      _bankAccountController.text = profile.bankAccountNumber ?? "";
      _ifscCodeController.text = profile.bankIfscCode ?? "";
    } else {
      // Fallbacks if profile not found
      _businessNameController.text = 'New Business';
      _descriptionController.text = 'Add your description';
      _phoneController.text = user?.phoneNumber ?? "";
      _emailController.text = user?.email ?? "";
    }
    setState(() {});
  }

  Future<void> _saveProfile() async {
    try {
      final vendorViewModel = context.read<VendorViewModel>();
      final authViewModel = context.read<AuthViewModel>();
      final messenger = ScaffoldMessenger.of(context);

      await vendorViewModel.updateProfile({
        'businessName': _businessNameController.text.trim(),
        'businessDescription': _descriptionController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'serviceAreas': _addressController.text.split(',').map((e) => e.trim()).toList(),
        'bankAccountNumber': _bankAccountController.text.trim(),
        'bankIfscCode': _ifscCodeController.text.trim(),
      });
      
      // Also refresh auth status to get updated user info
      await authViewModel.initializeAuth();

      if (mounted) {
        setState(() {
          _isEditing = false;
        });

        messenger.showSnackBar(
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
        title: const Text('Vendor Profile'),
        elevation: 0,
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text('Edit'),
            )
          else
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset controllers to original values when canceling
                  _initializeControllers(context.read<VendorViewModel>());
                });
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
      body: Consumer<VendorViewModel>(
        builder: (context, viewModel, child) {
          final allOrders = viewModel.vendorOrders;
          final totalOrders = allOrders.length;
          final completedOrders =
              allOrders.where((order) => order.isCompleted).length;
          final cancelledOrders =
              allOrders.where((order) => order.isCancelled).length;
          final ratedCompletedOrders = allOrders
              .where((order) => order.isCompleted && (order.rating ?? 0) > 0)
              .toList();
          final averageRating = ratedCompletedOrders.isEmpty
              ? 0.0
              : ratedCompletedOrders
                      .fold<double>(
                        0.0,
                        (sum, order) => sum + (order.rating ?? 0.0),
                      ) /
                  ratedCompletedOrders.length;
          final totalEarnings = allOrders
              .where((order) => order.isCompleted)
              .fold<double>(0.0, (sum, order) => sum + order.totalAmount);

          if (viewModel.isLoading && viewModel.vendorProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.vendorProfile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchVendorProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.business,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _businessNameController.text.isEmpty 
                            ? (viewModel.vendorProfile?.businessName ?? 'No Name')
                            : _businessNameController.text,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${averageRating.toStringAsFixed(1)} (${ratedCompletedOrders.length} reviews)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Information Section
                  _buildSectionTitle(context, 'Business Information'),
                  const SizedBox(height: 12),

                  if (_isEditing)
                    Column(
                      children: [
                        _buildTextField(
                          controller: _businessNameController,
                          label: 'Business Name',
                          icon: Icons.business,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildInfoRow(context, 'Business Name', _businessNameController.text),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Description', _descriptionController.text),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Contact Information Section
                  _buildSectionTitle(context, 'Contact Information'),
                  const SizedBox(height: 12),

                  if (_isEditing)
                    Column(
                      children: [
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Business Address',
                          icon: Icons.location_on,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildInfoRow(context, 'Phone', _phoneController.text),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Email', _emailController.text),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'Address', _addressController.text),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Banking Information Section
                  _buildSectionTitle(context, 'Banking Information'),
                  const SizedBox(height: 12),

                  if (_isEditing)
                    Column(
                      children: [
                        _buildTextField(
                          controller: _bankAccountController,
                          label: 'Bank Account (masked)',
                          icon: Icons.account_balance,
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _ifscCodeController,
                          label: 'IFSC Code',
                          icon: Icons.code,
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildInfoRow(context, 'Bank Account', _bankAccountController.text),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, 'IFSC Code', _ifscCodeController.text),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Statistics Section
                  _buildSectionTitle(context, 'Statistics'),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatTile(
                        context,
                        'Total Orders',
                        totalOrders.toString(),
                        Icons.assignment,
                        Colors.blue,
                      ),
                      _buildStatTile(
                        context,
                        'Completed',
                        completedOrders.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatTile(
                        context,
                        'Cancelled',
                        cancelledOrders.toString(),
                        Icons.cancel,
                        Colors.red,
                      ),
                      _buildStatTile(
                        context,
                        'Rating',
                        averageRating.toStringAsFixed(1),
                        Icons.star,
                        Colors.amber,
                      ),
                      _buildStatTile(
                        context,
                        'Earnings',
                        'Rs ${totalEarnings.toStringAsFixed(0)}',
                        Icons.account_balance_wallet,
                        Colors.indigo,
                      ),
                      _buildStatTile(
                        context,
                        'Reviews',
                        ratedCompletedOrders.length.toString(),
                        Icons.reviews,
                        Colors.deepOrange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Operating Hours Section
                  _buildSectionTitle(context, 'Operating Hours'),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildHourRow(context, 'Monday - Friday', '09:00 AM - 10:00 PM'),
                        const Divider(),
                        _buildHourRow(context, 'Saturday', '08:00 AM - 11:00 PM'),
                        const Divider(),
                        _buildHourRow(context, 'Sunday', '08:00 AM - 09:00 PM'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Verification Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verified Business',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Colors.green,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your business has been verified by our team',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _initializeControllers(viewModel);
                              setState(() {
                                _isEditing = false;
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context
                                        .read<AuthViewModel>()
                                        .logout();
                                  },
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHourRow(BuildContext context, String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            hours,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _bankAccountController.dispose();
    _ifscCodeController.dispose();
    super.dispose();
  }
}