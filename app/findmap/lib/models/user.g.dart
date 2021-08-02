// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['idx'] as int,
    json['token'] as String,
    json['name'] as String,
    json['email'] as String,
    json['password'] as String,
    json['nickName'] as String,
    json['birthday'] as String,
    json['gender'] as String,
    json['phoneNum'] as String,
    json['taste'] as String,
    json['profileUrl'] as String,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'idx': instance.userIdx,
      'token': instance.accessToken,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'nickName': instance.nickName,
      'birthday': instance.birthday,
      'gender': instance.gender,
      'phoneNum': instance.phoneNum,
      'taste': instance.taste,
      'profileUrl': instance.profileUrl,
    };
