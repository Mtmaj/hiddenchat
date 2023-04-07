import 'package:flutter/material.dart';
import 'package:hiddenchat/colors.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/groupController.dart';
import '../controllers/messageWController.dart';
import '../main.dart';
import '../models/groupModel.dart';
import '../models/messageModel.dart';
import './home_screen.dart';
import '../controllers/messageController.dart';
import 'package:uuid/uuid.dart';
import '../network/networkApp.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ChatScreen extends StatefulWidget {
  final Group group_info;
  const ChatScreen({super.key, required this.group_info});
  static bool is_scroll = false;
  static List<Message> messages = [];
  static TextEditingController message_input = new TextEditingController();
  static final controller = AutoScrollController();
  static String replay_id = '';
  static int item_index_replay = 0;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
  static void scrollendList(_) {
    ChatScreen.is_scroll = true;
    ChatScreen.controller.animateTo(
        ChatScreen.controller.position.minScrollExtent,
        duration: Duration(milliseconds: 1),
        curve: Curves.easeInOutBack);
  }
}

class _ChatScreenState extends State<ChatScreen> {
  void getMessageForGroup() {
    ChatScreen.messages.clear();
    HomeScreen.MessageList.forEach((element) async {
      if (element.to == widget.group_info.group_id) {
        ChatScreen.messages.add(element);
        int index = 0;
        Message? update_id;
        bool f = false;
        HomeScreen.MessageList.forEach((check_e) {
          if (check_e.id == element.id) {
            f = true;
            update_id = check_e;
          }
          if (!f) index++;
        });
        if (f) {
          update_id!.isSeen = true;
          await Hive.box<Message>('messageBox').putAt(index, update_id!);
          message_controller.updateData();
          var home_controller = Get.put(GroupController());
          home_controller.increment();
        }
      }
    });
  }

