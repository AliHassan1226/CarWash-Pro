// Common input validators

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  // OTP validation
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6 || !value.contains(RegExp(r'^[0-9]{6}$'))) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  // Business name validation
  static String? validateBusinessName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Business name is required';
    }
    if (value.length < 3) {
      return 'Business name must be at least 3 characters long';
    }
    return null;
  }

  // Car plate validation
  static String? validateCarPlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Car plate number is required';
    }
    final plateRegex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}$');
    if (!plateRegex.hasMatch(value.toUpperCase())) {
      return 'Please enter a valid car plate number';
    }
    return null;
  }
}
