part of 'post.dart';

Post _$PostFromJson(Map<String, dynamic> json) {
  return Post(
    json['idx'] as int,
    json['title'] as String,
    json['contentUrl'] as String,
    json['thumbnailUrl'] as String,
    json['summary'] as String,
    json['comment'] as String,
    json['categoryIdx'] as int,
    json['folderIdx'] as int,
    json['isFeed'] as String,
  );
}

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'idx': instance.idx,
      'title': instance.title,
      'contentUrl': instance.contentUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'summary': instance.summary,
      'comment': instance.comment,
      'categoryIdx': instance.categoryIdx,
      'folderIdx': instance.folderIdx,
      'isFeed': instance.isFeed,
    };
