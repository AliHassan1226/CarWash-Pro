// Admin repository
// Admin Repository
// Purpose: Handles all admin-specific operations and dashboard management
// Author: CarWash Pro Development Team
// Date: March 3, 2026

import 'package:car_wash_app/data/datasources/remote/api_service.dart';
import 'package:car_wash_app/core/constants/api_endpoints.dart';

/// AdminRepository handles all administrative operations
/// 
/// Responsibilities:
/// - User management
/// - Vendor management and verification
/// - Order monitoring and management
/// - Revenue tracking and analytics
/// - System settings and configuration
/// - Dispute resolution
class AdminRepository {
  final ApiService apiService;

  AdminRepository({required this.apiService});

  // ==================== DASHBOARD & ANALYTICS ====================

  /// Get admin dashboard data
  /// 
  /// Returns: DashboardStats containing key metrics
  /// 
  /// Throws: Exception if fetch fails
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await apiService.get(ApiEndpoints.adminDashboard);

      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get dashboard stats error: ${e.toString()}');
    }
  }

  /// Get revenue analytics
  /// 
  /// Parameters:
  ///   - startDate: Start date for analytics period
  ///   - endDate: End date for analytics period
  /// 
  /// Returns: RevenueAnalytics containing revenue data
  /// 
  /// Throws: Exception if fetch fails
  Future<RevenueAnalytics> getRevenueAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await apiService.get(
        ApiEndpoints.adminRevenueAnalytics ?? '',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return RevenueAnalytics.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get revenue analytics error: ${e.toString()}');
    }
  }

  /// Get system analytics
  /// 
  /// Returns: SystemAnalytics containing system-wide metrics
  /// 
  /// Throws: Exception if fetch fails
  Future<SystemAnalytics> getSystemAnalytics() async {
    try {
      final response = await apiService.get(ApiEndpoints.adminSystemAnalytics ?? '');

      if (response.statusCode == 200) {
        return SystemAnalytics.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get system analytics error: ${e.toString()}');
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Get all users with pagination
  /// 
  /// Parameters:
  ///   - page: Page number (starting from 1)
  ///   - pageSize: Number of items per page
  ///   - role: Filter by user role (optional)
  ///   - searchQuery: Search by email or name (optional)
  /// 
  /// Returns: Paginated list of users
  /// 
  /// Throws: Exception if fetch fails
  Future<PaginatedUsers> getAllUsers({
    required int page,
    required int pageSize,
    String? role,
    String? searchQuery,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response = await apiService.get(
        ApiEndpoints.adminUsers ?? '',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedUsers.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get users error: ${e.toString()}');
    }
  }

  /// Get user details
  /// 
  /// Parameters:
  ///   - userId: ID of user to fetch
  /// 
  /// Returns: UserDetailsModel with complete user information
  /// 
  /// Throws: Exception if fetch fails
  Future<UserDetailsModel> getUserDetails(String userId) async {
    try {
      final response = await apiService.get(
        '${ApiEndpoints.adminUsers}/$userId',
      );

      if (response.statusCode == 200) {
        return UserDetailsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get user details error: ${e.toString()}');
    }
  }

  /// Suspend/block a user
  /// 
  /// Parameters:
  ///   - userId: ID of user to suspend
  ///   - reason: Reason for suspension
  /// 
  /// Throws: Exception if operation fails
  Future<void> suspendUser({
    required String userId,
    required String reason,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.adminUsers}/$userId/suspend',
        data: {'reason': reason},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Suspend user error: ${e.toString()}');
    }
  }

  /// Unsuspend/unblock a user
  /// 
  /// Parameters:
  ///   - userId: ID of user to unsuspend
  /// 
  /// Throws: Exception if operation fails
  Future<void> unsuspendUser(String userId) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.adminUsers}/$userId/unsuspend',
        data: {},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Unsuspend user error: ${e.toString()}');
    }
  }

  /// Delete a user account
  /// 
  /// Parameters:
  ///   - userId: ID of user to delete
  ///   - reason: Reason for deletion
  /// 
  /// Throws: Exception if operation fails
  Future<void> deleteUser({
    required String userId,
    required String reason,
  }) async {
    try {
      final response = await apiService.delete(
        '${ApiEndpoints.adminUsers}/$userId',
        data: {'reason': reason},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Delete user error: ${e.toString()}');
    }
  }

  // ==================== VENDOR MANAGEMENT ====================

  /// Get all vendors with pagination
  /// 
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///   - status: Filter by verification status (optional)
  /// 
  /// Returns: Paginated list of vendors
  /// 
  /// Throws: Exception if fetch fails
  Future<PaginatedVendors> getAllVendors({
    required int page,
    required int pageSize,
    String? status,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await apiService.get(
        ApiEndpoints.adminVendors ?? '',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedVendors.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get vendors error: ${e.toString()}');
    }
  }

  /// Get vendor details
  /// 
  /// Parameters:
  ///   - vendorId: ID of vendor to fetch
  /// 
  /// Returns: VendorDetailsModel with complete vendor information
  /// 
  /// Throws: Exception if fetch fails
  Future<VendorDetailsModel> getVendorDetails(String vendorId) async {
    try {
      final response = await apiService.get(
        '${ApiEndpoints.adminVendors}/$vendorId',
      );

      if (response.statusCode == 200) {
        return VendorDetailsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get vendor details error: ${e.toString()}');
    }
  }

  /// Verify vendor account
  /// 
  /// Parameters:
  ///   - vendorId: ID of vendor to verify
  ///   - notes: Verification notes
  /// 
  /// Throws: Exception if operation fails
  Future<void> verifyVendor({
    required String vendorId,
    String? notes,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }
      
      final response = await apiService.post(
        '${ApiEndpoints.adminVendors}/$vendorId/verify',
        data: data,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Verify vendor error: ${e.toString()}');
    }
  }

  /// Reject vendor verification
  /// 
  /// Parameters:
  ///   - vendorId: ID of vendor to reject
  ///   - reason: Reason for rejection
  /// 
  /// Throws: Exception if operation fails
  Future<void> rejectVendor({
    required String vendorId,
    required String reason,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.adminVendors}/$vendorId/reject',
        data: {'reason': reason},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Reject vendor error: ${e.toString()}');
    }
  }

  /// Suspend vendor account
  /// 
  /// Parameters:
  ///   - vendorId: ID of vendor to suspend
  ///   - reason: Reason for suspension
  /// 
  /// Throws: Exception if operation fails
  Future<void> suspendVendor({
    required String vendorId,
    required String reason,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.adminVendors}/$vendorId/suspend',
        data: {'reason': reason},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Suspend vendor error: ${e.toString()}');
    }
  }

  /// Unsuspend vendor account
  /// 
  /// Parameters:
  ///   - vendorId: ID of vendor to unsuspend
  /// 
  /// Throws: Exception if operation fails
  Future<void> unsuspendVendor(String vendorId) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.adminVendors}/$vendorId/unsuspend',
        data: {},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Unsuspend vendor error: ${e.toString()}');
    }
  }

  // ==================== ORDER MANAGEMENT ====================

  /// Get all orders with pagination
  /// 
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///   - status: Filter by status (optional)
  /// 
  /// Returns: Paginated list of orders
  /// 
  /// Throws: Exception if fetch fails
  Future<PaginatedOrders> getAllOrders({
    required int page,
    required int pageSize,
    String? status,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await apiService.get(
        ApiEndpoints.adminOrders ?? '',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedOrders.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get orders error: ${e.toString()}');
    }
  }

  /// Get order details
  /// 
  /// Parameters:
  ///   - orderId: ID of order to fetch
  /// 
  /// Returns: OrderDetailsModel with complete order information
  /// 
  /// Throws: Exception if fetch fails
  Future<OrderDetailsModel> getOrderDetails(String orderId) async {
    try {
      final response = await apiService.get(
        '${ApiEndpoints.adminOrders}/$orderId',
      );

      if (response.statusCode == 200) {
        return OrderDetailsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get order details error: ${e.toString()}');
    }
  }

  /// Cancel an order
  /// 
  /// Parameters:
  ///   - orderId: ID of order to cancel
  ///   - reason: Reason for cancellation
  /// 
  /// Throws: Exception if operation fails
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.adminOrders}/$orderId/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Cancel order error: ${e.toString()}');
    }
  }

  // ==================== DISPUTE MANAGEMENT ====================

  /// Get all disputes with pagination
  /// 
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///   - status: Filter by status (optional)
  /// 
  /// Returns: Paginated list of disputes
  /// 
  /// Throws: Exception if fetch fails
  Future<PaginatedDisputes> getAllDisputes({
    required int page,
    required int pageSize,
    String? status,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await apiService.get(
        ApiEndpoints.adminDisputes ?? '',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedDisputes.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get disputes error: ${e.toString()}');
    }
  }

  /// Resolve a dispute
  /// 
  /// Parameters:
  ///   - disputeId: ID of dispute to resolve
  ///   - resolution: Resolution decision and notes
  /// 
  /// Throws: Exception if operation fails
  Future<void> resolveDispute({
    required String disputeId,
    required String resolution,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.adminDisputes}/$disputeId/resolve',
        data: {'resolution': resolution},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Resolve dispute error: ${e.toString()}');
    }
  }

  // ==================== SYSTEM MANAGEMENT ====================

  /// Get system settings
  /// 
  /// Returns: SystemSettings containing all system configuration
  /// 
  /// Throws: Exception if fetch fails
  Future<SystemSettings> getSystemSettings() async {
    try {
      final response = await apiService.get(ApiEndpoints.adminSettings ?? '');

      if (response.statusCode == 200) {
        return SystemSettings.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Get settings error: ${e.toString()}');
    }
  }

  /// Update system settings
  /// 
  /// Parameters:
  ///   - settings: Updated settings data
  /// 
  /// Returns: Updated SystemSettings
  /// 
  /// Throws: Exception if update fails
  Future<SystemSettings> updateSystemSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final response = await apiService.put(
        ApiEndpoints.adminSettings ?? '',
        data: settings,
      );

      if (response.statusCode == 200) {
        return SystemSettings.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } catch (e) {
      throw Exception('Update settings error: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Handle API error responses
  Exception _handleApiError(int statusCode) {
    switch (statusCode) {
      case 400:
        return Exception('Invalid request data');
      case 401:
        return Exception('Unauthorized - Admin access required');
      case 403:
        return Exception('Forbidden - Insufficient permissions');
      case 404:
        return Exception('Resource not found');
      case 429:
        return Exception('Too many requests - Please try again later');
      case 500:
        return Exception('Server error - Please try again later');
      default:
        return Exception('Error: $statusCode');
    }
  }
}

// ==================== DATA MODELS ====================

/// Dashboard statistics model
class DashboardStats {
  final int totalUsers;
  final int totalVendors;
  final int totalOrders;
  final int pendingOrders;
  final double totalRevenue;
  final double platformFees;
  final int suspendedUsers;
  final int unverifiedVendors;

  DashboardStats({
    required this.totalUsers,
    required this.totalVendors,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalRevenue,
    required this.platformFees,
    required this.suspendedUsers,
    required this.unverifiedVendors,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalVendors: json['totalVendors'] as int? ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      pendingOrders: json['pendingOrders'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      platformFees: (json['platformFees'] as num?)?.toDouble() ?? 0.0,
      suspendedUsers: json['suspendedUsers'] as int? ?? 0,
      unverifiedVendors: json['unverifiedVendors'] as int? ?? 0,
    );
  }
}

/// Revenue analytics model
class RevenueAnalytics {
  final double totalRevenue;
  final double platformFees;
  final double vendorEarnings;
  final int orderCount;
  final List<Map<String, dynamic>> dailyRevenue;

  RevenueAnalytics({
    required this.totalRevenue,
    required this.platformFees,
    required this.vendorEarnings,
    required this.orderCount,
    required this.dailyRevenue,
  });

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    return RevenueAnalytics(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      platformFees: (json['platformFees'] as num?)?.toDouble() ?? 0.0,
      vendorEarnings: (json['vendorEarnings'] as num?)?.toDouble() ?? 0.0,
      orderCount: json['orderCount'] as int? ?? 0,
      dailyRevenue: (json['dailyRevenue'] as List?)
              ?.map((item) => Map<String, dynamic>.from(item as Map))
              .toList() ??
          [],
    );
  }
}

/// System analytics model
class SystemAnalytics {
  final int activeUsers;
  final int activeVendors;
  final double averageRating;
  final double responseTime;
  final int systemErrors;

  SystemAnalytics({
    required this.activeUsers,
    required this.activeVendors,
    required this.averageRating,
    required this.responseTime,
    required this.systemErrors,
  });

  factory SystemAnalytics.fromJson(Map<String, dynamic> json) {
    return SystemAnalytics(
      activeUsers: json['activeUsers'] as int? ?? 0,
      activeVendors: json['activeVendors'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      responseTime: (json['responseTime'] as num?)?.toDouble() ?? 0.0,
      systemErrors: json['systemErrors'] as int? ?? 0,
    );
  }
}

/// Paginated users model
class PaginatedUsers {
  final List<UserDetailsModel> users;
  final int total;
  final int page;
  final int pageSize;

  PaginatedUsers({
    required this.users,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedUsers.fromJson(Map<String, dynamic> json) {
    return PaginatedUsers(
      users: (json['users'] as List?)
              ?.map((u) => UserDetailsModel.fromJson(u as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }
}

/// User details model
class UserDetailsModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isSuspended;
  final DateTime createdAt;

  UserDetailsModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isSuspended,
    required this.createdAt,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isSuspended: json['isSuspended'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Paginated vendors model
class PaginatedVendors {
  final List<VendorDetailsModel> vendors;
  final int total;
  final int page;
  final int pageSize;

  PaginatedVendors({
    required this.vendors,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedVendors.fromJson(Map<String, dynamic> json) {
    return PaginatedVendors(
      vendors: (json['vendors'] as List?)
              ?.map((v) => VendorDetailsModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }
}

/// Vendor details model
class VendorDetailsModel {
  final String id;
  final String businessName;
  final bool isVerified;
  final bool isSuspended;
  final double rating;
  final int orderCount;
  final DateTime createdAt;

  VendorDetailsModel({
    required this.id,
    required this.businessName,
    required this.isVerified,
    required this.isSuspended,
    required this.rating,
    required this.orderCount,
    required this.createdAt,
  });

  factory VendorDetailsModel.fromJson(Map<String, dynamic> json) {
    return VendorDetailsModel(
      id: json['id'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      isSuspended: json['isSuspended'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      orderCount: json['orderCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Paginated orders model
class PaginatedOrders {
  final List<OrderDetailsModel> orders;
  final int total;
  final int page;
  final int pageSize;

  PaginatedOrders({
    required this.orders,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedOrders.fromJson(Map<String, dynamic> json) {
    return PaginatedOrders(
      orders: (json['orders'] as List?)
              ?.map((o) => OrderDetailsModel.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }
}

/// Order details model
class OrderDetailsModel {
  final String id;
  final String customerId;
  final String vendorId;
  final String status;
  final double totalAmount;
  final DateTime createdAt;

  OrderDetailsModel({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Paginated disputes model
class PaginatedDisputes {
  final List<DisputeModel> disputes;
  final int total;
  final int page;
  final int pageSize;

  PaginatedDisputes({
    required this.disputes,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedDisputes.fromJson(Map<String, dynamic> json) {
    return PaginatedDisputes(
      disputes: (json['disputes'] as List?)
              ?.map((d) => DisputeModel.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }
}

/// Dispute model
class DisputeModel {
  final String id;
  final String orderId;
  final String status;
  final DateTime createdAt;

  DisputeModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.createdAt,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// System settings model
class SystemSettings {
  final double platformFeePercentage;
  final String supportEmail;
  final bool maintenanceMode;

  SystemSettings({
    required this.platformFeePercentage,
    required this.supportEmail,
    required this.maintenanceMode,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      platformFeePercentage: (json['platformFeePercentage'] as num?)?.toDouble() ?? 0.0,
      supportEmail: json['supportEmail'] as String? ?? '',
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
    );
  }
}