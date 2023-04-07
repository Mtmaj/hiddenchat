import 'package:hive/hive.dart';

part 'groupModel.g.dart';

@HiveType(typeId: 1)
class Group {
  @HiveField(0)
  String? group_name;
  @HiveField(1)
  int? group_id;
  @HiveField(2)
  String? group_password;
  @HiveField(3)
  List? group_users;
  Group(
      {required this.group_name,
      required this.group_id,
      required this.group_password,
      required this.group_users});

  static Group fromJson(Map<String, dynamic> data) {
    return Group(
        group_name: data['groupname'],
        group_id: data['groupid'],
        group_password: data['grouppassword'],
        group_users: data['users']);
  }
}