  var message_controller = Get.put(MessageController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: GetBuilder<MessageController>(builder: (context) {
      getMessageForGroup();
      return Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.black,
          child: Column(
            children: [
              AppBarWidget(),
              Container(
                width: double.infinity,
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 15),
                color: Color_theme.blue24,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: ListView.builder(
                    reverse: true,
                    controller: ChatScreen.controller,
                    itemCount: ChatScreen.messages.length,
                    itemBuilder: (context, index) {
                      Message data = ChatScreen
                          .messages[ChatScreen.messages.length - index - 1];
                      if (data.from != MyApp.username) {
                        if (data.replay != '') {
                          return AutoScrollTag(
                            key: ValueKey(index),
                            controller: ChatScreen.controller,
                            index: index,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 9,
                                ),
                                anotherReplayMessageItem(data, index),
                              ],
                            ),
                          );
                        } else {
                          return AutoScrollTag(
                            key: ValueKey(index),
                            controller: ChatScreen.controller,
                            index: index,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 9,
                                ),
                                anotherMessageItem(data, index),
                              ],
                            ),
                          );
                        }
                      } else {
                        if (data.replay != '') {
                          return AutoScrollTag(
                            key: ValueKey(index),
                            controller: ChatScreen.controller,
                            index: index,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 9,
                                ),
                                myReplayMessageItem(data, index),
                              ],
                            ),
                          );
                        } else {
                          return AutoScrollTag(
                            key: ValueKey(index),
                            controller: ChatScreen.controller,
                            index: index,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 9,
                                ),
                                myMessageItem(data, index),
                              ],
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
              ChatScreen.replay_id != ''
                  ? GestureDetector(
                      onTap: () {
                        ChatScreen.controller
                            .scrollToIndex(ChatScreen.item_index_replay);
                      },
                      child: Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: Row(
                          children: [
                            Icon(Icons.subdirectory_arrow_right_rounded,
                                color: Color_theme.blue),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              ((findMessage(ChatScreen.replay_id).from! ==
                                                      MyApp.username
                                                  ? 'Me : '
                                                  : findMessage(ChatScreen.replay_id)
                                                          .from! +
                                                      ' : ') +
                                              (findMessage(ChatScreen.replay_id)
                                                  .text!))
                                          .length <
                                      50
                                  ? ((findMessage(ChatScreen.replay_id).from! ==
                                              MyApp.username
                                          ? 'Me : '
                                          : findMessage(ChatScreen.replay_id).from! +
                                              ' : ') +
                                      (findMessage(ChatScreen.replay_id).text!))
                                  : ((findMessage(ChatScreen.replay_id).from! ==
                                                      MyApp.username
                                                  ? 'Me : '
                                                  : findMessage(ChatScreen.replay_id)
                                                          .from! +
                                                      ' : ') +
                                              (findMessage(ChatScreen.replay_id)
                                                  .text!))
                                          .substring(0, 48) +
                                      '...',
                              style: TextStyle(
                                color: Color.fromARGB(255, 201, 201, 201),
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                                child: Icon(Icons.close_rounded,
                                    color: Colors.white),
                                onTap: () {
                                  ChatScreen.replay_id = '';
                                  setState(() {});
                                })
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 22, 27, 29),
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  : SizedBox(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                constraints: BoxConstraints(maxHeight: 100),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      style: TextStyle(color: Colors.white),
                      maxLines: null,
                      controller: ChatScreen.message_input,
                      decoration: InputDecoration.collapsed(
                          hintText: 'Enter Your Message...',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(188, 255, 255, 255),
                          )),
                    )),
                    GestureDetector(
                      onTap: () async {
                        if (ChatScreen.message_input.text != '') {
                          var mybox = await Hive.box<Message>('messageBox');
                          var uuid = Uuid();
                          String msg_id = uuid.v1();
                          Message message_data = Message(
                              from: MyApp.username,
                              to: widget.group_info.group_id,
                              text: ChatScreen.message_input.text,
                              replay: ChatScreen.replay_id,
                              id: msg_id,
                              isSend: false,
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
                          mybox.add(message_data);
                          Network.send_message(Message.toJson(message_data));
                          ChatScreen.message_input.text = '';
                          ChatScreen.replay_id = '';
                          MyApp.load_message();
                          message_controller.updateData();
                          setState(() {});
                        }
                      },
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    color: Color(0xff333F44),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8))),
              )
            ],
          ),
        ),
      );
    }));
  }

  Padding AppBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
          SizedBox(width: 12),
          Text(
            widget.group_info.group_name!,
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          Spacer(),
          GestureDetector(
            child: Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  var controller = Get.put(messaewController());
  Row anotherReplayMessageItem(Message message_data, int index) {
    Message replay_data = ChatScreen.messages
        .firstWhere((element) => message_data.replay == element.id);
    int index_replay = 0;
    int i = 0;
    ChatScreen.messages.forEach((element) {
      if (element.id == message_data.replay) {
        index_replay = i;
      }
      i++;
    });
    index_replay = ChatScreen.messages.length - 1 - index_replay;
    return Row(
      children: [
        Expanded(
            child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () {
              ChatScreen.replay_id = message_data.id!;
              ChatScreen.item_index_replay = index;
              setState(() {});
              controller.increment();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      message_data.time!.split('T')[0] +
                          ' ' +
                          message_data.time!.split('T')[1].split('.')[0],
                      style: TextStyle(
                          color: Color.fromARGB(172, 255, 255, 255),
                          fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ChatScreen.controller.scrollToIndex(index_replay);
                        print(index_replay);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.symmetric(
                                vertical: BorderSide(
                                    color: Color_theme.blue, width: 1))),
                        margin: EdgeInsets.all(10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        child: Text(
                          replay_data.from == MyApp.username
                              ? 'Me : ' +
                                  (replay_data.text!.length < 25
                                      ? replay_data.text!
                                      : replay_data.text!.substring(0, 18) +
                                          '...')
                              : (replay_data.from! + ' : ' + replay_data.text!)
                                          .length <
                                      25
                                  ? (replay_data.from! +
                                      ' : ' +
                                      replay_data.text!)
                                  : (replay_data.from! +
                                              ' : ' +
                                              replay_data.text!)
                                          .substring(0, 20) +
                                      '...',
                          style: TextStyle(
                              color: Color.fromARGB(193, 177, 177, 177),
                              height: 1.2,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                      color: Color_theme.blue,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message_data.from! + ' : ' + message_data.text!,
                        style: TextStyle(color: Colors.white, height: 1.2),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )),
        SizedBox(
          width: Get.width / 2.8,
        )
      ],
    );
  }

  Row myReplayMessageItem(Message message_data, int index) {
    Message replay_data = ChatScreen.messages
        .firstWhere((element) => message_data.replay == element.id);
    int index_replay = 0;
    int i = 0;
    ChatScreen.messages.forEach((element) {
      if (element.id == message_data.replay) {
        index_replay = i;
      }
      i++;
    });
    index_replay = ChatScreen.messages.length - 1 - index_replay;
    return Row(
      children: [
        SizedBox(
          width: Get.width / 2.8,
        ),
        Expanded(
            child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onLongPress: () {
              ChatScreen.replay_id = message_data.id!;
              ChatScreen.item_index_replay = index;
              setState(() {});
              controller.increment();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message_data.time!.split('T')[0] +
                          ' ' +
                          message_data.time!.split('T')[1].split('.')[0],
                      style: TextStyle(
                          color: Color.fromARGB(172, 255, 255, 255),
                          fontSize: 12),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ChatScreen.controller.scrollToIndex(index_replay);
                        print(index_replay);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.symmetric(
                                vertical: BorderSide(
                                    color: Color_theme.blue, width: 1))),
                        margin: EdgeInsets.all(10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        child: Text(
                          replay_data.from == MyApp.username
                              ? 'Me : ' +
                                  (replay_data.text!.length < 25
                                      ? replay_data.text!
                                      : replay_data.text!.substring(0, 18) +
                                          '...')
                              : (replay_data.from! + ' : ' + replay_data.text!)
                                          .length <
                                      25
                                  ? (replay_data.from! +
                                      ' : ' +
                                      replay_data.text!)
                                  : (replay_data.from! +
                                              ' : ' +
                                              replay_data.text!)
                                          .substring(0, 20) +
                                      '...',
                          style: TextStyle(
                              color: Color.fromARGB(193, 177, 177, 177),
                              height: 1.2,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                      color: Color(0xff333F44),
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message_data.text!,
                        style: TextStyle(color: Colors.white, height: 1.2),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        message_data.isSend
                            ? Icons.check_rounded
                            : Icons.timer_outlined,
                        color: Colors.white,
                        size: 12),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Row myMessageItem(Message message_data, int index) {
    return Row(
      children: [
        SizedBox(
          width: Get.width / 2.8,
        ),
        Expanded(
            child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onLongPress: () {
              ChatScreen.replay_id = message_data.id!;
              ChatScreen.item_index_replay = index;
              setState(() {});
              controller.increment();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message_data.time!.split('T')[0] +
                          ' ' +
                          message_data.time!.split('T')[1].split('.')[0],
                      style: TextStyle(
                          color: Color.fromARGB(172, 255, 255, 255),
                          fontSize: 12),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                      color: Color(0xff333F44),
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    message_data.text!,
                    style: TextStyle(color: Colors.white, height: 1.2),
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      message_data.isSend
                          ? Icons.check_rounded
                          : Icons.timer_outlined,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Row anotherMessageItem(Message message_data, int index) {
    return Row(
      children: [
        Expanded(
            child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () {
              ChatScreen.replay_id = message_data.id!;
              ChatScreen.item_index_replay = index;
              setState(() {});
              controller.increment();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      message_data.time!.split('T')[0] +
                          ' ' +
                          message_data.time!.split('T')[1].split('.')[0],
                      style: TextStyle(
                          color: Color.fromARGB(172, 255, 255, 255),
                          fontSize: 12),
                    )
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                      color: Color_theme.blue,
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    message_data.from! + ' : ' + message_data.text!,
                    style: TextStyle(color: Colors.white, height: 1.2),
                  ),
                )
              ],
            ),
          ),
        )),
        SizedBox(
          width: Get.width / 2.8,
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getMessageForGroup();
    WidgetsBinding.instance.addPostFrameCallback(ChatScreen.scrollendList);
  }

  Message findMessage(String id) {
    return ChatScreen.messages.firstWhere((element) => element.id == id);
  }
}
