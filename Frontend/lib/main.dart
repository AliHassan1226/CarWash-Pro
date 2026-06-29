import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/customer_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/vendor_viewmodel.dart';
import 'package:car_wash_app/presentation/viewmodels/admin_viewmodel.dart';
import 'package:car_wash_app/dependency_injection/injection_container.dart';
import 'package:car_wash_app/presentation/views/auth/login_screen.dart';
import 'package:car_wash_app/presentation/views/customer/customer_home_screen.dart';
import 'package:car_wash_app/presentation/views/vendor/vendor_home_screen.dart';
import 'package:car_wash_app/presentation/views/admin/admin_home_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:car_wash_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupDependencies();
  runApp(const CarWashApp());
}

class CarWashApp extends StatelessWidget {
  const CarWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => getIt<AuthViewModel>()..initializeAuth(),
        ),
        ChangeNotifierProvider<CustomerViewModel>(
          create: (context) => getIt<CustomerViewModel>(),
        ),
        ChangeNotifierProvider<VendorViewModel>(
          create: (context) => getIt<VendorViewModel>(),
        ),
        ChangeNotifierProvider<AdminViewModel>(
          create: (context) => getIt<AdminViewModel>(),
        ),
      ],
      child: MaterialApp(
        title: 'CarWash Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            if (authViewModel.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (authViewModel.isAuthenticated) {
              switch (authViewModel.userRole) {
                case 'customer':
                  return const CustomerHomeScreen();
                case 'vendor':
                  return const VendorHomeScreen();
                case 'admin':
                  return const AdminHomeScreen();
                default:
                  return const LoginScreen();
              }
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}