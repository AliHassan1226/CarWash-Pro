// Vendor repository

// Vendor Repository
// Purpose: Handles all vendor-specific operations and business management
// Author: CarWash Pro Development Team
// Date: March 3, 2026

import 'package:car_wash_app/data/datasources/remote/api_service.dart';
import 'package:car_wash_app/core/constants/api_endpoints.dart';
import 'package:car_wash_app/data/models/vendor.dart';

/// VendorRepository handles all vendor-related operations
///
/// Responsibilities:
/// - Service management (create, edit, delete)
/// - Order management and acceptance
/// - Business profile management
/// - Earnings tracking and withdrawal
/// - Analytics and reporting
/// - Vendor verification
class VendorRepository {
  final ApiService apiService;

  VendorRepository({required this.apiService});

  // ==================== SERVICE MANAGEMENT ====================

  /// Get vendor's services with pagination
  ///
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///   - status: Filter by status (active/inactive)
  ///
  /// Returns: Paginated list of services
  ///
  /// Throws: Exception if fetch fails
  Future<PaginatedServices> getVendorServices({
    required int page,
    required int pageSize,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (status != null) queryParams['status'] = status;

      final response = await apiService.get(
        ApiEndpoints.vendorServices ?? '',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedServices.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get services error: ${e.toString()}');
    }
  }

  /// Get service details
  ///
  /// Parameters:
  ///   - serviceId: ID of service to fetch
  ///
  /// Returns: ServiceDetailsModel with complete service information
  ///
  /// Throws: Exception if fetch fails
  Future<ServiceDetailsModel> getServiceDetails(String serviceId) async {
    try {
      final response = await apiService.get(
        '${ApiEndpoints.vendorServices ?? ''}/$serviceId',
      );

      if (response.statusCode == 200) {
        return ServiceDetailsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get service details error: ${e.toString()}');
    }
  }

  /// Create new service
  ///
  /// Parameters:
  ///   - serviceData: Service details (name, description, price, duration, category)
  ///
  /// Returns: ServiceDetailsModel with created service
  ///
  /// Throws: Exception if creation fails
  Future<ServiceDetailsModel> createService(
    Map<String, dynamic> serviceData,
  ) async {
    try {
      if (serviceData.isEmpty) {
        throw Exception('Service data is required');
      }

      final response = await apiService.post(
        ApiEndpoints.vendorServices ?? '',
        data: serviceData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceDetailsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Create service error: ${e.toString()}');
    }
  }

  /// Update service
  ///
  /// Parameters:
  ///   - serviceId: ID of service to update
  ///   - updateData: Fields to update
  ///
  /// Returns: Updated ServiceDetailsModel
  ///
  /// Throws: Exception if update fails
  Future<ServiceDetailsModel> updateService({
    required String serviceId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      if (updateData.isEmpty) {
        throw Exception('Update data is required');
      }

      final response = await apiService.put(
        '${ApiEndpoints.vendorServices ?? ''}/$serviceId',
        data: updateData,
      );

      if (response.statusCode == 200) {
        return ServiceDetailsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Update service error: ${e.toString()}');
    }
  }

  /// Delete service
  ///
  /// Parameters:
  ///   - serviceId: ID of service to delete
  ///
  /// Throws: Exception if deletion fails
  Future<void> deleteService(String serviceId) async {
    try {
      final response = await apiService.delete(
        '${ApiEndpoints.vendorServices ?? ''}/$serviceId',
        data: {},
      );

      if (response.statusCode != 200) {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Delete service error: ${e.toString()}');
    }
  }

  /// Toggle service active/inactive status
  ///
  /// Parameters:
  ///   - serviceId: ID of service
  ///   - isActive: New active status
  ///
  /// Returns: Updated ServiceDetailsModel
  ///
  /// Throws: Exception if operation fails
  Future<ServiceDetailsModel> toggleServiceStatus({
    required String serviceId,
    required bool isActive,
  }) async {
    try {
      final response = await apiService.patch(
        '${ApiEndpoints.vendorServices ?? ''}/$serviceId/status',
        data: {'isActive': isActive},
      );

      if (response.statusCode == 200) {
        return ServiceDetailsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Toggle service status error: ${e.toString()}');
    }
  }

  // ==================== ORDER MANAGEMENT ====================

  /// Get vendor's orders with pagination
  ///
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///   - status: Filter by status (optional)
  ///   - dateFrom: Filter from date (optional)
  ///   - dateTo: Filter to date (optional)
  ///
  /// Returns: Paginated list of orders
  ///
  /// Throws: Exception if fetch fails
  Future<PaginatedOrders> getVendorOrders({
    required int page,
    required int pageSize,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (status != null) queryParams['status'] = status;
      if (dateFrom != null) {
        queryParams['dateFrom'] = dateFrom.toIso8601String();
      }
      if (dateTo != null) queryParams['dateTo'] = dateTo.toIso8601String();

      final response = await apiService.get(
        ApiEndpoints.vendorOrders ?? '',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedOrders.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get orders error: ${e.toString()}');
    }
  }

  /// Accept order
  ///
  /// Parameters:
  ///   - orderId: ID of order to accept
  ///   - estimatedDuration: Estimated service duration
  ///
  /// Returns: Updated OrderModel
  ///
  /// Throws: Exception if operation fails
  Future<OrderModel> acceptOrder({
    required String orderId,
    required int estimatedDuration,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.vendorOrders ?? ''}/$orderId/accept',
        data: {'estimatedDuration': estimatedDuration},
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Accept order error: ${e.toString()}');
    }
  }

  /// Reject order
  ///
  /// Parameters:
  ///   - orderId: ID of order to reject
  ///   - reason: Reason for rejection
  ///
  /// Throws: Exception if operation fails
  Future<void> rejectOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.vendorOrders ?? ''}/$orderId/reject',
        data: {'reason': reason},
      );

      if (response.statusCode != 200) {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Reject order error: ${e.toString()}');
    }
  }

  /// Start service on order
  ///
  /// Parameters:
  ///   - orderId: ID of order
  ///
  /// Returns: Updated OrderModel
  ///
  /// Throws: Exception if operation fails
  Future<OrderModel> startService(String orderId) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.vendorOrders ?? ''}/$orderId/start',
        data: {},
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Start service error: ${e.toString()}');
    }
  }

