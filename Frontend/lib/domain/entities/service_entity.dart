// Service entity definition

// Service Entity
// Purpose: Service data model and entity representation
// Author: CarWash Pro Development Team
// Date: March 3, 2026

/// Service entity representing a car wash service
/// 
/// This entity contains all service-related information including
/// pricing, duration, category, ratings, and availability status
class ServiceEntity {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final int estimatedDuration; // in minutes
  final String category; // basic, standard, premium
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final int totalBookings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Constructor
  ServiceEntity({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.estimatedDuration,
    required this.category,
    this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.totalBookings = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // ==================== FACTORY CONSTRUCTORS ====================

  /// Create from JSON
  /// 
  /// Parameters:
  ///   - json: JSON map from API/database
  /// 
  /// Returns: ServiceEntity instance
  factory ServiceEntity.fromJson(Map<String, dynamic> json) {
    return ServiceEntity(
      id: json['id'] as String? ?? '',
      vendorId: json['vendorId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      estimatedDuration: json['estimatedDuration'] as int? ?? 0,
      category: json['category'] as String? ?? 'standard',
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      totalBookings: json['totalBookings'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Create from database map
  /// 
  /// Parameters:
  ///   - map: Database record map
  /// 
  /// Returns: ServiceEntity instance
  factory ServiceEntity.fromDatabase(Map<String, dynamic> map) {
    return ServiceEntity(
      id: map['id'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      estimatedDuration: map['duration'] as int? ?? 0,
      category: map['category'] as String? ?? 'standard',
      imageUrl: map['image'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      totalBookings: map['totalBookings'] as int? ?? 0,
      isActive: (map['isActive'] as int? ?? 1) == 1,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create empty service
  factory ServiceEntity.empty() {
    return ServiceEntity(
      id: '',
      vendorId: '',
      name: '',
      description: '',
      price: 0.0,
      estimatedDuration: 0,
      category: 'standard',
      imageUrl: null,
      rating: 0.0,
      reviewCount: 0,
      totalBookings: 0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
  }

  /// Create dummy/test service
  factory ServiceEntity.dummy() {
    return ServiceEntity(
      id: 'svc-dummy',
      vendorId: 'vendor-dummy',
      name: 'Test Service',
      description: 'This is a test service',
      price: 599.99,
      estimatedDuration: 60,
      category: 'premium',
      imageUrl: 'https://via.placeholder.com/300',
      rating: 4.5,
      reviewCount: 125,
      totalBookings: 500,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ==================== CONVERSION METHODS ====================

  /// Convert to JSON
  /// 
  /// Returns: JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'price': price,
      'estimatedDuration': estimatedDuration,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'totalBookings': totalBookings,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to database map
  /// 
  /// Returns: Database-compatible map
  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'price': price,
      'duration': estimatedDuration,
      'category': category,
      'image': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'totalBookings': totalBookings,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to update map (for partial updates)
  /// 
  /// Returns: Map with only non-null values
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'estimatedDuration': estimatedDuration,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'totalBookings': totalBookings,
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // ==================== UTILITY METHODS ====================

  /// Get category display name
  String getCategoryDisplayName() {
    switch (category.toLowerCase()) {
      case 'basic':
        return 'Basic Wash';
      case 'standard':
        return 'Standard Wash';
      case 'premium':
        return 'Premium Wash';
      default:
        return category;
    }
  }

  /// Get category color code
  String getCategoryColorCode() {
    switch (category.toLowerCase()) {
      case 'basic':
        return '#3498db'; // Blue
      case 'standard':
        return '#2ecc71'; // Green
      case 'premium':
        return '#9b59b6'; // Purple
      default:
        return '#95a5a6'; // Gray
    }
  }

  /// Get service duration in hours and minutes
  String getDurationFormatted() {
    final hours = estimatedDuration ~/ 60;
    final minutes = estimatedDuration % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Check if service has high rating
  bool hasHighRating() {
    return rating >= 4.0;
  }

  /// Check if service is popular
  bool isPopular() {
    return totalBookings >= 100 && rating >= 4.0;
  }

  /// Get rating percentage
  double getRatingPercentage() {
    return (rating / 5.0) * 100;
  }

  /// Get discount price (for demo)
  double getDiscountedPrice({double discountPercent = 10}) {
    return price - (price * discountPercent / 100);
  }

  /// Format price for display
  String getPriceFormatted() {
    return 'Rs ${price.toStringAsFixed(2)}';
  }

  /// Create copy with modifications
  ServiceEntity copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    double? price,
    int? estimatedDuration,
    String? category,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    int? totalBookings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalBookings: totalBookings ?? this.totalBookings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==================== EQUALITY & HASH ====================

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vendorId == other.vendorId &&
          name == other.name &&
          price == other.price &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      vendorId.hashCode ^
      name.hashCode ^
      price.hashCode ^
      category.hashCode;

  // ==================== STRING REPRESENTATION ====================

  @override
  String toString() => '''ServiceEntity(
    id: $id,
    vendorId: $vendorId,
    name: $name,
    price: Rs $price,
    category: $category,
    rating: $rating/5.0,
    estimatedDuration: ${getDurationFormatted()},
    isActive: $isActive,
    createdAt: ${createdAt.toIso8601String()},
  )''';

  /// Get detailed string representation
  String toDetailedString() => '''
Service Details:
- ID: $id
- Vendor: $vendorId
- Name: $name
- Description: $description
- Price: ${getPriceFormatted()}
- Duration: ${getDurationFormatted()}
- Category: ${getCategoryDisplayName()}
- Rating: $rating/5.0 ($reviewCount reviews)
- Bookings: $totalBookings
- Status: ${isActive ? 'Active' : 'Inactive'}
- Created: ${createdAt.toIso8601String()}
- Updated: ${updatedAt?.toIso8601String() ?? 'Never'}
  ''';
}

// ==================== LIST EXTENSIONS ====================

/// Extension methods for Service lists
extension ServiceListExtension on List<ServiceEntity> {
  /// Get total value of all services
  double getTotalValue() {
    return fold<double>(0, (sum, service) => sum + service.price);
  }

  /// Get average rating
  double getAverageRating() {
    if (isEmpty) return 0.0;
    final totalRating = fold<double>(0, (sum, service) => sum + service.rating);
    return totalRating / length;
  }

  /// Get average price
  double getAveragePrice() {
    if (isEmpty) return 0.0;
    return getTotalValue() / length;
  }

  /// Get cheapest service
  ServiceEntity? getCheapest() {
    if (isEmpty) return null;
    return reduce((a, b) => a.price < b.price ? a : b);
  }

  /// Get most expensive service
  ServiceEntity? getExpensive() {
    if (isEmpty) return null;
    return reduce((a, b) => a.price > b.price ? a : b);
  }

  /// Get highest rated service
  ServiceEntity? getHighestRated() {
    if (isEmpty) return null;
    return reduce((a, b) => a.rating > b.rating ? a : b);
  }

  /// Get most popular services
  List<ServiceEntity> getPopular() {
    return where((service) => service.isPopular()).toList();
  }

  /// Get by category
  List<ServiceEntity> getByCategory(String category) {
    return where((service) => 
      service.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  /// Get by vendor
  List<ServiceEntity> getByVendor(String vendorId) {
    return where((service) => service.vendorId == vendorId).toList();
  }

  /// Get active services only
  List<ServiceEntity> getActive() {
    return where((service) => service.isActive).toList();
  }

  /// Get services above rating
  List<ServiceEntity> getAboveRating(double minRating) {
    return where((service) => service.rating >= minRating).toList();
  }

  /// Sort by price ascending
  List<ServiceEntity> sortByPrice() {
    final list = [...this];
    list.sort((a, b) => a.price.compareTo(b.price));
    return list;
  }

  /// Sort by rating descending
  List<ServiceEntity> sortByRating() {
    final list = [...this];
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  /// Sort by bookings descending
  List<ServiceEntity> sortByPopularity() {
    final list = [...this];
    list.sort((a, b) => b.totalBookings.compareTo(a.totalBookings));
    return list;
  }
}

// ==================== VALIDATION HELPER ====================

/// Service validation utility
class ServiceValidator {
  /// Validate service data
  /// 
  /// Parameters:
  ///   - name: Service name
  ///   - price: Service price
  ///   - duration: Service duration
  ///   - category: Service category
  /// 
  /// Returns: List of validation errors (empty if valid)
  static List<String> validate({
    required String name,
    required double price,
    required int duration,
    required String category,
    String? description,
  }) {
    final errors = <String>[];

    // Validate name
    if (name.isEmpty) {
      errors.add('Service name is required');
    } else if (name.length < 3) {
      errors.add('Service name must be at least 3 characters');
    } else if (name.length > 100) {
      errors.add('Service name must not exceed 100 characters');
    }

    // Validate price
    if (price <= 0) {
      errors.add('Price must be greater than 0');
    }

    // Validate duration
    if (duration <= 0) {
      errors.add('Duration must be greater than 0');
    }

    // Validate category
    const validCategories = ['basic', 'standard', 'premium'];
    if (!validCategories.contains(category.toLowerCase())) {
      errors.add('Invalid category. Must be: basic, standard, or premium');
    }

    // Validate description
    if (description != null && description.isNotEmpty) {
      if (description.length < 10) {
        errors.add('Description must be at least 10 characters');
      } else if (description.length > 1000) {
        errors.add('Description must not exceed 1000 characters');
      }
    }

    return errors;
  }

  /// Check if service data is valid
  static bool isValid({
    required String name,
    required double price,
    required int duration,
    required String category,
    String? description,
  }) {
    return validate(
      name: name,
      price: price,
      duration: duration,
      category: category,
      description: description,
    ).isEmpty;
  }
}

// ==================== COMPARISON HELPER ====================

/// Service comparison utility
class ServiceComparison {
  final ServiceEntity service1;
  final ServiceEntity service2;

  ServiceComparison(this.service1, this.service2);

  /// Check if services are similar (same vendor, similar price)
  bool areSimilar({double priceTolerance = 0.1}) {
    final priceDifference = (service1.price - service2.price).abs();
    final maxDifference = service1.price * priceTolerance;

    return service1.vendorId == service2.vendorId &&
        priceDifference <= maxDifference;
  }

  /// Get service with better rating
  ServiceEntity getBetterRated() {
    return service1.rating >= service2.rating ? service1 : service2;
  }

  /// Get service with better value (rating/price)
  ServiceEntity getBetterValue() {
    final value1 = service1.rating / service1.price;
    final value2 = service2.rating / service2.price;
    return value1 >= value2 ? service1 : service2;
  }

  /// Get price difference
  double getPriceDifference() {
    return (service1.price - service2.price).abs();
  }

  /// Get rating difference
  double getRatingDifference() {
    return (service1.rating - service2.rating).abs();
  }

  /// Get comparison summary
  Map<String, dynamic> getComparison() {
    return {
      'priceDifference': getPriceDifference(),
      'ratingDifference': getRatingDifference(),
      'betterRated': getBetterRated().id,
      'betterValue': getBetterValue().id,
      'areSimilar': areSimilar(),
    };
  }
}

// ==================== CONSTANTS ====================

/// Service category constants
class ServiceCategory {
  static const String basic = 'basic';
  static const String standard = 'standard';
  static const String premium = 'premium';

  static const List<String> all = [basic, standard, premium];

  static String getDisplayName(String category) {
    switch (category.toLowerCase()) {
      case basic:
        return 'Basic';
      case standard:
        return 'Standard';
      case premium:
        return 'Premium';
      default:
        return category;
    }
  }

  static String getDescription(String category) {
    switch (category.toLowerCase()) {
      case basic:
        return 'Basic car wash with water and soap';
      case standard:
        return 'Standard wash with waxing and drying';
      case premium:
        return 'Premium service with interior cleaning';
      default:
        return '';
    }
  }
}

/// Service pricing constants
class ServicePricing {
  static const double minPrice = 99.0;
  static const double maxPrice = 5000.0;
  static const double platformFeePercent = 10.0;

  static double calculatePlatformFee(double servicePrice) {
    return (servicePrice * platformFeePercent) / 100;
  }

  static double calculateVendorAmount(double servicePrice) {
    final fee = calculatePlatformFee(servicePrice);
    return servicePrice - fee;
  }
}

/// Service duration constants
class ServiceDuration {
  static const int minDuration = 15; // minutes
  static const int maxDuration = 480; // minutes (8 hours)

  static const int basicDuration = 30;
  static const int standardDuration = 60;
  static const int premiumDuration = 90;

  static String format(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }
}

/// Service rating constants
class ServiceRating {
  static const double minRating = 0.0;
  static const double maxRating = 5.0;
  static const double popularThreshold = 4.0;
  static const int minReviewsForRating = 5;

  static String getDescription(double rating) {
    if (rating >= 4.5) {
      return 'Excellent';
    } else if (rating >= 4.0) {
      return 'Very Good';
    } else if (rating >= 3.0) {
      return 'Good';
    } else if (rating >= 2.0) {
      return 'Fair';
    } else if (rating > 0) {
      return 'Poor';
    } else {
      return 'No Rating';
    }
  }

  static int getStars(double rating) {
    return rating.round();
  }
}