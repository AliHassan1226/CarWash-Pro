import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/admin_viewmodel.dart';

class ManageCustomersScreen extends StatefulWidget {
  const ManageCustomersScreen({super.key});

  @override
  State<ManageCustomersScreen> createState() => _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends State<ManageCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AdminViewModel>();
      vm.getAllUsers(reset: true);
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
        final users = vm.allUsers;
        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search users by name/email/phone',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: vm.setUserSearchQuery,
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _roleChip(vm, 'All', 'all'),
                          const SizedBox(width: 8),
                          _roleChip(vm, 'Customers', 'customer'),
                          const SizedBox(width: 8),
                          _roleChip(vm, 'Vendors', 'vendor'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => vm.getAllUsers(reset: true),
                  child: users.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 120),
                            const Icon(
                              Icons.people_outline,
                              size: 60,
                              color: AppTheme.lightGrey,
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                'No users found',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing16,
                          ),
                          itemCount: users.length + 1,
                          itemBuilder: (context, index) {
                            if (index == users.length) {
                              if (!vm.hasMoreUsers) {
                                return const SizedBox(height: 16);
                              }
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: vm.isLoadingMoreUsers
                                      ? const CircularProgressIndicator()
                                      : OutlinedButton(
                                          onPressed: vm.loadMoreUsers,
                                          child: const Text('Load More'),
                                        ),
                                ),
                              );
                            }

                            final user = users[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            user.name.isEmpty ? 'Unnamed User' : user.name,
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: user.isActive
                                                ? AppTheme.successColor.withOpacity(0.15)
                                                : AppTheme.errorColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            user.isActive ? 'Active' : 'Inactive',
                                            style: TextStyle(
                                              color: user.isActive
                                                  ? AppTheme.successColor
                                                  : AppTheme.errorColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(user.email),
                                    const SizedBox(height: 4),
                                    Text('Role: ${user.role} • Phone: ${user.phoneNumber}'),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        if (!user.isActive)
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => vm.activateUser(user.id),
                                              child: const Text('Activate'),
                                            ),
                                          ),
                                        if (user.isActive)
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => vm.deactivateUser(user.id),
                                              child: const Text('Deactivate'),
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

  Widget _roleChip(AdminViewModel vm, String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: vm.userRoleFilter == value,
      onSelected: (_) => vm.setUserRoleFilter(value),
    );
  }
}
