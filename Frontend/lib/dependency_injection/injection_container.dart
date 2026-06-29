// Dependency injection setup

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:car_wash_app/data/datasources/remote/api_service.dart';
import 'package:car_wash_app/data/repositories/auth_repository.dart';
import 'package:car_wash_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/customer_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/vendor_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/admin_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core services
  await _setupCoreServices();

  // Repositories
  _setupRepositories();

  // ViewModels
  _setupViewModels();
}

Future<void> _setupCoreServices() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // API Service
  final apiService = ApiService();
  getIt.registerSingleton<ApiService>(apiService);
}

void _setupRepositories() {
  // Auth Repository
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(
      apiService: getIt<ApiService>(),
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
}

void _setupViewModels() {
  // Auth ViewModel
  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(getIt<AuthRepository>()),
  );

  // Customer ViewModel
  getIt.registerSingleton<CustomerViewModel>(
    CustomerViewModel(),
  );

  // Vendor ViewModel
  getIt.registerSingleton<VendorViewModel>(
    VendorViewModel(),
  );

  // Admin ViewModel
  getIt.registerSingleton<AdminViewModel>(
    AdminViewModel(),
  );
}