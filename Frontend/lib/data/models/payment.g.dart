// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      customerId: json['customerId'] as String,
      vendorId: json['vendorId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      platformFee: (json['platformFee'] as num?)?.toDouble(),
      vendorAmount: (json['vendorAmount'] as num?)?.toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      transactionId: json['transactionId'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      errorMessage: json['errorMessage'] as String?,
      errorCode: json['errorCode'] as String?,
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      refundAmount: (json['refundAmount'] as num?)?.toDouble(),
      refundReason: json['refundReason'] as String?,
      refundedAt: json['refundedAt'] == null
          ? null
          : DateTime.parse(json['refundedAt'] as String),
      refundTransactionId: json['refundTransactionId'] as String?,
      cardHolderName: json['cardHolderName'] as String?,
      cardLastFour: json['cardLastFour'] as String?,
      cardNetwork: json['cardNetwork'] as String?,
      upiId: json['upiId'] as String?,
      bankName: json['bankName'] as String?,
      bankAccountLastFour: json['bankAccountLastFour'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringFrequency: json['recurringFrequency'] as String?,
      nextPaymentDate: json['nextPaymentDate'] == null
          ? null
          : DateTime.parse(json['nextPaymentDate'] as String),
      recurringCount: (json['recurringCount'] as num?)?.toInt(),
      invoiceNumber: json['invoiceNumber'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      breakdown: (json['breakdown'] as List<dynamic>?)
          ?.map((e) => PaymentBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'customerId': instance.customerId,
      'vendorId': instance.vendorId,
      'amount': instance.amount,
      'platformFee': instance.platformFee,
      'vendorAmount': instance.vendorAmount,
      'paymentMethod': instance.paymentMethod,
      'status': instance.status,
      'transactionId': instance.transactionId,
      'referenceNumber': instance.referenceNumber,
      'errorMessage': instance.errorMessage,
      'errorCode': instance.errorCode,
      'processedAt': instance.processedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'refundAmount': instance.refundAmount,
      'refundReason': instance.refundReason,
      'refundedAt': instance.refundedAt?.toIso8601String(),
      'refundTransactionId': instance.refundTransactionId,
      'cardHolderName': instance.cardHolderName,
      'cardLastFour': instance.cardLastFour,
      'cardNetwork': instance.cardNetwork,
      'upiId': instance.upiId,
      'bankName': instance.bankName,
      'bankAccountLastFour': instance.bankAccountLastFour,
      'isRecurring': instance.isRecurring,
      'recurringFrequency': instance.recurringFrequency,
      'nextPaymentDate': instance.nextPaymentDate?.toIso8601String(),
      'recurringCount': instance.recurringCount,
      'invoiceNumber': instance.invoiceNumber,
      'receiptUrl': instance.receiptUrl,
      'breakdown': instance.breakdown,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PaymentBreakdown _$PaymentBreakdownFromJson(Map<String, dynamic> json) =>
    PaymentBreakdown(
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      reference: json['reference'] as String?,
    );

Map<String, dynamic> _$PaymentBreakdownToJson(PaymentBreakdown instance) =>
    <String, dynamic>{
      'description': instance.description,
      'amount': instance.amount,
      'type': instance.type,
      'reference': instance.reference,
    };

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      id: json['id'] as String,
      paymentId: json['paymentId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      description: json['description'] as String?,
      relatedOrderId: json['relatedOrderId'] as String?,
      relatedPaymentId: json['relatedPaymentId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'paymentId': instance.paymentId,
      'type': instance.type,
      'amount': instance.amount,
      'status': instance.status,
      'description': instance.description,
      'relatedOrderId': instance.relatedOrderId,
      'relatedPaymentId': instance.relatedPaymentId,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };
