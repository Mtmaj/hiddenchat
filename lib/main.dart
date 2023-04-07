import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hiddenchat/network/networkApp.dart';
import 'package:hiddenchat/screens/login_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './models/messageModel.dart';
import './screens/home_screen.dart';
import 'models/groupModel.dart';
import 'models/user_login.dart';

void main() async {
  // DB Register
  await Hive.initFlutter();
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(GroupAdapter());
  Hive.registerAdapter(UserDataAdapter());
  await Hive.openBox<Message>('messageBox');
  await Hive.openBox<Group>('groupBox');
  await Hive.openBox<UserData>('userdataBox');
  // load Data
  HomeScreen.MessageList.clear();
  HomeScreen.GroupList.clear();
  await MyApp.load_data();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static String username = '';
  @override
  State<MyApp> createState() => _MyAppState();

  static Future<void> load_data() async {
    HomeScreen.MessageList.clear();
    HomeScreen.GroupList.clear();
    var message = await Hive.box<Message>('messageBox').values;
    var groups = await Hive.box<Group>('groupBox').values;
    var user_data = await Hive.box<UserData>('userdataBox').values;
    MyApp.username = user_data.isEmpty ? '' : user_data.elementAt(0).username!;
    message.forEach((element) {
      HomeScreen.MessageList.add(element);
    });
    groups.forEach((element) {
      HomeScreen.GroupList.add(element);
    });
    sorted_group();
  }

  static Future<void> sorted_group() async {
    for (int i = 0; i < HomeScreen.MessageList.length; i++) {
      if (HomeScreen.MessageList[i].time == null) {
        Message? new_data = await Hive.box<Message>('messageBox').getAt(i);
        new_data!.time = MyApp.set_time();
        await Hive.box<Message>('messageBox').putAt(i, new_data);
      }
    }
    for (int i = 0; i < HomeScreen.GroupList.length; i++) {
      for (int j = 0; j < HomeScreen.GroupList.length - 1; j++) {
        var dates = HomeScreen.MessageList.lastWhere(
          (element) => element.to == HomeScreen.GroupList[j].group_id,
          orElse: () {
            return Message(
                from: MyApp.username,
                to: 0,
                text: '',
                replay: '',
                id: '',
                isSend: true,
                isSeen: true,
                time: DateTime.now().year.toString() +
                    '-' +
                    (DateTime.now().month.toString().length < 2
                        ? ('0' + DateTime.now().month.toString())
                        : DateTime.now().month.toString()) +
                    '-' +
                    (DateTime.now().day.toString().length < 2
                        ? ('0' + DateTime.now().day.toString())
                        : DateTime.now().day.toString()) +
                    'T' +
                    (DateTime.now().hour.toString().length < 2
                        ? ('0' + DateTime.now().hour.toString())
                        : DateTime.now().hour.toString()) +
                    ':' +
                    (DateTime.now().minute.toString().length < 2
                        ? '0' + DateTime.now().minute.toString()
                        : DateTime.now().minute.toString()) +
                    ':' +
                    (DateTime.now().second.toString().length < 2
                        ? '0' + DateTime.now().second.toString()
                        : DateTime.now().second.toString()));
          },
        ).time;
        var dates2 = HomeScreen.MessageList.lastWhere(
          (element) => element.to == HomeScreen.GroupList[j + 1].group_id,
          orElse: () {
            return Message(
                from: MyApp.username,
                to: 0,
                text: '',
                replay: '',
                id: '',
                isSend: true,
                isSeen: true,
                time: DateTime.now().year.toString() +
                    '-' +
                    (DateTime.now().month.toString().length < 2
                        ? ('0' + DateTime.now().month.toString())
                        : DateTime.now().month.toString()) +
                    '-' +
                    (DateTime.now().day.toString().length < 2
                        ? ('0' + DateTime.now().day.toString())
                        : DateTime.now().day.toString()) +
                    'T' +
                    (DateTime.now().hour.toString().length < 2
                        ? ('0' + DateTime.now().hour.toString())
                        : DateTime.now().hour.toString()) +
                    ':' +
                    (DateTime.now().minute.toString().length < 2
                        ? '0' + DateTime.now().minute.toString()
                        : DateTime.now().minute.toString()) +
                    ':' +
                    (DateTime.now().second.toString().length < 2
                        ? '0' + DateTime.now().second.toString()
                        : DateTime.now().second.toString()));
          },
        ).time;
        if (dates == null) {
          dates = MyApp.set_time();
        }
        if (dates2 == null) {
          dates2 == MyApp.set_time();
        }
        dates = dates.split('T')[0] + ' ' + dates.split('T')[1].split('.')[0];
        dates2 =
            dates2!.split('T')[0] + ' ' + dates2.split('T')[1].split('.')[0];

        DateTime date1 = DateTime.parse(dates);
        DateTime date2 = DateTime.parse(dates2);
        if (date1.compareTo(date2) < 0) {
          Group temp = HomeScreen.GroupList[j];
          HomeScreen.GroupList[j] = HomeScreen.GroupList[j + 1];
          HomeScreen.GroupList[j + 1] = temp;
        }
      }
    }
  }

  static String set_time() {
    return DateTime.now().year.toString() +
        '-' +
        (DateTime.now().month.toString().length < 2
            ? ('0' + DateTime.now().month.toString())
            : DateTime.now().month.toString()) +
        '-' +
        (DateTime.now().day.toString().length < 2
            ? ('0' + DateTime.now().day.toString())
            : DateTime.now().day.toString()) +
        'T' +
        (DateTime.now().hour.toString().length < 2
            ? ('0' + DateTime.now().hour.toString())
            : DateTime.now().hour.toString()) +
        ':' +
        (DateTime.now().minute.toString().length < 2
            ? '0' + DateTime.now().minute.toString()
            : DateTime.now().minute.toString()) +
        ':' +
        (DateTime.now().second.toString().length < 2
            ? '0' + DateTime.now().second.toString()
            : DateTime.now().second.toString());
  }

  static Future<void> load_message() async {
    HomeScreen.MessageList.clear();
    var message = await Hive.box<Message>('messageBox').values;
    message.forEach((element) {
      HomeScreen.MessageList.add(element);
    });
    sorted_group();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    if (MyApp.username != '') {
      Network.connectSocket();
      Network.getGroups();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp.username != '' ? HomeScreen() : LoginScreen(),
      ),
    );
  }
}
