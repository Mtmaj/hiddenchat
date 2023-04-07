import 'dart:convert';
import 'package:get/get.dart';
import 'package:hiddenchat/main.dart';
import 'package:hiddenchat/models/messageModel.dart';
import 'package:hiddenchat/screens/chat_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/groupModel.dart';
import '../screens/home_screen.dart';
import '../controllers/groupController.dart';
import 'package:http/http.dart' as http;
import '../controllers/messageController.dart';

class Network {
  static String url = 'hiddenchat.iran.liara.run';
  static IO.Socket server =
      IO.io('https://' + Network.url + '/socket', <String, dynamic>{
    'transports': ['websocket'],
    'query': 'username=' + MyApp.username
  });
  static void connectSocket() {
    Network.server.on('getallmassage', (msg) async {
      var mybox = await Hive.box<Message>('messageBox');
      var messageList = mybox.values;
      msg.forEach((message) {
        if (messageList
            .where((element) => element.id == Message.toMessage(message).id)
            .isEmpty) {
          mybox.add(Message.toMessage(message));
        } else {
          int index = 0;
          Message? update_id;
          bool f = false;
          messageList.forEach((element) {
            if (element.id == Message.toMessage(message).id) {
              f = true;
              update_id = element;
            }
            if (!f) index++;
          });
          if (f) {
            update_id!.isSend = true;
            mybox.putAt(index, update_id!);
          }
        }
      });
      var message = await Hive.box<Message>('messageBox').values;
      HomeScreen.MessageList.clear();
      message.forEach((element) {
        HomeScreen.MessageList.add(element);
      });
    });
    Network.server.on('massage', (msg) async {
      print(msg);
      var mybox = await Hive.box<Message>('messageBox');
      var messages = mybox.values;
      int index = 0;
      bool is_last_add = false;
      messages.forEach((element) {
        if (msg['id'] == element.id) {
          mybox.putAt(index, Message.toMessage(msg));
          is_last_add = true;
        }
        index++;
      });
      if (!is_last_add) {
        mybox.add(Message.toMessage(msg));
      }
      var controller = Get.put(MessageController());
      await MyApp.load_message();
      await MyApp.sorted_group();
      controller.updateData();
      var home_controller = Get.put(GroupController());
      home_controller.increment();
      ChatScreen.scrollendList(0);
    });
  }

  static Future<void> send_message(var message) async {
    Network.server.emit('massage', message);
  }

  static Future<void> getGroups() async {
    http
        .post(Uri.parse('https://' +
            Network.url +
            '/getgroups/?username=' +
            MyApp.username))
        .then((response) async {
      print(response.body);
      var groupsGets = json.decode(response.body);
      await Hive.box<Group>('groupBox').clear();
      for (int i = 0; i < groupsGets.length; i++) {
        var dataForSave = Group.fromJson(groupsGets[i]);
        await Hive.box<Group>('groupBox').add(dataForSave);
      }
      ;
      var groups = await Hive.box<Group>('groupBox').values;
      HomeScreen.GroupList.clear();
      groups.forEach((element) {
        HomeScreen.GroupList.add(element);
      });
      var controller = Get.put(MessageController());
      var home_controller = Get.put(GroupController());
      controller.updateData();
      home_controller.increment();
    });
  }

  static Future<dynamic> login(String username, String password) async {
    var response = await http.post(
      Uri.parse('https://' + url + '/getuser/?username=' + username),
    );
    var data = jsonDecode(response.body);
    if (data == null) {
      return {'vu': false, 'vp': false};
    } else if (data['password'] != password) {
      return {'vu': true, 'vp': false};
    }
    return {'vu': true, 'vp': true};
  }

  static Future<bool> signin(
      String username, String password, String fullname) async {
    var response = await http.post(
      Uri.parse('https://' +
          url +
          '/newuser/?username=' +
          username +
          '&fullname=' +
          fullname +
          '&password=' +
          password),
    );
    if (jsonDecode(response.body) == null) {
      return false;
    } else if (jsonDecode(response.body)['status'] == true) {
      return true;
    }
    return false;
  }

  static Future<void> join_group(int id, String password) async {
    print(id.toString() + ' ' + password);
    var r = await http.post(Uri.parse('https://' + Network.url + '/joingroup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            {'username': MyApp.username, 'GroupId': id, 'password': password}));
    print(r.body);
    await Network.getGroups();
  }

  static Future<int> new_group(String name, String password) async {
    var response = await http.post(
        Uri.parse('https://' + Network.url + '/newgroup'),
        body: json.encode({'name': name, 'password': password}),
        headers: {'Content-Type': 'application/json'});
    return json.decode(response.body)['groupid'];
  }

  static Future<void> get_all_message() async {
    var response = await http.post(Uri.parse('https://' +
        Network.url +
        '/getallmessage?username=' +
        MyApp.username));
    var messages = json.decode(response.body);
    print(messages);
    var last_massage = await Hive.box<Message>('messageBox').values;
    for (int i = 0; i < messages.length; i++) {
      if (last_massage
          .where((element) => element.id == messages[i]['id'])
          .isEmpty) {
        await Hive.box<Message>('messageBox')
            .add(Message.toMessage(messages[i]));
      }
    }
  }
}
