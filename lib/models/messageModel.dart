import 'package:hive/hive.dart';

import '../main.dart';

part 'messageModel.g.dart';

@HiveType(typeId: 0)
class Message {
  @HiveField(0)
  String? from;
  @HiveField(1)
  int? to;
  @HiveField(2)
  String? text;
  @HiveField(3)
  String? replay;
  @HiveField(4)
  String? time;
  @HiveField(5)
  String? id;
  @HiveField(6)
  bool isSend;
  @HiveField(7)
  bool isSeen;
  Message(
      {required this.from,
      required this.to,
      required this.text,
      required this.replay,
      required this.id,
      required this.isSend,
      required this.isSeen,
      this.time});
  static Map<String, dynamic> toJson(Message data) {
    return <String, dynamic>{
      'from': data.from,
      'to': data.to,
      'text': data.text,
      'replay': data.replay,
      'id': data.id
    };
  }

  static Message toMessage(Map<String, dynamic> data) {
    return Message(
        from: data['from'],
        to: data['to'],
        text: data['text'],
        replay: data['replay'],
        id: data['id'],
        isSend: true,
        isSeen: data['from'] == MyApp.username,
        time: data['time']);
  }
}