  /// Complete service on order
  ///
  /// Parameters:
  ///   - orderId: ID of order
  ///   - notes: Completion notes (optional)
  ///
  /// Returns: Updated OrderModel
  ///
  /// Throws: Exception if operation fails
  Future<OrderModel> completeService({
    required String orderId,
    String? notes,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.vendorOrders ?? ''}/$orderId/complete',
        data: {
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Complete service error: ${e.toString()}');
    }
  }

  // ==================== PROFILE MANAGEMENT ====================

  /// Get vendor profile
  ///
  /// Returns: VendorProfileModel with vendor information
  ///
  /// Throws: Exception if fetch fails
  Future<VendorProfileModel> getProfile() async {
    try {
      final response = await apiService.get(ApiEndpoints.vendorProfile ?? '');

      if (response.statusCode == 200) {
        return VendorProfileModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get profile error: ${e.toString()}');
    }
  }

  /// Update vendor profile
  ///
  /// Parameters:
  ///   - profileData: Profile fields to update
  ///
  /// Returns: Updated VendorProfileModel
  ///
  /// Throws: Exception if update fails
  Future<VendorProfileModel> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      if (profileData.isEmpty) {
        throw Exception('Profile data is required');
      }

      final response = await apiService.put(
        ApiEndpoints.vendorProfile ?? '',
        data: profileData,
      );

      if (response.statusCode == 200) {
        return VendorProfileModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Update profile error: ${e.toString()}');
    }
  }

  // ==================== EARNINGS & PAYMENTS ====================

