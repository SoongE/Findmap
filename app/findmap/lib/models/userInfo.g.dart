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
    json['FollowCount'] as int,
    json['HaertCount'] as int,
  );
}

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'idx': instance.idx,
      'profileUrl': instance.profileUrl,
      'nickName': instance.nickName,
      'description': instance.description,
      'ScrapCount': instance.ScrapCount,
      'FollowCount': instance.FollowCount,
      'HaertCount': instance.HaertCount,
    };
