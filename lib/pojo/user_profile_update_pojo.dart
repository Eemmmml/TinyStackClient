import 'package:json_annotation/json_annotation.dart';

part 'user_profile_update_pojo.g.dart';

@JsonSerializable()
class UserProfileUpdatePojo {
  final int userID;
  final String? username;
  final String? avatarImageUrl;
  final String? description;
  final int? interests;
  final int? compositions;
  final int? fans;

  UserProfileUpdatePojo({
    required this.userID,
    this.username,
    this.avatarImageUrl,
    this.description,
    this.interests,
    this.compositions,
    this.fans,
  });

  factory UserProfileUpdatePojo.fromJson(Map<String, dynamic> json) => _$UserProfileUpdatePojoFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileUpdatePojoToJson(this);
}
