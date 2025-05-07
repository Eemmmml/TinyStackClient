import 'package:json_annotation/json_annotation.dart';

part 'user_profile_update_response_pojo.g.dart';

@JsonSerializable()
class UserProfileUpdateResponsePojo {
  final int code;
  final String msg;
  final bool? data;

  UserProfileUpdateResponsePojo(
      {required this.code, required this.msg, required this.data});

  factory UserProfileUpdateResponsePojo.fromJson(Map<String, dynamic> json) =>
      _$UserProfileUpdateResponsePojoFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileUpdateResponsePojoToJson(this);
}
