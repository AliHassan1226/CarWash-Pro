// service.dart - Complete Service Model

import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable(
  explicitToJson: true,
  anyMap: true,
  checked: true,
)
class Service {
  final String id;
  
  @JsonKey(name: 'vendor_id')
  final String vendorId;
  
  final String name;
  final String description;
  final String category; // 'basic', 'standard', 'premium', 'luxury'
  final double price;
  
  @JsonKey(name: 'estimated_duration')
  final double estimatedDuration; // in minutes
  
  @JsonKey(name: 'discount_price')
  final double? discountPrice;
  
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  
  @JsonKey(name: 'image_urls')
  final List<String>? imageUrls;
  
  final double rating;
  
  @JsonKey(name: 'review_count')
  final int reviewCount;
  
  @JsonKey(name: 'total_bookings')
  final int totalBookings;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  
  final List<String>? amenities;
  final Map<String, dynamic>? details;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.estimatedDuration,
    this.discountPrice,
    this.imageUrl,
    this.imageUrls,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.totalBookings = 0,
    required this.isActive,
    this.isFeatured = false,
    this.amenities,
    this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
  
  Map<String, dynamic> toJson() => _$ServiceToJson(this);

  // Copy with method for immutability
  Service copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    String? category,
    double? price,
    double? estimatedDuration,
    double? discountPrice,
    String? imageUrl,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    int? totalBookings,
    bool? isActive,
    bool? isFeatured,
    List<String>? amenities,
    Map<String, dynamic>? details,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalBookings: totalBookings ?? this.totalBookings,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      amenities: amenities ?? this.amenities,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Utility methods
  double get finalPrice => discountPrice ?? price;
  
  double get discountPercentage {
    if (discountPrice == null || discountPrice == 0 || price == 0) return 0;
    return ((price - discountPrice!) / price * 100).roundToDouble();
  }

  bool get hasDiscount => discountPrice != null && discountPrice! < price && discountPrice! > 0;

  double get savingsAmount => hasDiscount ? price - discountPrice! : 0;

  String get durationText {
    if (estimatedDuration < 60) {
      return '${estimatedDuration.toInt()} min${estimatedDuration.toInt() == 1 ? '' : 's'}';
    } else {
      final hours = (estimatedDuration / 60).floor();
      final mins = estimatedDuration.remainder(60).toInt();
      if (mins == 0) {
        return '${hours}h';
      }
      return '${hours}h ${mins}m';
    }
  }

  String get categoryDisplay {
    switch (category.toLowerCase()) {
      case 'basic':
        return 'Basic';
      case 'standard':
        return 'Standard';
      case 'premium':
        return 'Premium';
      case 'luxury':
        return 'Luxury';
      default:
        return category[0].toUpperCase() + category.substring(1).toLowerCase();
    }
  }

  bool get isPopular => totalBookings > 100;
  
  bool get isHighlyRated => rating >= 4.5;
  
  bool get isNew {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return createdAt.isAfter(weekAgo);
  }

  bool get hasImages => imageUrls != null && imageUrls!.isNotEmpty;
  
  bool get hasAmenities => amenities != null && amenities!.isNotEmpty;
  
  bool get hasDetails => details != null && details!.isNotEmpty;

  List<String> get allImages {
    final images = <String>[];
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      images.add(imageUrl!);
    }
    if (imageUrls != null) {
      images.addAll(imageUrls!);
    }
    return images;
  }

  String? get firstImage => allImages.isNotEmpty ? allImages.first : null;

  Map<String, dynamic> toUpdateMap(Service original) {
    final updateMap = <String, dynamic>{};
    
    if (name != original.name) updateMap['name'] = name;
    if (description != original.description) updateMap['description'] = description;
    if (category != original.category) updateMap['category'] = category;
    if (price != original.price) updateMap['price'] = price;
    if (estimatedDuration != original.estimatedDuration) {
      updateMap['estimated_duration'] = estimatedDuration;
    }
    if (discountPrice != original.discountPrice) {
      updateMap['discount_price'] = discountPrice;
    }
    if (imageUrl != original.imageUrl) updateMap['image_url'] = imageUrl;
    if (imageUrls != original.imageUrls) updateMap['image_urls'] = imageUrls;
    if (isActive != original.isActive) updateMap['is_active'] = isActive;
    if (isFeatured != original.isFeatured) updateMap['is_featured'] = isFeatured;
    if (amenities != original.amenities) updateMap['amenities'] = amenities;
    if (details != original.details) updateMap['details'] = details;
    
    return updateMap;
  }

  @override
  String toString() {
    return 'Service(id: $id, name: $name, price: $price, category: $category, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Service &&
        other.id == id &&
        other.vendorId == vendorId &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, vendorId, name);
}

