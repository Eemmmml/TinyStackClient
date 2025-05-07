import 'package:json_annotation/json_annotation.dart';
import 'package:tinystack/entity/user_basic_info.dart';

part 'user_profile_info_pojo.g.dart';

@JsonSerializable()
class UserProfileInfoPojo {
  final int code;
  final String msg;
  final UserBasicInfo? data;

  UserProfileInfoPojo({required this.code, required this.msg, required this.data});

  factory UserProfileInfoPojo.fromJson(Map<String, dynamic> json) => _$UserProfileInfoPojoFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileInfoPojoToJson(this);
}