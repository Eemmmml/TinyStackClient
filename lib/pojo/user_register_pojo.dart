import 'package:json_annotation/json_annotation.dart';

part 'user_register_pojo.g.dart';

@JsonSerializable()
class UserRegisterPojo {
  String username;
  String password;

  UserRegisterPojo({
    required this.username,
    required this.password,
  });

  factory UserRegisterPojo.fromJson(Map<String, dynamic> json) => _$UserRegisterPojoFromJson(json);

  Map<String, dynamic> toJson() => _$UserRegisterPojoToJson(this);
}
