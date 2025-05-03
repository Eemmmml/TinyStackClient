import 'package:json_annotation/json_annotation.dart';

part 'user_login_pojo.g.dart';

@JsonSerializable()
class UserLoginPojo {
  final int code;
  final String msg;
  final String data;

  UserLoginPojo({required this.code, required this.msg, required this.data});

  factory UserLoginPojo.fromJson(Map<String, dynamic> json) => _$UserLoginPojoFromJson(json);
  Map<String, dynamic> toJson() => _$UserLoginPojoToJson(this);
}