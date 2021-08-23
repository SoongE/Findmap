import 'package:json_annotation/json_annotation.dart';

part 'userInfo.g.dart';

@JsonSerializable()
class UserInfo {
  int idx;
  String profileUrl;
  String nickName;
  String description;
  int ScrapCount;
  int FollowCount;
  int HaertCount;

  UserInfo(this.idx, this.profileUrl, this.nickName, this.description,
      this.ScrapCount, this.FollowCount, this.HaertCount);

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
