// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: json['level'] as String? ?? "A1",
      learningGoal: json['learningGoal'] as String?,
      dailyGoal: json['dailyGoal'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'xp': instance.xp,
      'level': instance.level,
      'learningGoal': instance.learningGoal,
      'dailyGoal': instance.dailyGoal,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

// Bridge function expected by freezed-generated fromJson factory
UserModel _$UserModelFromJson(Map<String, dynamic> json) =>
    _$$UserModelImplFromJson(json);
