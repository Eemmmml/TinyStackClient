import 'package:json_annotation/json_annotation.dart';

part 'user_profile_page_for_others.g.dart';

@JsonSerializable()
class UserProfilePageForOthers {
  final int code;
  final String msg;
  final Map<String, dynamic> data;

  UserProfilePageForOthers({required this.code, required this.msg, required this.data});

  factory UserProfilePageForOthers.fromJson(Map<String, dynamic> json) => _$UserProfilePageForOthersFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfilePageForOthersToJson(this);
}