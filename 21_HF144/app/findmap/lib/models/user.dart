import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int userIdx;
  String accessToken;
  String name;
  String email;
  String password;
  String nickName;
  String birthday;
  String gender;
  String phoneNum;
  String taste;
  String profileUrl;

  User(this.userIdx, this.accessToken, this.name, this.email, this.password, this.nickName,
      this.birthday, this.gender, this.phoneNum, this.taste, this.profileUrl);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
