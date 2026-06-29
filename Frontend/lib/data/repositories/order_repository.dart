// Order repository
// Order Repository
// Purpose: Handles all order-related operations and tracking
// Author: CarWash Pro Development Team
// Date: March 3, 2026

import 'package:car_wash_app/data/datasources/remote/api_service.dart';
import 'package:car_wash_app/core/constants/api_endpoints.dart';

/// OrderRepository handles all order-related operations
/// 
/// Responsibilities:
/// - Order creation and management
/// - Order tracking and status updates
/// - Order history and analytics
/// - Cancellation and refunds
/// - Order disputes
class OrderRepository {
  final ApiService apiService;

  OrderRepository({required this.apiService});

  // ==================== ORDER CREATION & MANAGEMENT ====================

  /// Create a new order
  /// 
  /// Parameters:
  ///   - orderData: Complete order details (customer, service, date, address, etc.)
  /// 
  /// Returns: OrderModel with created order details
  /// 
  /// Throws: Exception if creation fails
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      if (orderData.isEmpty) {
        throw Exception('Order data is required');
      }

      final response = await apiService.post(
        ApiEndpoints.createOrder ?? '',
        data: orderData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return OrderModel.fromJson(response.data['order']);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Create order error: ${e.toString()}');
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
      final response = await apiService.get('${ApiEndpoints.getOrders}/$orderId');

      if (response.statusCode == 200) {
        return OrderDetailsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get order details error: ${e.toString()}');
    }
  }

