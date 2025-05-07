import 'package:json_annotation/json_annotation.dart';

part 'user_login_pojo.g.dart';

@JsonSerializable()
class UserLoginPojo {
  final int code;
  final String msg;
  final UserLoginDataPojo? data;

  UserLoginPojo({required this.code, required this.msg, required this.data});

  factory UserLoginPojo.fromJson(Map<String, dynamic> json) => _$UserLoginPojoFromJson(json);
  Map<String, dynamic> toJson() => _$UserLoginPojoToJson(this);

}

@JsonSerializable()
class UserLoginDataPojo {
  int userID;
  String token;

  UserLoginDataPojo({required this.userID, required this.token});

  factory UserLoginDataPojo.fromJson(Map<String, dynamic> json) => _$UserLoginDataPojoFromJson(json);
  Map<String, dynamic> toJson() => _$UserLoginDataPojoToJson(this);
}