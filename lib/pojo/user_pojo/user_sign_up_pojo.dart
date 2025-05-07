import 'package:json_annotation/json_annotation.dart';

part 'user_sign_up_pojo.g.dart';

@JsonSerializable()
class UserSignUpPojo {
  final int code;
  final String msg;
  final int data;

  UserSignUpPojo({required this.code, required this.msg, required this.data});

  factory UserSignUpPojo.fromJson(Map<String, dynamic> json) => _$UserSignUpPojoFromJson(json);
  Map<String, dynamic> toJson() => _$UserSignUpPojoToJson(this);
}
