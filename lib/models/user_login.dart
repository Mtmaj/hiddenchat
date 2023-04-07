import 'package:hive/hive.dart';

part 'user_login.g.dart';

@HiveType(typeId: 2)
class UserData {
  @HiveField(0)
  String? username;
  @HiveField(1)
  String? password;
  UserData({required this.username, required this.password});
}
