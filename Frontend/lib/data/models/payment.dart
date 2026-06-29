// Payment model

import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final String id;
  final String orderId;
  final String customerId;
  final String? vendorId;
  final double amount;
  final double? platformFee;
  final double? vendorAmount;
  final String paymentMethod; // 'card', 'upi', 'wallet', 'bank_transfer', 'cod'
  final String status; // 'pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled'
  final String? transactionId;
  final String? referenceNumber;
  final String? errorMessage;
  final String? errorCode;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final double? refundAmount;
  final String? refundReason;
  final DateTime? refundedAt;
  final String? refundTransactionId;
  final String? cardHolderName;
  final String? cardLastFour;
  final String? cardNetwork; // 'visa', 'mastercard', 'amex'
  final String? upiId;
  final String? bankName;
  final String? bankAccountLastFour;
  final bool isRecurring;
  final String? recurringFrequency; // 'daily', 'weekly', 'monthly'
  final DateTime? nextPaymentDate;
  final int? recurringCount;
  final String? invoiceNumber;
  final String? receiptUrl;
  final List<PaymentBreakdown>? breakdown;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.customerId,
    this.vendorId,
    required this.amount,
    this.platformFee,
    this.vendorAmount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.referenceNumber,
    this.errorMessage,
    this.errorCode,
    this.processedAt,
    this.completedAt,
    this.refundAmount,
    this.refundReason,
    this.refundedAt,
    this.refundTransactionId,
    this.cardHolderName,
    this.cardLastFour,
    this.cardNetwork,
    this.upiId,
    this.bankName,
    this.bankAccountLastFour,
    this.isRecurring = false,
    this.recurringFrequency,
    this.nextPaymentDate,
    this.recurringCount,
    this.invoiceNumber,
    this.receiptUrl,
    this.breakdown,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  // Copy with method for immutability
  Payment copyWith({
    String? id,
    String? orderId,
    String? customerId,
    String? vendorId,
    double? amount,
    double? platformFee,
    double? vendorAmount,
    String? paymentMethod,
    String? status,
    String? transactionId,
    String? referenceNumber,
    String? errorMessage,
    String? errorCode,
    DateTime? processedAt,
    DateTime? completedAt,
    double? refundAmount,
    String? refundReason,
    DateTime? refundedAt,
    String? refundTransactionId,
    String? cardHolderName,
    String? cardLastFour,
    String? cardNetwork,
    String? upiId,
    String? bankName,
    String? bankAccountLastFour,
    bool? isRecurring,
    String? recurringFrequency,
    DateTime? nextPaymentDate,
    int? recurringCount,
    String? invoiceNumber,
    String? receiptUrl,
    List<PaymentBreakdown>? breakdown,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      vendorId: vendorId ?? this.vendorId,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      vendorAmount: vendorAmount ?? this.vendorAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      refundedAt: refundedAt ?? this.refundedAt,
      refundTransactionId: refundTransactionId ?? this.refundTransactionId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardLastFour: cardLastFour ?? this.cardLastFour,
      cardNetwork: cardNetwork ?? this.cardNetwork,
      upiId: upiId ?? this.upiId,
      bankName: bankName ?? this.bankName,
      bankAccountLastFour: bankAccountLastFour ?? this.bankAccountLastFour,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      recurringCount: recurringCount ?? this.recurringCount,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      breakdown: breakdown ?? this.breakdown,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Utility methods
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';
  bool get isCancelled => status == 'cancelled';

  bool get isSuccessful => isCompleted;

  bool get canBeRefunded => isCompleted && status != 'refunded';

  bool get hasRefund => refundAmount != null && refundAmount! > 0;

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get paymentMethodDisplay {
    switch (paymentMethod.toLowerCase()) {
      case 'card':
        return 'Card';
      case 'upi':
        return 'UPI';
      case 'wallet':
        return 'Wallet';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return paymentMethod;
    }
  }

  String get paymentDetails {
    if (paymentMethod == 'card' && cardLastFour != null) {
      return '$cardNetwork ending in $cardLastFour';
    } else if (paymentMethod == 'upi' && upiId != null) {
      return upiId!;
    } else if (paymentMethod == 'bank_transfer' && bankName != null) {
      return bankName!;
    }
    return paymentMethodDisplay;
  }

  double get netAmount {
    double net = amount;
    if (platformFee != null) {
      net -= platformFee!;
    }
    return net;
  }

  Duration? get processingTime {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  bool get isLatePaid {
    if (completedAt == null) return false;
    return completedAt!.difference(createdAt).inHours > 24;
  }

  @override
  String toString() => 
    'Payment(id: $id, status: $status, amount: $amount, method: $paymentMethod)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class PaymentBreakdown {
  final String description;
  final double amount;
  final String type; // 'service', 'tax', 'fee', 'discount', 'refund'
  final String? reference;

  PaymentBreakdown({
    required this.description,
    required this.amount,
    required this.type,
    this.reference,
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) => 
    _$PaymentBreakdownFromJson(json);
  
  Map<String, dynamic> toJson() => _$PaymentBreakdownToJson(this);

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'service':
        return 'Service';
      case 'tax':
        return 'Tax';
      case 'fee':
        return 'Fee';
      case 'discount':
        return 'Discount';
      case 'refund':
        return 'Refund';
      default:
        return type;
    }
  }

  @override
  String toString() => 'PaymentBreakdown(description: $description, amount: $amount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentBreakdown &&
          runtimeType == other.runtimeType &&
          description == other.description;

  @override
  int get hashCode => description.hashCode;
}

@JsonSerializable()
class Transaction {
  final String id;
  final String paymentId;
  final String type; // 'debit', 'credit', 'refund'
  final double amount;
  final String status;
  final String? description;
  final String? relatedOrderId;
  final String? relatedPaymentId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.paymentId,
    required this.type,
    required this.amount,
    required this.status,
    this.description,
    this.relatedOrderId,
    this.relatedPaymentId,
    this.metadata,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => 
    _$TransactionFromJson(json);
  
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  bool get isDebit => type == 'debit';
  bool get isCredit => type == 'credit';
  bool get isRefund => type == 'refund';

  @override
  String toString() => 'Transaction(id: $id, type: $type, amount: $amount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}