// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) {
  return UserInfo(
    json['idx'] as int,
    json['profileUrl'] as String,
    json['nickName'] as String,
    json['description'] as String,
    json['ScrapCount'] as int,
    json['FollowerCount'] as int,
    json['HaertCount'] as int,
    json['status'] as bool,
  );
}

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'idx': instance.idx,
      'profileUrl': instance.profileUrl,
      'nickName': instance.nickName,
      'description': instance.description,
      'ScrapCount': instance.ScrapCount,
      'FollowerCount': instance.FollowerCount,
      'HaertCount': instance.HaertCount,
      'status': instance.status,
    };
