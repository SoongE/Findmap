import 'package:json_annotation/json_annotation.dart';

part 'post_folder.g.dart';

@JsonSerializable()
class PostFolder {
  int idx;
  int userIdx;
  String name;
  int categoryIdx;
  String createdAt;
  String updatedAt;
  String status;

  PostFolder(this.idx, this.userIdx, this.name, this.categoryIdx, this.createdAt,
      this.updatedAt, this.status);

  factory PostFolder.fromJson(Map<String, dynamic> json) => _$PostFolderFromJson(json);

  Map<String, dynamic> toJson() => _$PostFolderToJson(this);
}
