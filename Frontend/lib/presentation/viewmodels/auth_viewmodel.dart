// Authentication view model

import 'package:flutter/foundation.dart';
import 'package:car_wash_app/data/repositories/auth_repository.dart';
import 'package:car_wash_app/data/models/user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  // State variables
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _userRole;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;

  // Initialize auth on app start
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.initializeAuth();
      _isAuthenticated = _authRepository.isAuthenticated();
      _userRole = _authRepository.getUserRole();

      if (_isAuthenticated) {
        final user = await _authRepository.getProfile();
        _currentUser = user as User?;
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(email, password);

      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
        _userRole = _currentUser?.role;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String role,
    String? businessName,
    String? businessRegistration,
    String? businessType,
    String? businessDescription,
    List<String>? serviceTypes,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankAccountHolderName,
    String? bankName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.register(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
        businessName: businessName,
        businessRegistration: businessRegistration,
        businessType: businessType,
        businessDescription: businessDescription,
        serviceTypes: serviceTypes,
        bankAccountNumber: bankAccountNumber,
        bankIfscCode: bankIfscCode,
        bankAccountHolderName: bankAccountHolderName,
        bankName: bankName,
      );

      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
        _userRole = _currentUser?.role;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _userRole = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.forgotPassword(email);

      if (result['success']) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to send reset email';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authRepository.updateProfile(data);
      _currentUser = updatedUser as User?;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
