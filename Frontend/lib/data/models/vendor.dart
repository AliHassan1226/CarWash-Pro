// Vendor model

import 'package:json_annotation/json_annotation.dart';

part 'vendor.g.dart';

@JsonSerializable()
class Vendor {
  final String id;
  final String userId;
  final String? businessName;
  final String? businessRegistration;
  final String? businessType; // 'individual', 'partnership', 'pvt_ltd'
  final String? businessCategory;
  final String? businessDescription;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankAccountHolderName;
  final String? bankName;
  final List<String>? serviceTypes;
  final double rating;
  final int orderCount;
  final int completedOrders;
  final int cancelledOrders;
  final double totalEarnings;
  final double walletBalance;
  final double? totalRefunds;
  final bool isVerified;
  final DateTime? verificationDate;
  final String? verificationDocuments;
  final bool isSuspended;
  final String? suspensionReason;
  final DateTime? suspensionDate;
  final bool isBlocked;
  final String? blockReason;
  final DateTime? blockDate;
  final String? licenseImageUrl;
  final List<String>? certificationUrls;
  final String? gstNumber;
  final String? panNumber;
  final double? averageRating;
  final int? reviewCount;
  final int totalServices;
  final int activeServices;
  final String? website;
  final String? socialMedia;
  final String? operatingHours;
  final List<String>? serviceAreas;
  final int totalCustomers;
  final int repeatCustomers;
  final double? completionRate;
  final String? bankStatement;
  final bool hasInsurance;
  final DateTime? insuranceExpiry;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vendor({
    required this.id,
    required this.userId,
    this.businessName,
    this.businessRegistration,
    this.businessType,
    this.businessCategory,
    this.businessDescription,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankAccountHolderName,
    this.bankName,
    this.serviceTypes,
    this.rating = 0.0,
    this.orderCount = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.totalEarnings = 0.0,
    this.walletBalance = 0.0,
    this.totalRefunds,
    required this.isVerified,
    this.verificationDate,
    this.verificationDocuments,
    this.isSuspended = false,
    this.suspensionReason,
    this.suspensionDate,
    this.isBlocked = false,
    this.blockReason,
    this.blockDate,
    this.licenseImageUrl,
    this.certificationUrls,
    this.gstNumber,
    this.panNumber,
    this.averageRating,
    this.reviewCount,
    this.totalServices = 0,
    this.activeServices = 0,
    this.website,
    this.socialMedia,
    this.operatingHours,
    this.serviceAreas,
    this.totalCustomers = 0,
    this.repeatCustomers = 0,
    this.completionRate,
    this.bankStatement,
    this.hasInsurance = false,
    this.insuranceExpiry,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
  
  Map<String, dynamic> toJson() => _$VendorToJson(this);

  // Copy with method for immutability
  Vendor copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? businessRegistration,
    String? businessType,
    String? businessCategory,
    String? businessDescription,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankAccountHolderName,
    String? bankName,
    List<String>? serviceTypes,
    double? rating,
    int? orderCount,
    int? completedOrders,
    int? cancelledOrders,
    double? totalEarnings,
    double? walletBalance,
    double? totalRefunds,
    bool? isVerified,
    DateTime? verificationDate,
    String? verificationDocuments,
    bool? isSuspended,
    String? suspensionReason,
    DateTime? suspensionDate,
    bool? isBlocked,
    String? blockReason,
    DateTime? blockDate,
    String? licenseImageUrl,
    List<String>? certificationUrls,
    String? gstNumber,
    String? panNumber,
    double? averageRating,
    int? reviewCount,
    int? totalServices,
    int? activeServices,
    String? website,
    String? socialMedia,
    String? operatingHours,
    List<String>? serviceAreas,
    int? totalCustomers,
    int? repeatCustomers,
    double? completionRate,
    String? bankStatement,
    bool? hasInsurance,
    DateTime? insuranceExpiry,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vendor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      businessRegistration: businessRegistration ?? this.businessRegistration,
      businessType: businessType ?? this.businessType,
      businessCategory: businessCategory ?? this.businessCategory,
      businessDescription: businessDescription ?? this.businessDescription,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      bankAccountHolderName: bankAccountHolderName ?? this.bankAccountHolderName,
      bankName: bankName ?? this.bankName,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      rating: rating ?? this.rating,
      orderCount: orderCount ?? this.orderCount,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      walletBalance: walletBalance ?? this.walletBalance,
      totalRefunds: totalRefunds ?? this.totalRefunds,
      isVerified: isVerified ?? this.isVerified,
      verificationDate: verificationDate ?? this.verificationDate,
      verificationDocuments: verificationDocuments ?? this.verificationDocuments,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      suspensionDate: suspensionDate ?? this.suspensionDate,
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      blockDate: blockDate ?? this.blockDate,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
      certificationUrls: certificationUrls ?? this.certificationUrls,
      gstNumber: gstNumber ?? this.gstNumber,
      panNumber: panNumber ?? this.panNumber,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalServices: totalServices ?? this.totalServices,
      activeServices: activeServices ?? this.activeServices,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
      operatingHours: operatingHours ?? this.operatingHours,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      repeatCustomers: repeatCustomers ?? this.repeatCustomers,
      completionRate: completionRate ?? this.completionRate,
      bankStatement: bankStatement ?? this.bankStatement,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Utility methods
  bool get canAcceptOrders => isVerified && !isSuspended && !isBlocked;

  bool get isFullyOnboarded => 
    isVerified && 
    gstNumber != null && 
    panNumber != null && 
    licenseImageUrl != null;

  bool get needsDocuments => !isVerified;

  bool get insuranceActive => 
    hasInsurance && 
    insuranceExpiry != null && 
    insuranceExpiry!.isAfter(DateTime.now());

  int get cancellationRate {
    if (orderCount == 0) return 0;
    return ((cancelledOrders / orderCount) * 100).toInt();
  }

  int get completionRateInt {
    if (completionRate == null) return 0;
    return (completionRate! * 100).toInt();
  }

  double get repeatCustomerPercentage {
    if (totalCustomers == 0) return 0;
    return (repeatCustomers / totalCustomers) * 100;
  }

  String get businessTypeDisplay {
    if (businessType == null) return 'Not Specified';
    switch (businessType!.toLowerCase()) {
      case 'individual':
        return 'Individual';
      case 'partnership':
        return 'Partnership';
      case 'pvt_ltd':
        return 'Pvt. Ltd.';
      default:
        return businessType!;
    }
  }

  bool get hasAllRequiredDocs => 
    licenseImageUrl != null &&
    gstNumber != null &&
    panNumber != null &&
    bankStatement != null;

  @override
  String toString() => 'Vendor(id: $id, businessName: $businessName, verified: $isVerified)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vendor &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}