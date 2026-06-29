// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
      id: json['id'] as String,
      userId: json['userId'] as String,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      savedAddresses: (json['savedAddresses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      savedPaymentMethods: (json['savedPaymentMethods'] as List<dynamic>?)
              ?.map(
                  (e) => SavedPaymentMethod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      hasActiveSubscription: json['hasActiveSubscription'] as bool? ?? false,
      subscriptionExpiry: json['subscriptionExpiry'] == null
          ? null
          : DateTime.parse(json['subscriptionExpiry'] as String),
      subscriptionPlan: json['subscriptionPlan'] as String?,
      favoriteServices: (json['favoriteServices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favoriteVendors: (json['favoriteVendors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      referralCount: (json['referralCount'] as num?)?.toInt() ?? 0,
      referralCode: json['referralCode'] as String?,
      referralBonus: (json['referralBonus'] as num?)?.toDouble(),
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      marketingEmails: json['marketingEmails'] as bool? ?? true,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      preferredCurrency: json['preferredCurrency'] as String? ?? 'INR',
      isBlacklisted: json['isBlacklisted'] as bool? ?? false,
      blacklistReason: json['blacklistReason'] as String?,
      blacklistDate: json['blacklistDate'] == null
          ? null
          : DateTime.parse(json['blacklistDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'totalOrders': instance.totalOrders,
      'completedOrders': instance.completedOrders,
      'cancelledOrders': instance.cancelledOrders,
      'totalSpent': instance.totalSpent,
      'averageOrderValue': instance.averageOrderValue,
      'walletBalance': instance.walletBalance,
      'savedAddresses': instance.savedAddresses,
      'savedPaymentMethods': instance.savedPaymentMethods,
      'hasActiveSubscription': instance.hasActiveSubscription,
      'subscriptionExpiry': instance.subscriptionExpiry?.toIso8601String(),
      'subscriptionPlan': instance.subscriptionPlan,
      'favoriteServices': instance.favoriteServices,
      'favoriteVendors': instance.favoriteVendors,
      'loyaltyPoints': instance.loyaltyPoints,
      'referralCount': instance.referralCount,
      'referralCode': instance.referralCode,
      'referralBonus': instance.referralBonus,
      'emailNotifications': instance.emailNotifications,
      'smsNotifications': instance.smsNotifications,
      'pushNotifications': instance.pushNotifications,
      'marketingEmails': instance.marketingEmails,
      'preferredLanguage': instance.preferredLanguage,
      'preferredCurrency': instance.preferredCurrency,
      'isBlacklisted': instance.isBlacklisted,
      'blacklistReason': instance.blacklistReason,
      'blacklistDate': instance.blacklistDate?.toIso8601String(),
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SavedPaymentMethod _$SavedPaymentMethodFromJson(Map<String, dynamic> json) =>
    SavedPaymentMethod(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      type: json['type'] as String,
      displayName: json['displayName'] as String,
      lastFour: json['lastFour'] as String,
      cardNetwork: json['cardNetwork'] as String?,
      upiId: json['upiId'] as String?,
      bankName: json['bankName'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      isExpired: json['isExpired'] as bool? ?? false,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SavedPaymentMethodToJson(SavedPaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'type': instance.type,
      'displayName': instance.displayName,
      'lastFour': instance.lastFour,
      'cardNetwork': instance.cardNetwork,
      'upiId': instance.upiId,
      'bankName': instance.bankName,
      'isDefault': instance.isDefault,
      'isExpired': instance.isExpired,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
