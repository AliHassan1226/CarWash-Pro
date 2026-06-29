// user.dart - Complete User Model

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(
  explicitToJson: true,
  anyMap: true,
  checked: true,
  createFactory: true,
  createToJson: true,
)
class User {
  // Core fields
  final String id;
  final String email;
  final String name;
  
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  
  final String role; // 'customer', 'vendor', 'admin'
  
  // Optional profile fields
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  
  final String? address;
  final double? latitude;
  final double? longitude;
  
  // Verification status
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'is_email_verified')
  final bool isEmailVerified;
  
  @JsonKey(name: 'is_phone_verified')
  final bool isPhoneVerified;
  
  // Device and session info
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;
  
  @JsonKey(name: 'device_token')
  final String? deviceToken;
  
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;
  
  // Additional data
  final Map<String, dynamic>? metadata;
  
  // Timestamps
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  // Constructor
  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.role,
    this.profileImageUrl,
    this.address,
    this.latitude,
    this.longitude,
    this.isVerified = false,
    this.isActive = true,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.lastLogin,
    this.deviceToken,
    this.fcmToken,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON serialization methods
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Copy with method for immutability
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? role,
    String? profileImageUrl,
    String? address,
    double? latitude,
    double? longitude,
    bool? isVerified,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? lastLogin,
    String? deviceToken,
    String? fcmToken,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      lastLogin: lastLogin ?? this.lastLogin,
      deviceToken: deviceToken ?? this.deviceToken,
      fcmToken: fcmToken ?? this.fcmToken,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Role check utilities
  bool get isCustomer => role == 'customer';
  bool get isVendor => role == 'vendor';
  bool get isAdmin => role == 'admin';

  // Verification utilities
  bool get isFullyVerified => isEmailVerified && isPhoneVerified;
  
  bool get isPartiallyVerified => isEmailVerified || isPhoneVerified;
  
  bool get needsVerification => !isFullyVerified;

  // Account status utilities
  bool get canLogin => isActive && isVerified;
  
  bool get isNewUser {
    final now = DateTime.now();
    final dayAgo = now.subtract(const Duration(days: 1));
    return createdAt.isAfter(dayAgo);
  }

  // Helper method to get display name
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  // Helper method to get initials for avatar
  String get initials {
    if (name.isEmpty) return '';
    
    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    }
    
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    
    return name[0].toUpperCase();
  }

  // Check if user has location data
  bool get hasLocation => latitude != null && longitude != null;

  // Check if user has complete profile
  bool get hasCompleteProfile {
    return name.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        address != null &&
        address!.isNotEmpty &&
        profileImageUrl != null &&
        profileImageUrl!.isNotEmpty;
  }

  // Get profile completion percentage
  double get profileCompletionPercentage {
    int totalFields = 0;
    int completedFields = 0;
    
    // Required fields
    if (name.isNotEmpty) completedFields++;
    totalFields++;
    
    if (email.isNotEmpty) completedFields++;
    totalFields++;
    
    if (phoneNumber.isNotEmpty) completedFields++;
    totalFields++;
    
    // Optional fields
    if (address != null && address!.isNotEmpty) completedFields++;
    totalFields++;
    
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) completedFields++;
    totalFields++;
    
    if (latitude != null && longitude != null) completedFields++;
    totalFields++;
    
    return totalFields > 0 ? (completedFields / totalFields) * 100 : 0;
  }

  // Create a vendor profile from user (for vendors)
  Map<String, dynamic> toVendorProfile() {
    if (!isVendor) {
      throw Exception('User is not a vendor');
    }
    
    return {
      'userId': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create a map for API updates (only changed fields)
  Map<String, dynamic> toUpdateMap(User original) {
    final updateMap = <String, dynamic>{};
    
    if (name != original.name) updateMap['name'] = name;
    if (phoneNumber != original.phoneNumber) updateMap['phone_number'] = phoneNumber;
    if (profileImageUrl != original.profileImageUrl) updateMap['profile_image_url'] = profileImageUrl;
    if (address != original.address) updateMap['address'] = address;
    if (latitude != original.latitude) updateMap['latitude'] = latitude;
    if (longitude != original.longitude) updateMap['longitude'] = longitude;
    if (metadata != original.metadata) updateMap['metadata'] = metadata;
    
    return updateMap;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, isVerified: $isVerified, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      phoneNumber,
    );
  }
}

// Extension for additional user-related utilities
extension UserListExtension on List<User> {
  List<User> get activeUsers => where((user) => user.isActive).toList();
  
  List<User> get verifiedUsers => where((user) => user.isVerified).toList();
  
  List<User> get customers => where((user) => user.isCustomer).toList();
  
  List<User> get vendors => where((user) => user.isVendor).toList();
  
  List<User> get admins => where((user) => user.isAdmin).toList();
  
  List<User> get newlyRegistered {
    final now = DateTime.now();
    final dayAgo = now.subtract(const Duration(days: 1));
    return where((user) => user.createdAt.isAfter(dayAgo)).toList();
  }
  
  Map<String, int> get roleDistribution {
    return {
      'customer': customers.length,
      'vendor': vendors.length,
      'admin': admins.length,
    };
  }
  
  List<User> search(String query) {
    if (query.isEmpty) return this;
    
    final lowerQuery = query.toLowerCase();
    return where((user) =>
      user.name.toLowerCase().contains(lowerQuery) ||
      user.email.toLowerCase().contains(lowerQuery) ||
      user.phoneNumber.contains(query)
    ).toList();
  }
}

// Enum for user roles
enum UserRole {
  customer,
  vendor,
  admin;
  
  @override
  String toString() => name;
  
  static UserRole fromString(String role) {
    switch (role) {
      case 'customer':
        return UserRole.customer;
      case 'vendor':
        return UserRole.vendor;
      case 'admin':
        return UserRole.admin;
      default:
        throw ArgumentError('Invalid role: $role');
    }
  }
}

// Constants for user-related configuration
class UserConstants {
  static const List<String> validRoles = ['customer', 'vendor', 'admin'];
  
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  
  static const int phoneNumberLength = 10;
  
  static const double defaultLatitude = 0.0;
  static const double defaultLongitude = 0.0;
  
  static const String defaultProfileImageUrl = 'assets/images/default_avatar.png';
  
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration verificationTimeout = Duration(minutes: 10);
}