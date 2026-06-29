// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map json) => $checkedCreate(
      'User',
      json,
      ($checkedConvert) {
        final val = User(
          id: $checkedConvert('id', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          phoneNumber: $checkedConvert('phone_number', (v) => v as String),
          role: $checkedConvert('role', (v) => v as String),
          profileImageUrl:
              $checkedConvert('profile_image_url', (v) => v as String?),
          address: $checkedConvert('address', (v) => v as String?),
          latitude: $checkedConvert('latitude', (v) => (v as num?)?.toDouble()),
          longitude:
              $checkedConvert('longitude', (v) => (v as num?)?.toDouble()),
          isVerified:
              $checkedConvert('is_verified', (v) => v as bool? ?? false),
          isActive: $checkedConvert('is_active', (v) => v as bool? ?? true),
          isEmailVerified:
              $checkedConvert('is_email_verified', (v) => v as bool? ?? false),
          isPhoneVerified:
              $checkedConvert('is_phone_verified', (v) => v as bool? ?? false),
          lastLogin: $checkedConvert('last_login',
              (v) => v == null ? null : DateTime.parse(v as String)),
          deviceToken: $checkedConvert('device_token', (v) => v as String?),
          fcmToken: $checkedConvert('fcm_token', (v) => v as String?),
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
        'phoneNumber': 'phone_number',
        'profileImageUrl': 'profile_image_url',
        'isVerified': 'is_verified',
        'isActive': 'is_active',
        'isEmailVerified': 'is_email_verified',
        'isPhoneVerified': 'is_phone_verified',
        'lastLogin': 'last_login',
        'deviceToken': 'device_token',
        'fcmToken': 'fcm_token',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at'
      },
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'phone_number': instance.phoneNumber,
      'role': instance.role,
      'profile_image_url': instance.profileImageUrl,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'is_verified': instance.isVerified,
      'is_active': instance.isActive,
      'is_email_verified': instance.isEmailVerified,
      'is_phone_verified': instance.isPhoneVerified,
      'last_login': instance.lastLogin?.toIso8601String(),
      'device_token': instance.deviceToken,
      'fcm_token': instance.fcmToken,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
