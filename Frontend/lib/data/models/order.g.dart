// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map json) => $checkedCreate(
      'Order',
      json,
      ($checkedConvert) {
        final val = Order(
          id: $checkedConvert('id', (v) => v as String),
          customerId: $checkedConvert('customer_id', (v) => v as String),
          vendorId: $checkedConvert('vendor_id', (v) => v as String),
          serviceId: $checkedConvert('service_id', (v) => v as String),
          serviceName: $checkedConvert('service_name', (v) => v as String?),
          vendorName: $checkedConvert('vendor_name', (v) => v as String?),
          totalAmount:
              $checkedConvert('total_amount', (v) => (v as num).toDouble()),
          discountAmount: $checkedConvert(
              'discount_amount', (v) => (v as num?)?.toDouble()),
          taxAmount:
              $checkedConvert('tax_amount', (v) => (v as num?)?.toDouble()),
          status: $checkedConvert('status', (v) => v as String),
          cancellationReason:
              $checkedConvert('cancellation_reason', (v) => v as String?),
          scheduledDate: $checkedConvert(
              'scheduled_date', (v) => DateTime.parse(v as String)),
          completedDate: $checkedConvert('completed_date',
              (v) => v == null ? null : DateTime.parse(v as String)),
          notes: $checkedConvert('notes', (v) => v as String?),
          carDetails: $checkedConvert('car_details', (v) => v as String?),
          carColor: $checkedConvert('car_color', (v) => v as String?),
          carPlateNumber:
              $checkedConvert('car_plate_number', (v) => v as String?),
          address: $checkedConvert('address', (v) => v as String?),
          latitude: $checkedConvert('latitude', (v) => (v as num?)?.toDouble()),
          longitude:
              $checkedConvert('longitude', (v) => (v as num?)?.toDouble()),
          rating: $checkedConvert('rating', (v) => (v as num?)?.toDouble()),
          review: $checkedConvert('review', (v) => v as String?),
          reviewPhotosCount: $checkedConvert(
              'review_photos_count', (v) => (v as num?)?.toInt()),
          paymentMethod: $checkedConvert('payment_method', (v) => v as String?),
          paymentStatus: $checkedConvert(
              'payment_status', (v) => v as String? ?? 'pending'),
          transactionId: $checkedConvert('transaction_id', (v) => v as String?),
          isRescheduleAllowed: $checkedConvert(
              'is_reschedule_allowed', (v) => v as bool? ?? true),
          rescheduledFrom: $checkedConvert('rescheduled_from',
              (v) => v == null ? null : DateTime.parse(v as String)),
          rescheduleCount: $checkedConvert(
              'reschedule_count', (v) => (v as num?)?.toInt() ?? 0),
          customerNotes: $checkedConvert('customer_notes', (v) => v as String?),
          vendorNotes: $checkedConvert('vendor_notes', (v) => v as String?),
          metadata: $checkedConvert(
              'metadata',
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
        'customerId': 'customer_id',
        'vendorId': 'vendor_id',
        'serviceId': 'service_id',
        'serviceName': 'service_name',
        'vendorName': 'vendor_name',
        'totalAmount': 'total_amount',
        'discountAmount': 'discount_amount',
        'taxAmount': 'tax_amount',
        'cancellationReason': 'cancellation_reason',
        'scheduledDate': 'scheduled_date',
        'completedDate': 'completed_date',
        'carDetails': 'car_details',
        'carColor': 'car_color',
        'carPlateNumber': 'car_plate_number',
        'reviewPhotosCount': 'review_photos_count',
        'paymentMethod': 'payment_method',
        'paymentStatus': 'payment_status',
        'transactionId': 'transaction_id',
        'isRescheduleAllowed': 'is_reschedule_allowed',
        'rescheduledFrom': 'rescheduled_from',
        'rescheduleCount': 'reschedule_count',
        'customerNotes': 'customer_notes',
        'vendorNotes': 'vendor_notes',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at'
      },
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'vendor_id': instance.vendorId,
      'service_id': instance.serviceId,
      'service_name': instance.serviceName,
      'vendor_name': instance.vendorName,
      'total_amount': instance.totalAmount,
      'discount_amount': instance.discountAmount,
      'tax_amount': instance.taxAmount,
      'status': instance.status,
      'cancellation_reason': instance.cancellationReason,
      'scheduled_date': instance.scheduledDate.toIso8601String(),
      'completed_date': instance.completedDate?.toIso8601String(),
      'notes': instance.notes,
      'car_details': instance.carDetails,
      'car_color': instance.carColor,
      'car_plate_number': instance.carPlateNumber,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rating': instance.rating,
      'review': instance.review,
      'review_photos_count': instance.reviewPhotosCount,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'transaction_id': instance.transactionId,
      'is_reschedule_allowed': instance.isRescheduleAllowed,
      'rescheduled_from': instance.rescheduledFrom?.toIso8601String(),
      'reschedule_count': instance.rescheduleCount,
      'customer_notes': instance.customerNotes,
      'vendor_notes': instance.vendorNotes,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
