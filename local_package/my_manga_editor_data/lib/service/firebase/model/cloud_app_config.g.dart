// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CloudAppConfig _$CloudAppConfigFromJson(Map<String, dynamic> json) =>
    _CloudAppConfig(
      minSupportedBuildNumber: (json['minSupportedBuildNumber'] as num).toInt(),
      noticeMessage: json['noticeMessage'] as String? ?? '',
      noticeId: json['noticeId'] as String? ?? '',
    );

Map<String, dynamic> _$CloudAppConfigToJson(_CloudAppConfig instance) =>
    <String, dynamic>{
      'minSupportedBuildNumber': instance.minSupportedBuildNumber,
      'noticeMessage': instance.noticeMessage,
      'noticeId': instance.noticeId,
    };