// Extension for service list operations
extension ServiceListExtension on List<Service> {
  List<Service> get active => where((s) => s.isActive).toList();
  
  List<Service> get featured => where((s) => s.isFeatured).toList();
  
  List<Service> get onSale => where((s) => s.hasDiscount).toList();
  
  List<Service> get popular => where((s) => s.isPopular).toList();
  
  List<Service> get highlyRated => where((s) => s.isHighlyRated).toList();
  
  List<Service> get newServices => where((s) => s.isNew).toList();
  
  List<Service> byCategory(String category) {
    return where((s) => s.category.toLowerCase() == category.toLowerCase()).toList();
  }
  
  List<Service> byVendor(String vendorId) {
    return where((s) => s.vendorId == vendorId).toList();
  }
  
  List<Service> search(String query) {
    if (query.isEmpty) return this;
    
    final lowerQuery = query.toLowerCase();
    return where((s) =>
      s.name.toLowerCase().contains(lowerQuery) ||
      s.description.toLowerCase().contains(lowerQuery) ||
      s.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }
  
  List<Service> sortByPrice([bool ascending = true]) {
    final sorted = List<Service>.from(this);
    sorted.sort((a, b) => ascending 
        ? a.finalPrice.compareTo(b.finalPrice)
        : b.finalPrice.compareTo(a.finalPrice));
    return sorted;
  }
  
  List<Service> sortByRating([bool ascending = false]) {
    final sorted = List<Service>.from(this);
    sorted.sort((a, b) => ascending 
        ? a.rating.compareTo(b.rating)
        : b.rating.compareTo(a.rating));
    return sorted;
  }
  
  List<Service> sortByPopularity([bool ascending = false]) {
    final sorted = List<Service>.from(this);
    sorted.sort((a, b) => ascending 
        ? a.totalBookings.compareTo(b.totalBookings)
        : b.totalBookings.compareTo(a.totalBookings));
    return sorted;
  }
  
  Map<String, List<Service>> groupByCategory() {
    final map = <String, List<Service>>{};
    for (final service in this) {
      map.putIfAbsent(service.category, () => []).add(service);
    }
    return map;
  }
  
  double get averagePrice {
    if (isEmpty) return 0;
    final total = fold(0.0, (sum, s) => sum + s.finalPrice);
    return total / length;
  }
  
  double get averageRating {
    if (isEmpty) return 0;
    final total = fold(0.0, (sum, s) => sum + s.rating);
    return total / length;
  }
  
  int get totalBookingsCount => fold(0, (sum, s) => sum + s.totalBookings);
  
  Map<String, int> get categoryDistribution {
    final map = <String, int>{};
    for (final service in this) {
      map[service.category] = (map[service.category] ?? 0) + 1;
    }
    return map;
  }
}

// Enum for service categories
enum ServiceCategory {
  basic,
  standard,
  premium,
  luxury;
  
  @override
  String toString() => name;
  
  static ServiceCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'basic':
        return ServiceCategory.basic;
      case 'standard':
        return ServiceCategory.standard;
      case 'premium':
        return ServiceCategory.premium;
      case 'luxury':
        return ServiceCategory.luxury;
      default:
        throw ArgumentError('Invalid category: $category');
    }
  }
}

// Constants for service configuration
class ServiceConstants {
  static const List<String> validCategories = ['basic', 'standard', 'premium', 'luxury'];
  
  static const double minPrice = 0;
  static const double maxPrice = 10000;
  
  static const double minDuration = 15; // minutes
  static const double maxDuration = 480; // minutes (8 hours)
  
  static const int minNameLength = 3;
  static const int maxNameLength = 100;
  
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 1000;
  
  static const double defaultRating = 0.0;
  static const int defaultReviewCount = 0;
  
  static const String defaultImageUrl = 'assets/images/default_service.png';
  
  static const int popularThreshold = 100; // bookings
  static const double highlyRatedThreshold = 4.5;
  
  static const Duration newServicePeriod = Duration(days: 7);
}