// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostFolder _$PostFolderFromJson(Map<String, dynamic> json) {
  return PostFolder(
    json['idx'] as int,
    json['userIdx'] as int,
    json['name'] as String,
    json['categoryIdx'] as int,
    json['createdAt'] as String,
    json['updatedAt'] as String,
    json['status'] as String,
  );
}

Map<String, dynamic> _$PostFolderToJson(PostFolder instance) =>
    <String, dynamic>{
      'idx': instance.idx,
      'userIdx': instance.userIdx,
      'name': instance.name,
      'categoryIdx': instance.categoryIdx,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'status': instance.status,
    };
