import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/core/utils/validators.dart';
import 'package:car_wash_app/presentation/viewmodels/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthViewModel>().forgotPassword(
            _emailController.text.trim(),
          );
      setState(() {
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacing24),
              
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: const Icon(
                  Icons.lock_open_outlined,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: AppTheme.spacing24),
              
              Text(
                'Reset Your Password',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              
              const SizedBox(height: AppTheme.spacing12),
              
              Text(
                'Enter your email address and we\'ll send you instructions to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: AppTheme.spacing32),
              
              if (!_emailSent)
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: Validators.validateEmail,
                      ),
                      
                      const SizedBox(height: AppTheme.spacing24),
                      
                      Consumer<AuthViewModel>(
                        builder: (context, authViewModel, _) {
                          return ElevatedButton(
                            onPressed: authViewModel.isLoading
                                ? null
                                : _handleSubmit,
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
                                  : const Text('Send Reset Link'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.successColor),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 48,
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          Text(
                            'Check Your Email',
                            style:
                                Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppTheme.successColor,
                                    ),
                          ),
                          const SizedBox(height: AppTheme.spacing8),
                          Text(
                            'We\'ve sent a password reset link to ${_emailController.text}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacing32),
                    
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}