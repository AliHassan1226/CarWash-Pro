// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) => Vendor(
      id: json['id'] as String,
      userId: json['userId'] as String,
      businessName: json['businessName'] as String?,
      businessRegistration: json['businessRegistration'] as String?,
      businessType: json['businessType'] as String?,
      businessCategory: json['businessCategory'] as String?,
      businessDescription: json['businessDescription'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankIfscCode: json['bankIfscCode'] as String?,
      bankAccountHolderName: json['bankAccountHolderName'] as String?,
      bankName: json['bankName'] as String?,
      serviceTypes: (json['serviceTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      totalRefunds: (json['totalRefunds'] as num?)?.toDouble(),
      isVerified: json['isVerified'] as bool,
      verificationDate: json['verificationDate'] == null
          ? null
          : DateTime.parse(json['verificationDate'] as String),
      verificationDocuments: json['verificationDocuments'] as String?,
      isSuspended: json['isSuspended'] as bool? ?? false,
      suspensionReason: json['suspensionReason'] as String?,
      suspensionDate: json['suspensionDate'] == null
          ? null
          : DateTime.parse(json['suspensionDate'] as String),
      isBlocked: json['isBlocked'] as bool? ?? false,
      blockReason: json['blockReason'] as String?,
      blockDate: json['blockDate'] == null
          ? null
          : DateTime.parse(json['blockDate'] as String),
      licenseImageUrl: json['licenseImageUrl'] as String?,
      certificationUrls: (json['certificationUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      gstNumber: json['gstNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      totalServices: (json['totalServices'] as num?)?.toInt() ?? 0,
      activeServices: (json['activeServices'] as num?)?.toInt() ?? 0,
      website: json['website'] as String?,
      socialMedia: json['socialMedia'] as String?,
      operatingHours: json['operatingHours'] as String?,
      serviceAreas: (json['serviceAreas'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
      repeatCustomers: (json['repeatCustomers'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble(),
      bankStatement: json['bankStatement'] as String?,
      hasInsurance: json['hasInsurance'] as bool? ?? false,
      insuranceExpiry: json['insuranceExpiry'] == null
          ? null
          : DateTime.parse(json['insuranceExpiry'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'businessName': instance.businessName,
      'businessRegistration': instance.businessRegistration,
      'businessType': instance.businessType,
      'businessCategory': instance.businessCategory,
      'businessDescription': instance.businessDescription,
      'bankAccountNumber': instance.bankAccountNumber,
      'bankIfscCode': instance.bankIfscCode,
      'bankAccountHolderName': instance.bankAccountHolderName,
      'bankName': instance.bankName,
      'serviceTypes': instance.serviceTypes,
      'rating': instance.rating,
      'orderCount': instance.orderCount,
      'completedOrders': instance.completedOrders,
      'cancelledOrders': instance.cancelledOrders,
      'totalEarnings': instance.totalEarnings,
      'walletBalance': instance.walletBalance,
      'totalRefunds': instance.totalRefunds,
      'isVerified': instance.isVerified,
      'verificationDate': instance.verificationDate?.toIso8601String(),
      'verificationDocuments': instance.verificationDocuments,
      'isSuspended': instance.isSuspended,
      'suspensionReason': instance.suspensionReason,
      'suspensionDate': instance.suspensionDate?.toIso8601String(),
      'isBlocked': instance.isBlocked,
      'blockReason': instance.blockReason,
      'blockDate': instance.blockDate?.toIso8601String(),
      'licenseImageUrl': instance.licenseImageUrl,
      'certificationUrls': instance.certificationUrls,
      'gstNumber': instance.gstNumber,
      'panNumber': instance.panNumber,
      'averageRating': instance.averageRating,
      'reviewCount': instance.reviewCount,
      'totalServices': instance.totalServices,
      'activeServices': instance.activeServices,
      'website': instance.website,
      'socialMedia': instance.socialMedia,
      'operatingHours': instance.operatingHours,
      'serviceAreas': instance.serviceAreas,
      'totalCustomers': instance.totalCustomers,
      'repeatCustomers': instance.repeatCustomers,
      'completionRate': instance.completionRate,
      'bankStatement': instance.bankStatement,
      'hasInsurance': instance.hasInsurance,
      'insuranceExpiry': instance.insuranceExpiry?.toIso8601String(),
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