  /// Get vendor earnings summary
  ///
  /// Returns: EarningsModel with earnings data
  ///
  /// Throws: Exception if fetch fails
  Future<EarningsModel> getEarnings() async {
    try {
      final response = await apiService.get(ApiEndpoints.vendorEarnings ?? '');

      if (response.statusCode == 200) {
        return EarningsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get earnings error: ${e.toString()}');
    }
  }

  /// Get earnings history with pagination
  ///
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///   - dateFrom: Filter from date (optional)
  ///   - dateTo: Filter to date (optional)
  ///
  /// Returns: Paginated list of earnings records
  ///
  /// Throws: Exception if fetch fails
  Future<PaginatedEarnings> getEarningsHistory({
    required int page,
    required int pageSize,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (dateFrom != null) {
        queryParams['dateFrom'] = dateFrom.toIso8601String();
      }
      if (dateTo != null) queryParams['dateTo'] = dateTo.toIso8601String();

      final response = await apiService.get(
        ApiEndpoints.vendorEarningsHistory ?? '',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedEarnings.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get earnings history error: ${e.toString()}');
    }
  }

  /// Request withdrawal
  ///
  /// Parameters:
  ///   - amount: Amount to withdraw
  ///   - bankDetails: Bank account details for transfer
  ///
  /// Returns: WithdrawalModel with withdrawal details
  ///
  /// Throws: Exception if request fails
  Future<WithdrawalModel> requestWithdrawal({
    required double amount,
    required Map<String, dynamic> bankDetails,
  }) async {
    try {
      if (amount <= 0) {
        throw Exception('Withdrawal amount must be greater than 0');
      }

      final response = await apiService.post(
        ApiEndpoints.vendorWithdrawal ?? '',
        data: {
          'amount': amount,
          'bankDetails': bankDetails,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WithdrawalModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Request withdrawal error: ${e.toString()}');
    }
  }

  /// Get withdrawal history
  ///
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///
  /// Returns: Paginated list of withdrawals
  ///
  /// Throws: Exception if fetch fails
  Future<PaginatedWithdrawals> getWithdrawalHistory({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiService.get(
        ApiEndpoints.vendorWithdrawalHistory ?? '',
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      if (response.statusCode == 200) {
        return PaginatedWithdrawals.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get withdrawal history error: ${e.toString()}');
    }
  }

  // ==================== ANALYTICS & REPORTING ====================

  /// Get vendor dashboard analytics
  ///
  /// Returns: DashboardAnalyticsModel with key metrics
  ///
  /// Throws: Exception if fetch fails
  Future<DashboardAnalyticsModel> getDashboardAnalytics() async {
    try {
      final response = await apiService.get(ApiEndpoints.vendorDashboard);

      if (response.statusCode == 200) {
        return DashboardAnalyticsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get dashboard analytics error: ${e.toString()}');
    }
  }

  /// Get detailed analytics report
  ///
  /// Parameters:
  ///   - startDate: Start date for report
  ///   - endDate: End date for report
  ///
  /// Returns: AnalyticsReportModel with detailed data
  ///
  /// Throws: Exception if fetch fails
  Future<AnalyticsReportModel> getAnalyticsReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await apiService.get(
        ApiEndpoints.vendorAnalyticsReport ?? '',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return AnalyticsReportModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get analytics report error: ${e.toString()}');
    }
  }

  /// Get vendor reviews
  ///
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///
  /// Returns: Paginated list of reviews
  ///
  /// Throws: Exception if fetch fails
  Future<PaginatedReviews> getReviews({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiService.get(
        ApiEndpoints.vendorReviews ?? '',
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      if (response.statusCode == 200) {
        return PaginatedReviews.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get reviews error: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Handle API error responses
  Exception _handleApiError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return Exception('Invalid request data');
      case 401:
        return Exception('Unauthorized - Please login');
      case 403:
        return Exception('Forbidden - Vendor access required');
      case 404:
        return Exception('Resource not found');
      case 409:
        return Exception('Conflict - Resource already exists');
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

/// Service model
class ServiceDetailsModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double estimatedDuration;
  final String category;
  final bool isActive;
  final double rating;
  final int reviewCount;

  ServiceDetailsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.estimatedDuration,
    required this.category,
    required this.isActive,
    required this.rating,
    required this.reviewCount,
  });

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      estimatedDuration: (json['estimatedDuration'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? true,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}

/// Paginated services
class PaginatedServices {
  final List<ServiceDetailsModel> services;
  final int total;
  final int page;
  final int pageSize;

  PaginatedServices({
    required this.services,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedServices.fromJson(Map<String, dynamic> json) {
    return PaginatedServices(
      services: (json['services'] as List?)
              ?.map((s) => ServiceDetailsModel.fromJson(s))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}

/// Order model
class OrderModel {
  final String id;
  final String customerId;
  final String status;
  final DateTime bookingDate;
  final double totalAmount;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.status,
    required this.bookingDate,
    required this.totalAmount,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      status: json['status'] ?? 'pending',
      bookingDate:
          DateTime.tryParse(json['bookingDate'] ?? '') ?? DateTime.now(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

/// Paginated orders
class PaginatedOrders {
  final List<OrderModel> orders;
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
              ?.map((o) => OrderModel.fromJson(o))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}

/// Vendor profile model
class VendorProfileModel {
  final String id;
  final String businessName;
  final String businessDescription;
  final String businessAddress;
  final String businessPhoneNumber;
  final String businessEmail;
  final bool isVerified;
  final bool isSuspended;
  final double rating;
  final int totalOrders;
  final int completedOrders;

  VendorProfileModel({
    required this.id,
    required this.businessName,
    required this.businessDescription,
    required this.businessAddress,
    required this.businessPhoneNumber,
    required this.businessEmail,
    required this.isVerified,
    required this.isSuspended,
    required this.rating,
    required this.totalOrders,
    required this.completedOrders,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    return VendorProfileModel(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? '',
      businessDescription: json['businessDescription'] ?? '',
      businessAddress: json['businessAddress'] ?? '',
      businessPhoneNumber: json['businessPhoneNumber'] ?? '',
      businessEmail: json['businessEmail'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isSuspended: json['isSuspended'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
    );
  }
}

/// Earnings model
class EarningsModel {
  final double totalEarnings;
  final double availableBalance;
  final double pendingAmount;
  final int completedOrders;

  EarningsModel({
    required this.totalEarnings,
    required this.availableBalance,
    required this.pendingAmount,
    required this.completedOrders,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      pendingAmount: (json['pendingAmount'] ?? 0).toDouble(),
      completedOrders: json['completedOrders'] ?? 0,
    );
  }
}

/// Paginated earnings
class PaginatedEarnings {
  final List<EarningRecordModel> records;
  final int total;
  final int page;
  final int pageSize;

  PaginatedEarnings({
    required this.records,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedEarnings.fromJson(Map<String, dynamic> json) {
    return PaginatedEarnings(
      records: (json['records'] as List?)
              ?.map((r) => EarningRecordModel.fromJson(r))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}

/// Earning record model
class EarningRecordModel {
  final String orderId;
  final double amount;
  final DateTime date;

  EarningRecordModel({
    required this.orderId,
    required this.amount,
    required this.date,
  });

  factory EarningRecordModel.fromJson(Map<String, dynamic> json) {
    return EarningRecordModel(
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Withdrawal model
class WithdrawalModel {
  final String id;
  final double amount;
  final String status;
  final DateTime requestDate;

  WithdrawalModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.requestDate,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      requestDate:
          DateTime.tryParse(json['requestDate'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Paginated withdrawals
class PaginatedWithdrawals {
  final List<WithdrawalModel> withdrawals;
  final int total;
  final int page;
  final int pageSize;

  PaginatedWithdrawals({
    required this.withdrawals,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedWithdrawals.fromJson(Map<String, dynamic> json) {
    return PaginatedWithdrawals(
      withdrawals: (json['withdrawals'] as List?)
              ?.map((w) => WithdrawalModel.fromJson(w))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}

/// Dashboard analytics model
class DashboardAnalyticsModel {
  final int pendingOrders;
  final int todayOrders;
  final double todayEarnings;
  final double averageRating;

  DashboardAnalyticsModel({
    required this.pendingOrders,
    required this.todayOrders,
    required this.todayEarnings,
    required this.averageRating,
  });

  factory DashboardAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return DashboardAnalyticsModel(
      pendingOrders: json['pendingOrders'] ?? 0,
      todayOrders: json['todayOrders'] ?? 0,
      todayEarnings: (json['todayEarnings'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }
}

/// Analytics report model
class AnalyticsReportModel {
  final int totalOrders;
  final int completedOrders;
  final double totalEarnings;
  final double averageRating;

  AnalyticsReportModel({
    required this.totalOrders,
    required this.completedOrders,
    required this.totalEarnings,
    required this.averageRating,
  });

  factory AnalyticsReportModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsReportModel(
      totalOrders: json['totalOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }
}

/// Review model
class ReviewModel {
  final String id;
  final int rating;
  final String reviewText;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      rating: json['rating'] ?? 0,
      reviewText: json['reviewText'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Paginated reviews
class PaginatedReviews {
  final List<ReviewModel> reviews;
  final int total;
  final int page;
  final int pageSize;

  PaginatedReviews({
    required this.reviews,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedReviews.fromJson(Map<String, dynamic> json) {
    return PaginatedReviews(
      reviews: (json['reviews'] as List?)
              ?.map((r) => ReviewModel.fromJson(r))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}
