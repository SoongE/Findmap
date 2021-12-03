// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feed _$FeedFromJson(Map<String, dynamic> json) {
  return Feed(
    json['scrapIdx'] as int,
    json['userIdx'] as int,
    json['userNickName'] as String,
    json['userProfile'] as String,
    json['title'] as String,
    json['contentUrl'] as String,
    json['thumbnailUrl'] as String,
    json['summary'] as String,
    json['comment'] as String,
    json['createdDate'] as String,
    json['createdTerm'] as String,
    json['scrapLikeCount'] as int,
    json['scrapStorageCount'] as int,
    json['scrapHistoryCount'] as String,
    json['userLikeStatus'] as String,
    json['userHistoryStatus'] as String,
    json['userStorageStatus'] as String,
  );
}

Map<String, dynamic> _$FeedToJson(Feed instance) => <String, dynamic>{
      'scrapIdx': instance.scrapIdx,
      'userIdx': instance.userIdx,
      'userNickName': instance.userNickName,
      'userProfile': instance.userProfile,
      'title': instance.title,
      'contentUrl': instance.contentUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'summary': instance.summary,
      'comment': instance.comment,
      'createdDate': instance.createdDate,
      'createdTerm': instance.createdTerm,
      'scrapLikeCount': instance.scrapLikeCount,
      'scrapStorageCount': instance.scrapStorageCount,
      'scrapHistoryCount': instance.scrapHistoryCount,
      'userLikeStatus': instance.userLikeStatus,
      'userHistoryStatus': instance.userHistoryStatus,
      'userStorageStatus': instance.userStorageStatus,
    };
