// Customer model

import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer {
  final String id;
  final String userId;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalSpent;
  final double averageOrderValue;
  final double walletBalance;
  final List<String> savedAddresses;
  final List<SavedPaymentMethod> savedPaymentMethods;
  final bool hasActiveSubscription;
  final DateTime? subscriptionExpiry;
  final String? subscriptionPlan;
  final List<String> favoriteServices;
  final List<String> favoriteVendors;
  final int loyaltyPoints;
  final int referralCount;
  final String? referralCode;
  final double? referralBonus;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool marketingEmails;
  final String? preferredLanguage;
  final String? preferredCurrency;
  final bool isBlacklisted;
  final String? blacklistReason;
  final DateTime? blacklistDate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.userId,
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.totalSpent = 0.0,
    this.averageOrderValue = 0.0,
    this.walletBalance = 0.0,
    this.savedAddresses = const [],
    this.savedPaymentMethods = const [],
    this.hasActiveSubscription = false,
    this.subscriptionExpiry,
    this.subscriptionPlan,
    this.favoriteServices = const [],
    this.favoriteVendors = const [],
    this.loyaltyPoints = 0,
    this.referralCount = 0,
    this.referralCode,
    this.referralBonus,
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.pushNotifications = true,
    this.marketingEmails = true,
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'INR',
    this.isBlacklisted = false,
    this.blacklistReason,
    this.blacklistDate,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
  
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  // Copy with method for immutability
  Customer copyWith({
    String? id,
    String? userId,
    int? totalOrders,
    int? completedOrders,
    int? cancelledOrders,
    double? totalSpent,
    double? averageOrderValue,
    double? walletBalance,
    List<String>? savedAddresses,
    List<SavedPaymentMethod>? savedPaymentMethods,
    bool? hasActiveSubscription,
    DateTime? subscriptionExpiry,
    String? subscriptionPlan,
    List<String>? favoriteServices,
    List<String>? favoriteVendors,
    int? loyaltyPoints,
    int? referralCount,
    String? referralCode,
    double? referralBonus,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? marketingEmails,
    String? preferredLanguage,
    String? preferredCurrency,
    bool? isBlacklisted,
    String? blacklistReason,
    DateTime? blacklistDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalOrders: totalOrders ?? this.totalOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      walletBalance: walletBalance ?? this.walletBalance,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      savedPaymentMethods: savedPaymentMethods ?? this.savedPaymentMethods,
      hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      favoriteServices: favoriteServices ?? this.favoriteServices,
      favoriteVendors: favoriteVendors ?? this.favoriteVendors,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      referralCount: referralCount ?? this.referralCount,
      referralCode: referralCode ?? this.referralCode,
      referralBonus: referralBonus ?? this.referralBonus,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      blacklistReason: blacklistReason ?? this.blacklistReason,
      blacklistDate: blacklistDate ?? this.blacklistDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Utility methods
  bool get isLoyalCustomer => totalOrders >= 10;
  
  bool get isFrequentCustomer => totalOrders >= 5;
  
  bool get isNewCustomer => totalOrders < 5;

  bool get hasSubscription => 
    hasActiveSubscription && 
    subscriptionExpiry != null && 
    subscriptionExpiry!.isAfter(DateTime.now());

  int get cancellationRate {
    if (totalOrders == 0) return 0;
    return ((cancelledOrders / totalOrders) * 100).toInt();
  }

  int get completionRate {
    if (totalOrders == 0) return 0;
    return ((completedOrders / totalOrders) * 100).toInt();
  }

  bool get canReferFriends => referralCode != null && referralCode!.isNotEmpty;

  bool get hasSavedPayments => savedPaymentMethods.isNotEmpty;

  bool get hasSavedAddresses => savedAddresses.isNotEmpty;

  int get rewardCashback {
    return (loyaltyPoints / 100).toInt(); // 100 points = 1 rupee
  }

  @override
  String toString() => 'Customer(id: $id, userId: $userId, totalOrders: $totalOrders)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}

@JsonSerializable()
class SavedPaymentMethod {
  final String id;
  final String customerId;
  final String type; // 'card', 'upi', 'wallet', 'bank_transfer'
  final String displayName;
  final String lastFour; // Last 4 digits
  final String? cardNetwork; // Visa, Mastercard, Amex
  final String? upiId;
  final String? bankName;
  final bool isDefault;
  final bool isExpired;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime createdAt;

  SavedPaymentMethod({
    required this.id,
    required this.customerId,
    required this.type,
    required this.displayName,
    required this.lastFour,
    this.cardNetwork,
    this.upiId,
    this.bankName,
    this.isDefault = false,
    this.isExpired = false,
    this.expiryDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) => 
    _$SavedPaymentMethodFromJson(json);
  
  Map<String, dynamic> toJson() => _$SavedPaymentMethodToJson(this);

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'card':
        return 'Card';
      case 'upi':
        return 'UPI';
      case 'wallet':
        return 'Wallet';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return type;
    }
  }

  @override
  String toString() => 'SavedPaymentMethod(type: $type, displayName: $displayName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedPaymentMethod &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}