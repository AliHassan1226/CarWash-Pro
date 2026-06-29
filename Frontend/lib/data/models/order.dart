// order.dart - Complete Order Model

import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable(
  explicitToJson: true,
  anyMap: true,
  checked: true,
)
class Order {
  final String id;
  
  @JsonKey(name: 'customer_id')
  final String customerId;
  
  @JsonKey(name: 'vendor_id')
  final String vendorId;
  
  @JsonKey(name: 'service_id')
  final String serviceId;

  @JsonKey(name: 'service_name')
  final String? serviceName;

  @JsonKey(name: 'vendor_name')
  final String? vendorName;
  
  @JsonKey(name: 'selected_services')
  final List<String>? selectedServices;

  @JsonKey(name: 'customer_name')
  final String customerName;

  @JsonKey(name: 'customer_phone')
  final String customerPhone;
  
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  
  @JsonKey(name: 'discount_amount')
  final double? discountAmount;
  
  @JsonKey(name: 'tax_amount')
  final double? taxAmount;
  
  final String status; // 'pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'refunded'
  
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;
  
  @JsonKey(name: 'scheduled_date')
  final DateTime scheduledDate;
  
  @JsonKey(name: 'completed_date')
  final DateTime? completedDate;
  
  final String? notes;
  
  @JsonKey(name: 'car_details')
  final String? carDetails;
  
  @JsonKey(name: 'car_color')
  final String? carColor;
  
  @JsonKey(name: 'car_plate_number')
  final String? carPlateNumber;
  
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final String? review;
  
  @JsonKey(name: 'review_photos_count')
  final int? reviewPhotosCount;
  
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  
  @JsonKey(name: 'payment_status')
  final String? paymentStatus;
  
  @JsonKey(name: 'transaction_id')
  final String? transactionId;
  
  @JsonKey(name: 'is_reschedule_allowed')
  final bool isRescheduleAllowed;
  
  @JsonKey(name: 'rescheduled_from')
  final DateTime? rescheduledFrom;
  
  @JsonKey(name: 'reschedule_count')
  final int rescheduleCount;
  
  @JsonKey(name: 'customer_notes')
  final String? customerNotes;
  
  @JsonKey(name: 'vendor_notes')
  final String? vendorNotes;
  
