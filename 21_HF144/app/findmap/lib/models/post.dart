import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  int idx;
  String title;
  String contentUrl;
  String thumbnailUrl;
  String summary;
  String comment;
  int categoryIdx;
  int folderIdx;
  String isFeed;

  Post(this.idx, this.title, this.contentUrl, this.thumbnailUrl, this.summary,
      this.comment, this.categoryIdx, this.folderIdx, this.isFeed);

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}