  /// Get all orders with pagination
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
  Future<PaginatedOrders> getAllOrders({
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
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom.toIso8601String();
      if (dateTo != null) queryParams['dateTo'] = dateTo.toIso8601String();

      final response = await apiService.get(
        ApiEndpoints.getOrders,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedOrders.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get orders error: ${e.toString()}');
    }
  }

  /// Update order status
  /// 
  /// Parameters:
  ///   - orderId: ID of order to update
  ///   - newStatus: New order status
  ///   - notes: Optional status update notes
  /// 
  /// Returns: Updated OrderModel
  /// 
  /// Throws: Exception if update fails
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? notes,
  }) async {
    try {
      final validStatuses = [
        'pending',
        'confirmed',
        'in_progress',
        'completed',
        'cancelled'
      ];
      if (!validStatuses.contains(newStatus)) {
        throw Exception('Invalid order status');
      }

      final response = await apiService.patch(
        '${ApiEndpoints.getOrders}/$orderId/status',
        data: {
          'status': newStatus,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['order']);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Update order status error: ${e.toString()}');
    }
  }

  // ==================== ORDER ACTIONS ====================

  /// Accept order (vendor action)
  /// 
  /// Parameters:
  ///   - orderId: ID of order to accept
  ///   - estimatedDuration: Estimated service duration (optional)
  /// 
  /// Returns: Updated OrderModel
  /// 
  /// Throws: Exception if operation fails
  Future<OrderModel> acceptOrder({
    required String orderId,
    int? estimatedDuration,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.getOrders}/$orderId/accept',
        data: {
          if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
        },
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['order']);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Accept order error: ${e.toString()}');
    }
  }

  /// Reject order (vendor action)
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
        '${ApiEndpoints.getOrders}/$orderId/reject',
        data: {'reason': reason},
      );

      if (response.statusCode != 200) {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Reject order error: ${e.toString()}');
    }
  }

  /// Start service (vendor action)
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
        '${ApiEndpoints.getOrders}/$orderId/start',
        data: {},
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['order']);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Start service error: ${e.toString()}');
    }
  }

  /// Complete service (vendor action)
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
        '${ApiEndpoints.getOrders}/$orderId/complete',
        data: {
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['order']);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Complete service error: ${e.toString()}');
    }
  }

  /// Cancel order
  /// 
  /// Parameters:
  ///   - orderId: ID of order to cancel
  ///   - reason: Reason for cancellation
  ///   - refundAmount: Optional refund amount
  /// 
  /// Returns: Updated OrderModel
  /// 
  /// Throws: Exception if operation fails
  Future<OrderModel> cancelOrder({
    required String orderId,
    required String reason,
    double? refundAmount,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.getOrders}/$orderId/cancel',
        data: {
          'reason': reason,
          if (refundAmount != null) 'refundAmount': refundAmount,
        },
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['order']);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Cancel order error: ${e.toString()}');
    }
  }

  // ==================== ORDER TRACKING ====================

  /// Get order tracking information
  /// 
  /// Parameters:
  ///   - orderId: ID of order to track
  /// 
  /// Returns: TrackingModel with live tracking information
  /// 
  /// Throws: Exception if fetch fails
  Future<TrackingModel> getOrderTracking(String orderId) async {
    try {
      final response = await apiService.get(
        '${ApiEndpoints.getOrders}/$orderId/tracking',
      );

      if (response.statusCode == 200) {
        return TrackingModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get tracking error: ${e.toString()}');
    }
  }

  /// Get order timeline/history
  /// 
  /// Parameters:
  ///   - orderId: ID of order
  /// 
  /// Returns: List of timeline events
  /// 
  /// Throws: Exception if fetch fails
  Future<List<TimelineEventModel>> getOrderTimeline(String orderId) async {
    try {
      final response = await apiService.get(
        '${ApiEndpoints.getOrders}/$orderId/timeline',
      );

      if (response.statusCode == 200) {
        final events = response.data['events'] as List?;
        return events
                ?.map((event) => TimelineEventModel.fromJson(event))
                .toList() ??
            [];
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get timeline error: ${e.toString()}');
    }
  }

  // ==================== REFUNDS & DISPUTES ====================

  /// Request refund for order
  /// 
  /// Parameters:
  ///   - orderId: ID of order
  ///   - reason: Reason for refund request
  ///   - refundAmount: Requested refund amount
  /// 
  /// Returns: RefundModel with refund details
  /// 
  /// Throws: Exception if request fails
  Future<RefundModel> requestRefund({
    required String orderId,
    required String reason,
    required double refundAmount,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.getOrders}/$orderId/refund',
        data: {
          'reason': reason,
          'refundAmount': refundAmount,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RefundModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Request refund error: ${e.toString()}');
    }
  }

  /// Get refund status
  /// 
  /// Parameters:
  ///   - refundId: ID of refund request
  /// 
  /// Returns: RefundModel with refund status
  /// 
  /// Throws: Exception if fetch fails
  Future<RefundModel> getRefundStatus(String refundId) async {
    try {
      final response = await apiService.get(
        '${ApiEndpoints.getRefund}/$refundId',
      );

      if (response.statusCode == 200) {
        return RefundModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get refund status error: ${e.toString()}');
    }
  }

  /// Report order dispute
  /// 
  /// Parameters:
  ///   - orderId: ID of order
  ///   - issue: Description of issue
  ///   - evidence: Optional evidence (image URLs, etc.)
  /// 
  /// Returns: DisputeModel with dispute details
  /// 
  /// Throws: Exception if creation fails
  Future<DisputeModel> reportDispute({
    required String orderId,
    required String issue,
    List<String>? evidence,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.getOrders}/$orderId/dispute',
        data: {
          'issue': issue,
          if (evidence != null) 'evidence': evidence,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DisputeModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Report dispute error: ${e.toString()}');
    }
  }

  // ==================== ANALYTICS ====================

  /// Get order analytics
  /// 
  /// Parameters:
  ///   - startDate: Start date for analytics
  ///   - endDate: End date for analytics
  ///   - groupBy: Group by (day, week, month)
  /// 
  /// Returns: AnalyticsModel with order statistics
  /// 
  /// Throws: Exception if fetch fails
  Future<AnalyticsModel> getOrderAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? groupBy,
  }) async {
    try {
      final response = await apiService.get(
        ApiEndpoints.orderAnalytics ?? '',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          if (groupBy != null) 'groupBy': groupBy,
        },
      );

      if (response.statusCode == 200) {
        return AnalyticsModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode ?? 500);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get analytics error: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Handle API error responses
  Exception _handleApiError(int statusCode) {
    switch (statusCode) {
      case 400:
        return Exception('Invalid request data');
      case 401:
        return Exception('Unauthorized - Please login');
      case 404:
        return Exception('Order not found');
      case 409:
        return Exception('Operation not allowed for this order status');
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

/// Order model
class OrderModel {
  final String id;
  final String customerId;
  final String vendorId;
  final String serviceId;
  final String status;
  final DateTime bookingDate;
  final double totalAmount;
  final double platformFee;
  final double vendorAmount;
  final String paymentStatus;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.serviceId,
    required this.status,
    required this.bookingDate,
    required this.totalAmount,
    required this.platformFee,
    required this.vendorAmount,
    required this.paymentStatus,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      status: json['status'] ?? 'pending',
      bookingDate: DateTime.tryParse(json['bookingDate'] ?? '') ?? DateTime.now(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? 0).toDouble(),
      vendorAmount: (json['vendorAmount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
    );
  }
}

/// Order details model
class OrderDetailsModel {
  final OrderModel order;
  final Map<String, dynamic> customerInfo;
  final Map<String, dynamic> vendorInfo;
  final Map<String, dynamic> serviceInfo;

  OrderDetailsModel({
    required this.order,
    required this.customerInfo,
    required this.vendorInfo,
    required this.serviceInfo,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      order: OrderModel.fromJson(json['order']),
      customerInfo: json['customerInfo'] ?? {},
      vendorInfo: json['vendorInfo'] ?? {},
      serviceInfo: json['serviceInfo'] ?? {},
    );
  }
}

/// Paginated orders model
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

/// Tracking model
class TrackingModel {
  final String orderId;
  final String status;
  final Map<String, dynamic> location;
  final DateTime lastUpdate;

  TrackingModel({
    required this.orderId,
    required this.status,
    required this.location,
    required this.lastUpdate,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      location: json['location'] ?? {},
      lastUpdate: DateTime.tryParse(json['lastUpdate'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Timeline event model
class TimelineEventModel {
  final String event;
  final String status;
  final DateTime timestamp;
  final String? description;

  TimelineEventModel({
    required this.event,
    required this.status,
    required this.timestamp,
    this.description,
  });

  factory TimelineEventModel.fromJson(Map<String, dynamic> json) {
    return TimelineEventModel(
      event: json['event'] ?? '',
      status: json['status'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      description: json['description'],
    );
  }
}

/// Refund model
class RefundModel {
  final String id;
  final String orderId;
  final double amount;
  final String status;
  final String reason;
  final DateTime createdAt;

  RefundModel({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.reason,
    required this.createdAt,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      reason: json['reason'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Dispute model
class DisputeModel {
  final String id;
  final String orderId;
  final String issue;
  final String status;
  final DateTime createdAt;

  DisputeModel({
    required this.id,
    required this.orderId,
    required this.issue,
    required this.status,
    required this.createdAt,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      issue: json['issue'] ?? '',
      status: json['status'] ?? 'open',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Analytics model
class AnalyticsModel {
  final int totalOrders;
  final double totalRevenue;
  final int completedOrders;
  final int cancelledOrders;
  final double averageOrderValue;

  AnalyticsModel({
    required this.totalOrders,
    required this.totalRevenue,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.averageOrderValue,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      completedOrders: json['completedOrders'] ?? 0,
      cancelledOrders: json['cancelledOrders'] ?? 0,
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
    );
  }
}
