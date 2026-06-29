import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/admin_viewmodel.dart';

class ManageVendorsScreen extends StatefulWidget {
  const ManageVendorsScreen({super.key});

  @override
  State<ManageVendorsScreen> createState() => _ManageVendorsScreenState();
}

class _ManageVendorsScreenState extends State<ManageVendorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().getAllVendors(reset: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) {
        final vendors = vm.allVendors;
        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search vendors by name or user id',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: vm.setVendorSearchQuery,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => vm.getAllVendors(reset: true),
                  child: vendors.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 120),
                            const Icon(
                              Icons.business_outlined,
                              size: 60,
                              color: AppTheme.lightGrey,
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                'No vendors found',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing16,
                          ),
                          itemCount: vendors.length + 1,
                          itemBuilder: (context, index) {
                            if (index == vendors.length) {
                              if (!vm.hasMoreVendors) {
                                return const SizedBox(height: 16);
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: vm.isLoadingMoreVendors
                                      ? const CircularProgressIndicator()
                                      : OutlinedButton(
                                          onPressed: vm.loadMoreVendors,
                                          child: const Text('Load More'),
                                        ),
                                ),
                              );
                            }

                            final vendor = vendors[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            vendor.businessName ?? 'Unnamed Vendor',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: vendor.isVerified
                                                ? AppTheme.successColor
                                                    .withOpacity(0.15)
                                                : AppTheme.warningColor
                                                    .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            vendor.isVerified
                                                ? 'Verified'
                                                : 'Unverified',
                                            style: TextStyle(
                                              color: vendor.isVerified
                                                  ? AppTheme.successColor
                                                  : AppTheme.warningColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('User ID: ${vendor.userId}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      vendor.isSuspended
                                          ? 'Status: Suspended'
                                          : 'Status: Active',
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        if (!vendor.isVerified)
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  vm.verifyVendor(vendor.id),
                                              child: const Text('Verify'),
                                            ),
                                          ),
                                        if (!vendor.isVerified)
                                          const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              if (vendor.isSuspended) {
                                                vm.unsuspendVendor(vendor.id);
                                              } else {
                                                _showSuspendDialog(context, vendor.id);
                                              }
                                            },
                                            child: Text(
                                              vendor.isSuspended
                                                  ? 'Unsuspend'
                                                  : 'Suspend',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuspendDialog(BuildContext context, String vendorId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend Vendor'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Reason for suspension',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final reason = controller.text.trim().isEmpty
                  ? 'Policy violation'
                  : controller.text.trim();
              context.read<AdminViewModel>().suspendVendor(vendorId, reason);
            },
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }
}
