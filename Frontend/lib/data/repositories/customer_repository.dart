// Customer repository

// Customer Repository
// Purpose: Handles all customer-specific operations
// Author: CarWash Pro Development Team
// Date: March 3, 2026

import 'package:car_wash_app/data/datasources/remote/api_service.dart';
import 'package:car_wash_app/core/constants/api_endpoints.dart';

/// CustomerRepository handles all customer-related operations
///
/// Responsibilities:
/// - Service browsing and search
/// - Booking management
/// - Order history
/// - Wishlist management
/// - Customer profile
/// - Payment management
/// - Rating and reviews
class CustomerRepository {
  final ApiService apiService;

  CustomerRepository({required this.apiService});

  // ==================== SERVICE BROWSING ====================

  /// Get all available services with pagination
  ///
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///   - category: Filter by category (optional)
  ///   - searchQuery: Search by name (optional)
  ///   - sortBy: Sort field (optional)
  ///
  /// Returns: Paginated list of services
  ///
  /// Throws: Exception if fetch fails
  Future<PaginatedServices> getServices({
    required int page,
    required int pageSize,
    String? category,
    String? searchQuery,
    String? sortBy,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      if (category != null) queryParams['category'] = category;
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await apiService.get(
        ApiEndpoints.customerServices ?? '',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedServices.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
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
        '${ApiEndpoints.customerServices}/$serviceId',
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

  /// Search services
  ///
  /// Parameters:
  ///   - query: Search query
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///
  /// Returns: Paginated search results
  ///
  /// Throws: Exception if search fails
  Future<PaginatedServices> searchServices({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiService.get(
        ApiEndpoints.customerServicesSearch ?? '',
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      if (response.statusCode == 200) {
        return PaginatedServices.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Search services error: ${e.toString()}');
    }
  }

  /// Get vendor details
  ///
  /// Parameters:
  ///   - vendorId: ID of vendor to fetch
  ///
  /// Returns: VendorProfileModel with vendor information
  ///
  /// Throws: Exception if fetch fails
  Future<VendorProfileModel> getVendorProfile(String vendorId) async {
    try {
      final response = await apiService.get(
        '${ApiEndpoints.customerVendors}/$vendorId',
      );

      if (response.statusCode == 200) {
        return VendorProfileModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get vendor profile error: ${e.toString()}');
    }
  }

  // ==================== BOOKING OPERATIONS ====================

  /// Create a new booking
  ///
  /// Parameters:
  ///   - bookingData: Booking details including service, date, address, etc.
  ///
  /// Returns: BookingModel with booking details
  ///
  /// Throws: Exception if booking fails
  Future<BookingModel> createBooking(Map<String, dynamic> bookingData) async {
    try {
      if (bookingData.isEmpty) {
        throw Exception('Booking data is required');
      }

      final response = await apiService.post(
        ApiEndpoints.customerBookings,
        data: bookingData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Create booking error: ${e.toString()}');
    }
  }

  /// Get booking details
  ///
  /// Parameters:
  ///   - bookingId: ID of booking to fetch
  ///
  /// Returns: BookingModel with booking information
  ///
  /// Throws: Exception if fetch fails
  Future<BookingModel> getBookingDetails(String bookingId) async {
    try {
      final response = await apiService.get(
        '${ApiEndpoints.customerBookings}/$bookingId',
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get booking details error: ${e.toString()}');
    }
  }

  /// Cancel booking
  ///
  /// Parameters:
  ///   - bookingId: ID of booking to cancel
  ///   - reason: Reason for cancellation
  ///
  /// Throws: Exception if cancellation fails
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.customerBookings}/$bookingId/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode != 200) {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Cancel booking error: ${e.toString()}');
    }
  }

  /// Reschedule booking
  ///
  /// Parameters:
  ///   - bookingId: ID of booking to reschedule
  ///   - newDate: New booking date/time
  ///
  /// Returns: Updated BookingModel
  ///
  /// Throws: Exception if rescheduling fails
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.customerBookings}/$bookingId/reschedule',
        data: {'newDate': newDate.toIso8601String()},
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Reschedule booking error: ${e.toString()}');
    }
  }

  // ==================== ORDER HISTORY ====================

  /// Get customer's booking history with pagination
  ///
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///   - status: Filter by status (optional)
  ///
  /// Returns: Paginated list of bookings
  ///
  /// Throws: Exception if fetch fails
  Future<PaginatedBookings> getBookingHistory({
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
        ApiEndpoints.customerBookingHistory ?? '',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedBookings.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get booking history error: ${e.toString()}');
    }
  }

  // ==================== WISHLIST ====================

  /// Get customer's wishlist
  ///
  /// Returns: List of services in wishlist
  ///
  /// Throws: Exception if fetch fails
  Future<List<ServiceDetailsModel>> getWishlist() async {
    try {
      final response = await apiService.get(ApiEndpoints.customerWishlist);

      if (response.statusCode == 200) {
        final items = response.data['items'] as List?;
        return items
                ?.map((item) => ServiceDetailsModel.fromJson(item))
                .toList() ??
            [];
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get wishlist error: ${e.toString()}');
    }
  }

  /// Add service to wishlist
  ///
  /// Parameters:
  ///   - serviceId: ID of service to add
  ///
  /// Throws: Exception if operation fails
  Future<void> addToWishlist(String serviceId) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.customerWishlist,
        data: {'serviceId': serviceId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Add to wishlist error: ${e.toString()}');
    }
  }

  /// Remove service from wishlist
  ///
  /// Parameters:
  ///   - serviceId: ID of service to remove
  ///
  /// Throws: Exception if operation fails
  Future<void> removeFromWishlist(String serviceId) async {
    try {
      final response = await apiService.delete(
        '${ApiEndpoints.customerWishlist}/$serviceId',
        data: {},
      );

      if (response.statusCode != 200) {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Remove from wishlist error: ${e.toString()}');
    }
  }

  // ==================== RATINGS & REVIEWS ====================

  /// Submit rating and review for completed booking
  ///
  /// Parameters:
  ///   - bookingId: ID of booking to rate
  ///   - rating: Rating value (1-5)
  ///   - review: Review text
  ///
  /// Returns: ReviewModel with submitted review
  ///
  /// Throws: Exception if submission fails
  Future<ReviewModel> submitReview({
    required String bookingId,
    required int rating,
    required String review,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }
      if (review.isEmpty || review.length < 10) {
        throw Exception('Review must be at least 10 characters');
      }

      final response = await apiService.post(
        '${ApiEndpoints.customerBookings}/$bookingId/review',
        data: {
          'rating': rating,
          'review': review,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReviewModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Submit review error: ${e.toString()}');
    }
  }

  /// Get vendor reviews
  ///
  /// Parameters:
  ///   - vendorId: ID of vendor
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///
  /// Returns: Paginated list of reviews
  ///
  /// Throws: Exception if fetch fails
  Future<PaginatedReviews> getVendorReviews({
    required String vendorId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiService.get(
        '${ApiEndpoints.customerVendors}/$vendorId/reviews',
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
      throw Exception('Get vendor reviews error: ${e.toString()}');
    }
  }

  // ==================== PAYMENT ====================

  /// Process payment for booking
  ///
  /// Parameters:
  ///   - bookingId: ID of booking
  ///   - paymentData: Payment details (method, card info, etc.)
  ///
  /// Returns: PaymentModel with payment details
  ///
  /// Throws: Exception if payment fails
  Future<PaymentModel> processPayment({
    required String bookingId,
    required Map<String, dynamic> paymentData,
  }) async {
    try {
      final response = await apiService.post(
        '${ApiEndpoints.customerBookings}/$bookingId/payment',
        data: paymentData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Process payment error: ${e.toString()}');
    }
  }

  /// Get payment history
  ///
  /// Parameters:
  ///   - page: Page number
  ///   - pageSize: Items per page
  ///
  /// Returns: Paginated list of payments
  ///
  /// Throws: Exception if fetch fails
  Future<PaginatedPayments> getPaymentHistory({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await apiService.get(
        ApiEndpoints.customerPaymentHistory ?? '',
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      if (response.statusCode == 200) {
        return PaginatedPayments.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get payment history error: ${e.toString()}');
    }
  }

  // ==================== ADDRESSES ====================

  /// Get customer's saved addresses
  ///
  /// Returns: List of saved addresses
  ///
  /// Throws: Exception if fetch fails
  Future<List<AddressModel>> getSavedAddresses() async {
    try {
      final response = await apiService.get(ApiEndpoints.customerAddresses);

      if (response.statusCode == 200) {
        final addresses = response.data['addresses'] as List?;
        return addresses?.map((addr) => AddressModel.fromJson(addr)).toList() ??
            [];
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Get addresses error: ${e.toString()}');
    }
  }

  /// Add new address
  ///
  /// Parameters:
  ///   - addressData: Address details
  ///
  /// Returns: AddressModel with saved address
  ///
  /// Throws: Exception if operation fails
  Future<AddressModel> addAddress(Map<String, dynamic> addressData) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.customerAddresses,
        data: addressData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddressModel.fromJson(response.data);
      } else {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Add address error: ${e.toString()}');
    }
  }

  /// Delete saved address
  ///
  /// Parameters:
  ///   - addressId: ID of address to delete
  ///
  /// Throws: Exception if operation fails
  Future<void> deleteAddress(String addressId) async {
    try {
      final response = await apiService.delete(
        '${ApiEndpoints.customerAddresses}/$addressId',
        data: {},
      );

      if (response.statusCode != 200) {
        throw _handleApiError(response.statusCode);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Delete address error: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Handle API error responses
  Exception _handleApiError(int? statusCode) {
    statusCode ??= 0;
    switch (statusCode) {
      case 400:
        return Exception('Invalid request data');
      case 401:
        return Exception('Unauthorized - Please login');
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

/// Paginated services model
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

/// Service details model
class ServiceDetailsModel {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final double duration;
  final String category;
  final double rating;
  final int reviewCount;

  ServiceDetailsModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.category,
    required this.rating,
    required this.reviewCount,
  });

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsModel(
      id: json['id'] ?? '',
      vendorId: json['vendorId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: (json['duration'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}

/// Vendor profile model
class VendorProfileModel {
  final String id;
  final String businessName;
  final String description;
  final String address;
  final String phoneNumber;
  final bool isVerified;
  final double rating;
  final int totalOrders;

  VendorProfileModel({
    required this.id,
    required this.businessName,
    required this.description,
    required this.address,
    required this.phoneNumber,
    required this.isVerified,
    required this.rating,
    required this.totalOrders,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    return VendorProfileModel(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isVerified: json['isVerified'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
    );
  }
}

/// Booking model
class BookingModel {
  final String id;
  final String serviceId;
  final String vendorId;
  final String status;
  final DateTime bookingDate;
  final double totalAmount;
  final bool isReviewed;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.vendorId,
    required this.status,
    required this.bookingDate,
    required this.totalAmount,
    required this.isReviewed,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      status: json['status'] ?? '',
      bookingDate:
          DateTime.tryParse(json['bookingDate'] ?? '') ?? DateTime.now(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      isReviewed: json['isReviewed'] ?? false,
    );
  }
}

/// Paginated bookings model
class PaginatedBookings {
  final List<BookingModel> bookings;
  final int total;
  final int page;
  final int pageSize;

  PaginatedBookings({
    required this.bookings,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedBookings.fromJson(Map<String, dynamic> json) {
    return PaginatedBookings(
      bookings: (json['bookings'] as List?)
              ?.map((b) => BookingModel.fromJson(b))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}

/// Review model
class ReviewModel {
  final String id;
  final String bookingId;
  final int rating;
  final String reviewText;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      rating: json['rating'] ?? 0,
      reviewText: json['reviewText'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Paginated reviews model
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

/// Payment model
class PaymentModel {
  final String id;
  final String bookingId;
  final double amount;
  final String status;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      bookingId: json['bookingId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Paginated payments model
class PaginatedPayments {
  final List<PaymentModel> payments;
  final int total;
  final int page;
  final int pageSize;

  PaginatedPayments({
    required this.payments,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedPayments.fromJson(Map<String, dynamic> json) {
    return PaginatedPayments(
      payments: (json['payments'] as List?)
              ?.map((p) => PaymentModel.fromJson(p))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}

/// Address model
class AddressModel {
  final String id;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
