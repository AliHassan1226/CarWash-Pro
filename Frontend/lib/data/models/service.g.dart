// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map json) => $checkedCreate(
      'Service',
      json,
      ($checkedConvert) {
        final val = Service(
          id: $checkedConvert('id', (v) => v as String),
          vendorId: $checkedConvert('vendor_id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String),
          category: $checkedConvert('category', (v) => v as String),
          price: $checkedConvert('price', (v) => (v as num).toDouble()),
          estimatedDuration: $checkedConvert(
              'estimated_duration', (v) => (v as num).toDouble()),
          discountPrice:
              $checkedConvert('discount_price', (v) => (v as num?)?.toDouble()),
          imageUrl: $checkedConvert('image_url', (v) => v as String?),
          imageUrls: $checkedConvert('image_urls',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          rating:
              $checkedConvert('rating', (v) => (v as num?)?.toDouble() ?? 0.0),
          reviewCount:
              $checkedConvert('review_count', (v) => (v as num?)?.toInt() ?? 0),
          totalBookings: $checkedConvert(
              'total_bookings', (v) => (v as num?)?.toInt() ?? 0),
          isActive: $checkedConvert('is_active', (v) => v as bool),
          isFeatured:
              $checkedConvert('is_featured', (v) => v as bool? ?? false),
          amenities: $checkedConvert('amenities',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          details: $checkedConvert(
              'details',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )),
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          updatedAt:
              $checkedConvert('updated_at', (v) => DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'vendorId': 'vendor_id',
        'estimatedDuration': 'estimated_duration',
        'discountPrice': 'discount_price',
        'imageUrl': 'image_url',
        'imageUrls': 'image_urls',
        'reviewCount': 'review_count',
        'totalBookings': 'total_bookings',
        'isActive': 'is_active',
        'isFeatured': 'is_featured',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at'
      },
    );

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'id': instance.id,
      'vendor_id': instance.vendorId,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'price': instance.price,
      'estimated_duration': instance.estimatedDuration,
      'discount_price': instance.discountPrice,
      'image_url': instance.imageUrl,
      'image_urls': instance.imageUrls,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'total_bookings': instance.totalBookings,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
      'amenities': instance.amenities,
      'details': instance.details,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
