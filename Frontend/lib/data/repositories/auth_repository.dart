import 'package:car_wash_app/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:car_wash_app/data/datasources/remote/api_service.dart';
import 'package:car_wash_app/core/constants/api_endpoints.dart';
import 'package:car_wash_app/core/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final ApiService apiService;
  final SharedPreferences sharedPreferences;

  AuthRepository({
    required this.apiService,
    required this.sharedPreferences,
  });

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      if (email == AppConstants.adminEmail) {
        // Admin flow
        if (password != AppConstants.defaultPassword) {
          throw Exception('Invalid password');
        }
        
        final user = User(
          id: 'admin_id_1',
          email: email,
          name: 'Admin User',
          phoneNumber: '+1234567890',
          role: 'admin',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          isVerified: true,
        );
        
        const token = 'mock_admin_token';
        
        await sharedPreferences.setString(AppConstants.userTokenKey, token);
        await sharedPreferences.setString(AppConstants.userIdKey, user.id);
        await sharedPreferences.setString(AppConstants.userEmailKey, user.email);
        await sharedPreferences.setString(AppConstants.userRoleKey, user.role);
        await sharedPreferences.setBool(AppConstants.isLoggedInKey, true);
        
        apiService.setAuthToken(token);
        
        return {
          'success': true,
          'user': user,
          'token': token,
          'refreshToken': 'mock_refresh_token',
        };
      } else {
        // Firebase Auth Flow for customer/vendor
        final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        final firebaseUser = userCredential.user;
        if (firebaseUser == null) {
          throw Exception('Failed to log in via Firebase');
        }
        
        final doc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
        if (!doc.exists) {
          throw Exception('User profile not found in database');
        }
        
        final data = doc.data()!;
        data['id'] = firebaseUser.uid;
        // ensure dates are properly formatted before parsing if needed, but fromJson should handle ISO strings or Timestamps
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
        }
        final user = User.fromJson(data);
        
        final token = await firebaseUser.getIdToken() ?? 'firebase_token';
        
        await sharedPreferences.setString(AppConstants.userTokenKey, token);
        await sharedPreferences.setString(AppConstants.userIdKey, user.id);
        await sharedPreferences.setString(AppConstants.userEmailKey, user.email);
        await sharedPreferences.setString(AppConstants.userRoleKey, user.role);
        await sharedPreferences.setBool(AppConstants.isLoggedInKey, true);
        
        apiService.setAuthToken(token);
        
        return {
          'success': true,
          'user': user,
          'token': token,
          'refreshToken': 'firebase_refresh_token',
        };
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> register({
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
    try {
      if (email == AppConstants.adminEmail) {
         throw Exception('Cannot register admin address');
      }

      final userCredential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create account');
      }
      
      final userData = {
        'id': firebaseUser.uid,
        'email': email,
        'name': name,
        'phone_number': phoneNumber,
        'role': role,
        'is_active': true,
        'is_verified': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set(userData);
      
      // If role is vendor, also create a basic profile in vendors collection
      if (role == 'vendor') {
        final vendorData = {
          'id': firebaseUser.uid,
          'userId': firebaseUser.uid,
          'businessName': businessName ?? name,
          'businessRegistration': businessRegistration ?? '',
          'businessType': businessType ?? 'individual',
          'businessCategory': 'Car Wash',
          'businessDescription': businessDescription ?? 'No description provided yet.',
          'serviceTypes': serviceTypes ?? [],
          'bankAccountNumber': bankAccountNumber ?? '',
          'bankIfscCode': bankIfscCode ?? '',
          'bankAccountHolderName': bankAccountHolderName ?? name,
          'bankName': bankName ?? '',
          'isVerified': false,
          'rating': 0.0,
          'orderCount': 0,
          'completedOrders': 0,
          'cancelledOrders': 0,
          'totalEarnings': 0.0,
          'totalServices': 0,
          'activeServices': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        await FirebaseFirestore.instance.collection('vendors').doc(firebaseUser.uid).set(vendorData);
      }
      
      final user = User.fromJson(userData);
      final token = await firebaseUser.getIdToken() ?? 'firebase_token';

      // Save to local storage
      await sharedPreferences.setString(AppConstants.userTokenKey, token);
      await sharedPreferences.setString(AppConstants.userIdKey, user.id);
      await sharedPreferences.setString(AppConstants.userEmailKey, user.email);
      await sharedPreferences.setString(AppConstants.userRoleKey, user.role);
      await sharedPreferences.setBool(AppConstants.isLoggedInKey, true);

      // Set auth token for future requests
      apiService.setAuthToken(token);

      return {
        'success': true,
        'user': user,
        'token': token,
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use. Please log in instead.';
      } else if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _safeFirebaseSignOut();

      // Clear local storage
      await sharedPreferences.remove(AppConstants.userTokenKey);
      await sharedPreferences.remove(AppConstants.userIdKey);
      await sharedPreferences.remove(AppConstants.userEmailKey);
      await sharedPreferences.remove(AppConstants.userRoleKey);
      await sharedPreferences.setBool(AppConstants.isLoggedInKey, false);

      // Clear auth token
      apiService.clearAuthToken();
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      } else {
        throw Exception('Failed to send reset email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Forgot password error: $e');
    }
  }

  // Reset Password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reset password: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Reset password error: $e');
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    try {
      final userId = getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw Exception('User profile not found');
      }

      final data = doc.data()!;
      data['id'] = doc.id;
      
      // Handle potential Timestamp fields from Firestore
      if (data['created_at'] is Timestamp) {
        data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updated_at'] is Timestamp) {
        data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
      }
      
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }

  // Update profile
  Future<User> updateProfile(Map<String, dynamic> data) async {
    try {
      final userId = getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      data['updated_at'] = DateTime.now().toIso8601String();
      await FirebaseFirestore.instance.collection('users').doc(userId).update(data);
      
      return await getProfile();
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return sharedPreferences.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  // Get stored user role
  String? getUserRole() {
    return sharedPreferences.getString(AppConstants.userRoleKey);
  }

  // Get stored user token
  String? getUserToken() {
    return sharedPreferences.getString(AppConstants.userTokenKey);
  }

  // Get stored user ID
  String? getUserId() {
    return sharedPreferences.getString(AppConstants.userIdKey);
  }

  // Initialize auth on app start
  Future<void> initializeAuth() async {
    final token = getUserToken();
    final storedRole = getUserRole();
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    // Handle admin mock session restoration
    if (storedRole == 'admin' && token != null) {
      await sharedPreferences.setBool(AppConstants.isLoggedInKey, true);
      apiService.setAuthToken(token);
      return;
    }

    // Restore Firebase-backed customer/vendor session if possible
    if (firebaseUser != null) {
      final refreshedToken = await firebaseUser.getIdToken();
      if (refreshedToken != null) {
        await sharedPreferences.setString(AppConstants.userTokenKey, refreshedToken);
        await sharedPreferences.setString(AppConstants.userIdKey, firebaseUser.uid);
      }

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        final role = userDoc.data()?['role']?.toString();
        if (role != null && role.isNotEmpty) {
          await sharedPreferences.setString(AppConstants.userRoleKey, role);
        }
      }

      await sharedPreferences.setBool(AppConstants.isLoggedInKey, true);
      apiService.setAuthToken(refreshedToken ?? token ?? 'firebase_token');
      return;
    }

    // No valid session - clear any stale persisted auth
    await sharedPreferences.setBool(AppConstants.isLoggedInKey, false);
    await sharedPreferences.remove(AppConstants.userTokenKey);
    await sharedPreferences.remove(AppConstants.userIdKey);
    await sharedPreferences.remove(AppConstants.userEmailKey);
    await sharedPreferences.remove(AppConstants.userRoleKey);
    apiService.clearAuthToken();
  }

  Future<void> _safeFirebaseSignOut() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
    } catch (_) {
      // Ignore signout failures for mock-admin sessions.
    }
  }
}