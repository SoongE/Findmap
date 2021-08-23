import 'package:json_annotation/json_annotation.dart';

part 'feed.g.dart';

@JsonSerializable()
class Feed {
  int scrapIdx;
  int userIdx;
  String userNickName;
  String userProfile;
  String title;
  String contentUrl;
  String thumbnailUrl;
  String summary;
  String comment;
  String createdDate;
  String createdTerm;
  int scrapLikeCount;
  int scrapStorageCount;
  String scrapHistoryCount;
  String userLikeStatus;
  String userHistoryStatus;
  String userStorageStatus;

  Feed(
      this.scrapIdx,
      this.userIdx,
      this.userNickName,
      this.userProfile,
      this.title,
      this.contentUrl,
      this.thumbnailUrl,
      this.summary,
      this.comment,
      this.createdDate,
      this.createdTerm,
      this.scrapLikeCount,
      this.scrapStorageCount,
      this.scrapHistoryCount,
      this.userLikeStatus,
      this.userHistoryStatus,
      this.userStorageStatus);

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);

  Map<String, dynamic> toJson() => _$FeedToJson(this);
}
