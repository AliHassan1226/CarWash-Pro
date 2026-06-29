import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_wash_app/core/theme/app_theme.dart';
import 'package:car_wash_app/core/utils/validators.dart';
import 'package:car_wash_app/presentation/viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  
  String _selectedRole = 'customer';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Vendor specific controllers
  late TextEditingController _businessNameController;
  late TextEditingController _businessRegController;
  late TextEditingController _businessDescController;
  late TextEditingController _bankAccountController;
  late TextEditingController _bankIfscController;
  late TextEditingController _bankHolderController;
  late TextEditingController _bankNameController;
  String _selectedBusinessType = 'individual';
  final List<String> _selectedServiceTypes = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
    _businessNameController = TextEditingController();
    _businessRegController = TextEditingController();
    _businessDescController = TextEditingController();
    _bankAccountController = TextEditingController();
    _bankIfscController = TextEditingController();
    _bankHolderController = TextEditingController();
    _bankNameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _businessRegController.dispose();
    _businessDescController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    _bankHolderController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthViewModel>().register(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            name: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            role: _selectedRole,
            businessName: _selectedRole == 'vendor' ? _businessNameController.text.trim() : null,
            businessRegistration: _selectedRole == 'vendor' ? _businessRegController.text.trim() : null,
            businessType: _selectedRole == 'vendor' ? _selectedBusinessType : null,
            businessDescription: _selectedRole == 'vendor' ? _businessDescController.text.trim() : null,
            serviceTypes: _selectedRole == 'vendor' ? _selectedServiceTypes : null,
            bankAccountNumber: _selectedRole == 'vendor' ? _bankAccountController.text.trim() : null,
            bankIfscCode: _selectedRole == 'vendor' ? _bankIfscController.text.trim() : null,
            bankAccountHolderName: _selectedRole == 'vendor' ? _bankHolderController.text.trim() : null,
            bankName: _selectedRole == 'vendor' ? _bankNameController.text.trim() : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Full Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: Validators.validateName,
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
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
                
                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.validatePhoneNumber,
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // Role Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I am registering as a',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.lightGrey),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                            value: 'customer',
                            child: Padding(
                              padding: EdgeInsets.all(AppTheme.spacing12),
                              child: Row(
                                children: [
                                  Icon(Icons.person),
                                  SizedBox(width: AppTheme.spacing12),
                                  Text('Customer'),
                                ],
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'vendor',
                            child: Padding(
                              padding: EdgeInsets.all(AppTheme.spacing12),
                              child: Row(
                                children: [
                                  Icon(Icons.business),
                                  SizedBox(width: AppTheme.spacing12),
                                  Text('Service Provider'),
                                ],
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                if (_selectedRole == 'vendor') ...[
                  const SizedBox(height: AppTheme.spacing24),
                  Text(
                    'Business Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      hintText: 'Business Name',
                      prefixIcon: Icon(Icons.business_center_outlined),
                    ),
                    validator: (value) => _selectedRole == 'vendor' && (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  TextFormField(
                    controller: _businessRegController,
                    decoration: const InputDecoration(
                      hintText: 'Registration Number',
                      prefixIcon: Icon(Icons.app_registration),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBusinessType,
                    decoration: const InputDecoration(
                      hintText: 'Business Type',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'individual', child: Text('Individual')),
                      DropdownMenuItem(value: 'partnership', child: Text('Partnership')),
                      DropdownMenuItem(value: 'pvt_ltd', child: Text('Pvt. Ltd.')),
                    ],
                    onChanged: (value) => setState(() => _selectedBusinessType = value!),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  TextFormField(
                    controller: _businessDescController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Business Description',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  
                  Text(
                    'Service Types',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Wrap(
                    spacing: 8,
                    children: ['Washing', 'Polishing', 'Cleaning', 'Drying'].map((type) {
                      final isSelected = _selectedServiceTypes.contains(type);
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedServiceTypes.add(type);
                            } else {
                              _selectedServiceTypes.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  
                  Text(
                    'Bank Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  TextFormField(
                    controller: _bankNameController,
                    decoration: const InputDecoration(
                      hintText: 'Bank Name',
                      prefixIcon: Icon(Icons.account_balance_outlined),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  TextFormField(
                    controller: _bankHolderController,
                    decoration: const InputDecoration(
                      hintText: 'Account Holder Name',
                      prefixIcon: Icon(Icons.person_pin_outlined),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  TextFormField(
                    controller: _bankAccountController,
                    decoration: const InputDecoration(
                      hintText: 'Account Number',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  TextFormField(
                    controller: _bankIfscController,
                    decoration: const InputDecoration(
                      hintText: 'IFSC Code',
                      prefixIcon: Icon(Icons.code),
                    ),
                  ),
                ],
                
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
                  validator: Validators.validatePassword,
                ),
                
                const SizedBox(height: AppTheme.spacing16),
                
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing24),
                
                // Register Button
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, _) {
                    return ElevatedButton(
                      onPressed: authViewModel.isLoading ? null : _handleRegister,
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
                            : const Text('Create Account'),
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
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                            border: Border.all(color: AppTheme.errorColor),
                          ),
                          child: Text(
                            authViewModel.errorMessage ?? '',
                            style: const TextStyle(color: AppTheme.errorColor),
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
        ),
      ),
    );
  }
}