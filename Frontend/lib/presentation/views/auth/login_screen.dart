import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/core/utils/validators.dart';
import 'package:car_wash_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:car_wash_app/presentation/views/auth/register_screen.dart';
import 'package:car_wash_app/presentation/views/auth/forgot_password_screen.dart';
import 'package:car_wash_app/presentation/views/customer/customer_home_screen.dart';
import 'package:car_wash_app/presentation/views/vendor/vendor_home_screen.dart';
import 'package:car_wash_app/presentation/views/admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted || !success) return;

    Widget target = const CustomerHomeScreen();
    switch (authViewModel.userRole) {
      case 'vendor':
        target = const VendorHomeScreen();
        break;
      case 'admin':
        target = const AdminHomeScreen();
        break;
      case 'customer':
      default:
        target = const CustomerHomeScreen();
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => target),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              // Logo/App Name
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: const [AppTheme.shadowMedium],
                ),
                child: const Icon(
                  Icons.local_car_wash,
                  color: AppTheme.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: AppTheme.spacing20),

              Text(
                'CarWash Pro',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkGrey,
                    ),
              ),

              const SizedBox(height: AppTheme.spacing8),

              Text(
                'Professional Car Washing Services',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.spacing48),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.validateEmail,
                    ),

                    const SizedBox(height: AppTheme.spacing16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: Validators.validateRequired,
                    ),

                    const SizedBox(height: AppTheme.spacing12),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing24),

                    // Login Button
                    Consumer<AuthViewModel>(
                      builder: (context, authViewModel, _) {
                        return ElevatedButton(
                          onPressed:
                              authViewModel.isLoading ? null : _handleLogin,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing8,
                            ),
                            child: authViewModel.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                        AppTheme.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        );
                      },
                    ),

                    // Error Message
                    Consumer<AuthViewModel>(
                      builder: (context, authViewModel, _) {
                        if (authViewModel.errorMessage != null) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: AppTheme.spacing16,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppTheme.spacing12,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium,
                                ),
                                border: Border.all(
                                  color: AppTheme.errorColor,
                                ),
                              ),
                              child: Text(
                                authViewModel.errorMessage ?? '',
                                style: const TextStyle(
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacing48),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing12,
                    ),
                    child: Text(
                      'New to CarWash Pro?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: AppTheme.spacing20),

              // Register Button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