  final Map<String, dynamic>? metadata;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.serviceId,
    this.serviceName,
    this.vendorName,
    this.selectedServices,
    this.customerName = 'Customer',
    this.customerPhone = '',
    required this.totalAmount,
    this.discountAmount,
    this.taxAmount,
    required this.status,
    this.cancellationReason,
    required this.scheduledDate,
    this.completedDate,
    this.notes,
    this.carDetails,
    this.carColor,
    this.carPlateNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.review,
    this.reviewPhotosCount,
    this.paymentMethod,
    this.paymentStatus = 'pending',
    this.transactionId,
    this.isRescheduleAllowed = true,
    this.rescheduledFrom,
    this.rescheduleCount = 0,
    this.customerNotes,
    this.vendorNotes,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  // Copy with method for immutability
  Order copyWith({
    String? id,
    String? customerId,
    String? vendorId,
    String? serviceId,
    String? serviceName,
    String? vendorName,
    List<String>? selectedServices,
    String? customerName,
    String? customerPhone,
    double? totalAmount,
    double? discountAmount,
    double? taxAmount,
    String? status,
    String? cancellationReason,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? notes,
    String? carDetails,
    String? carColor,
    String? carPlateNumber,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    String? review,
    int? reviewPhotosCount,
    String? paymentMethod,
    String? paymentStatus,
    String? transactionId,
    bool? isRescheduleAllowed,
    DateTime? rescheduledFrom,
    int? rescheduleCount,
    String? customerNotes,
    String? vendorNotes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vendorId: vendorId ?? this.vendorId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      vendorName: vendorName ?? this.vendorName,
      selectedServices: selectedServices ?? this.selectedServices,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      carDetails: carDetails ?? this.carDetails,
      carColor: carColor ?? this.carColor,
      carPlateNumber: carPlateNumber ?? this.carPlateNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      reviewPhotosCount: reviewPhotosCount ?? this.reviewPhotosCount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      transactionId: transactionId ?? this.transactionId,
      isRescheduleAllowed: isRescheduleAllowed ?? this.isRescheduleAllowed,
      rescheduledFrom: rescheduledFrom ?? this.rescheduledFrom,
      rescheduleCount: rescheduleCount ?? this.rescheduleCount,
      customerNotes: customerNotes ?? this.customerNotes,
      vendorNotes: vendorNotes ?? this.vendorNotes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Status checks
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';

  // Payment status checks
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentPaid => paymentStatus == 'paid';
  bool get isPaymentFailed => paymentStatus == 'failed';
  bool get isPaymentRefunded => paymentStatus == 'refunded';
  bool get isPaymentPartiallyRefunded => paymentStatus == 'partially_refunded';

  // Review status
  bool get isRated => rating != null && rating! > 0;
  bool get hasReview => review != null && review!.isNotEmpty;
  bool get hasReviewPhotos => reviewPhotosCount != null && reviewPhotosCount! > 0;

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  String get paymentStatusDisplay {
    switch (paymentStatus?.toLowerCase() ?? '') {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      case 'partially_refunded':
        return 'Partially Refunded';
      default:
        return paymentStatus ?? 'Unknown';
    }
  }

  // Action permissions
  bool get canBeCancelled => isPending || isConfirmed;
  bool get canBeRescheduled => (isPending || isConfirmed) && isRescheduleAllowed;
  bool get canBeRated => isCompleted && !isRated;
  bool get canBeModified => isPending || isConfirmed;
  bool get canRequestRefund => isCompleted && !isRefunded;

  // Time calculations
  Duration? get timeUntilScheduled {
    return scheduledDate.difference(DateTime.now());
  }

  Duration? get timeSinceCompleted {
    if (completedDate == null) return null;
    return DateTime.now().difference(completedDate!);
  }

  bool get isUpcoming => 
    (isPending || isConfirmed) && 
    scheduledDate.isAfter(DateTime.now());

  bool get isOverdue => 
    (isPending || isConfirmed) && 
    scheduledDate.isBefore(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
           scheduledDate.month == now.month &&
           scheduledDate.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return scheduledDate.year == tomorrow.year &&
           scheduledDate.month == tomorrow.month &&
           scheduledDate.day == tomorrow.day;
  }

  // Financial calculations
  double get subtotal => totalAmount;
  
  double get discount => discountAmount ?? 0;
  
  double get tax => taxAmount ?? 0;
  
  double get finalAmount {
    return subtotal - discount + tax;
  }

  double get savingsAmount => discount;

  String get formattedAmount => '\$${finalAmount.toStringAsFixed(2)}';

  // Rescheduling info
  bool get isRescheduled => rescheduledFrom != null;
  
  bool get hasReachedRescheduleLimit => rescheduleCount >= 3; // Max 3 reschedules

  // Car info
  bool get hasCarDetails => carDetails != null && carDetails!.isNotEmpty;
  
  bool get hasCarColor => carColor != null && carColor!.isNotEmpty;
  
  bool get hasCarPlate => carPlateNumber != null && carPlateNumber!.isNotEmpty;

  bool get hasCompleteCarInfo => hasCarDetails && hasCarPlate;

  // Location info
  bool get hasAddress => address != null && address!.isNotEmpty;
  
  bool get hasLocation => latitude != null && longitude != null;

  bool get hasCompleteLocation => hasAddress && hasLocation;

  // Notes
  bool get hasCustomerNotes => customerNotes != null && customerNotes!.isNotEmpty;
  
  bool get hasVendorNotes => vendorNotes != null && vendorNotes!.isNotEmpty;

  // Order metadata
  String get shortId => id.substring(0, 8).toUpperCase();
  
  String get orderNumber => 'ORD-$shortId';

  // Timeline methods
  Map<String, DateTime> get timeline {
    final timeline = <String, DateTime>{
      'created': createdAt,
      'scheduled': scheduledDate,
    };
    
    if (completedDate != null) {
      timeline['completed'] = completedDate!;
    }
    
    if (rescheduledFrom != null) {
      timeline['rescheduled_from'] = rescheduledFrom!;
    }
    
    return timeline;
  }

  // Create update map for API
  Map<String, dynamic> toUpdateMap(Order original) {
    final updateMap = <String, dynamic>{};
    
    if (status != original.status) updateMap['status'] = status;
    if (scheduledDate != original.scheduledDate) {
      updateMap['scheduled_date'] = scheduledDate.toIso8601String();
    }
    if (notes != original.notes) updateMap['notes'] = notes;
    if (carDetails != original.carDetails) updateMap['car_details'] = carDetails;
    if (carColor != original.carColor) updateMap['car_color'] = carColor;
    if (carPlateNumber != original.carPlateNumber) {
      updateMap['car_plate_number'] = carPlateNumber;
    }
    if (address != original.address) updateMap['address'] = address;
    if (latitude != original.latitude) updateMap['latitude'] = latitude;
    if (longitude != original.longitude) updateMap['longitude'] = longitude;
    if (customerNotes != original.customerNotes) {
      updateMap['customer_notes'] = customerNotes;
    }
    if (metadata != original.metadata) updateMap['metadata'] = metadata;
    
    return updateMap;
  }

  // Create review map for API
  Map<String, dynamic> toReviewMap() {
    if (!isCompleted) {
      throw Exception('Cannot review an incomplete order');
    }
    
    return {
      'rating': rating,
      'review': review,
      'review_photos_count': reviewPhotosCount,
    };
  }

  @override
  String toString() {
    return 'Order(id: $id, status: $status, amount: $finalAmount, scheduled: ${scheduledDate.toIso8601String()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Order &&
        other.id == id &&
        other.customerId == customerId &&
        other.serviceId == serviceId &&
        other.selectedServices == selectedServices &&
        other.scheduledDate == scheduledDate;
  }

  @override
  int get hashCode => Object.hash(id, customerId, serviceId, selectedServices, scheduledDate);
}

// Extension for order list operations
extension OrderListExtension on List<Order> {
  // Filter by status
  List<Order> get pending => where((o) => o.isPending).toList();
  List<Order> get confirmed => where((o) => o.isConfirmed).toList();
  List<Order> get inProgress => where((o) => o.isInProgress).toList();
  List<Order> get completed => where((o) => o.isCompleted).toList();
  List<Order> get cancelled => where((o) => o.isCancelled).toList();
  List<Order> get refunded => where((o) => o.isRefunded).toList();
  
  // Filter by payment status
  List<Order> get paymentPending => where((o) => o.isPaymentPending).toList();
  List<Order> get paymentPaid => where((o) => o.isPaymentPaid).toList();
  List<Order> get paymentFailed => where((o) => o.isPaymentFailed).toList();
  
  // Filter by date
  List<Order> get upcoming => where((o) => o.isUpcoming).toList();
  List<Order> get overdue => where((o) => o.isOverdue).toList();
  List<Order> get today => where((o) => o.isToday).toList();
  List<Order> get tomorrow => where((o) => o.isTomorrow).toList();
  
  // Filter by customer/vendor
  List<Order> forCustomer(String customerId) {
    return where((o) => o.customerId == customerId).toList();
  }
  
  List<Order> forVendor(String vendorId) {
    return where((o) => o.vendorId == vendorId).toList();
  }
  
  List<Order> forService(String serviceId) {
    return where((o) => o.serviceId == serviceId).toList();
  }
  
  // Filter by rating
  List<Order> get rated => where((o) => o.isRated).toList();
  List<Order> get unrated => where((o) => !o.isRated && o.isCompleted).toList();
  
  // Search
  List<Order> search(String query) {
    if (query.isEmpty) return this;
    
    final lowerQuery = query.toLowerCase();
    return where((o) =>
      o.id.toLowerCase().contains(lowerQuery) ||
      o.orderNumber.toLowerCase().contains(lowerQuery) ||
      (o.carPlateNumber?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
  
  // Sorting
  List<Order> sortByDate([bool ascending = false]) {
    final sorted = List<Order>.from(this);
    sorted.sort((a, b) => ascending 
        ? a.scheduledDate.compareTo(b.scheduledDate)
        : b.scheduledDate.compareTo(a.scheduledDate));
    return sorted;
  }
  
  List<Order> sortByAmount([bool ascending = false]) {
    final sorted = List<Order>.from(this);
    sorted.sort((a, b) => ascending 
        ? a.finalAmount.compareTo(b.finalAmount)
        : b.finalAmount.compareTo(a.finalAmount));
    return sorted;
  }
  
  // Statistics
  double get totalRevenue => fold(0.0, (sum, o) => sum + o.finalAmount);
  
  double get averageOrderValue => isEmpty ? 0 : totalRevenue / length;
  
  int get completedCount => completed.length;
  
  int get cancelledCount => cancelled.length;
  
  double get completionRate => 
      isEmpty ? 0 : (completed.length / length) * 100;
  
  Map<String, int> get statusDistribution {
    final map = <String, int>{};
    for (final order in this) {
      map[order.status] = (map[order.status] ?? 0) + 1;
    }
    return map;
  }
  
  Map<String, double> get dailyRevenue {
    final map = <String, double>{};
    for (final order in completed) {
      final date = order.completedDate ?? order.updatedAt;
      final key = '${date.year}-${date.month}-${date.day}';
      map[key] = (map[key] ?? 0) + order.finalAmount;
    }
    return map;
  }
}

// Enum for order status
enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  refunded;
  
  @override
  String toString() {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.refunded:
        return 'refunded';
    }
  }
  
  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        throw ArgumentError('Invalid status: $status');
    }
  }
}

// Constants for order configuration
class OrderConstants {
  static const List<String> validStatuses = [
    'pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'refunded'
  ];
  
  static const List<String> validPaymentStatuses = [
    'pending', 'paid', 'failed', 'refunded', 'partially_refunded'
  ];
  
  static const int maxRescheduleCount = 3;
  static const int minRating = 1;
  static const int maxRating = 5;
  
  static const Duration cancellationWindow = Duration(hours: 2);
  static const Duration rescheduleWindow = Duration(hours: 1);
  
  static const int maxReviewLength = 500;
  static const int maxNotesLength = 500;
}