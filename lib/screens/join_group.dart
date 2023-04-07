import 'package:flutter/material.dart';
import 'package:hiddenchat/controllers/groupController.dart';
import 'package:hiddenchat/network/networkApp.dart';
import 'package:hiddenchat/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../colors.dart';
import 'package:get/get.dart';

import '../controllers/messageController.dart';
import '../main.dart';
import '../models/messageModel.dart';
import 'chat_screen.dart';

class Add_Group extends StatefulWidget {
  const Add_Group({super.key});
  static TextEditingController group_id_input = new TextEditingController();
  static TextEditingController join_group_password =
      new TextEditingController();
  static TextEditingController group_name = new TextEditingController();
  static TextEditingController new_group_password = new TextEditingController();
  static int res_group_id = 0;
  @override
  State<Add_Group> createState() => _Add_GroupState();
}

class _Add_GroupState extends State<Add_Group> {
  @override
  Widget build(BuildContext context) {
    var message_controller = Get.put(MessageController());
    var group_controller = Get.put(GroupController());
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            children: [
              AppBarWidget(),
              SizedBox(
                height: 15,
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Color_theme.blue24,
              ),
              SizedBox(
                height: 15,
              ),
              text_fieldCustomized(Add_Group.group_id_input, 'Enter Group ID',
                  Icons.group_rounded, false),
              SizedBox(
                height: 15,
              ),
              text_fieldCustomized(Add_Group.join_group_password,
                  'Enter Group Password', Icons.password_rounded, true),
              SizedBox(
                height: 15,
              ),
              btn_custome_groupscreen('Join Group', () async {
                try {
                  await Network.join_group(
                      int.parse(Add_Group.group_id_input.text),
                      Add_Group.join_group_password.text);
                  await Network.get_all_message();
                  message_controller.updateData();
                  group_controller.increment();
                  setState(() {});
                } catch (e) {
                  print(e);
                }
              }),
              SizedBox(
                height: 15,
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Create Group',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              text_fieldCustomized(Add_Group.group_name, 'Enter Group Name',
                  Icons.group_rounded, false),
              SizedBox(
                height: 15,
              ),
              text_fieldCustomized(Add_Group.new_group_password,
                  'Enter Group Password', Icons.password_rounded, true),
              SizedBox(
                height: 15,
              ),
              btn_custome_groupscreen('Submit', () async {
                int group_id = await Network.new_group(
                    Add_Group.group_name.text,
                    Add_Group.new_group_password.text);
                Add_Group.res_group_id = group_id;
                var mybox = await Hive.box<Message>('messageBox');
                var uuid = Uuid();
                String msg_id = uuid.v1();
                Message message_data = Message(
                    from: MyApp.username,
                    to: group_id,
                    text: MyApp.username + ' Created the Group',
                    replay: '',
                    id: msg_id,
                    isSend: false,
                    isSeen: true);
                mybox.add(message_data);
                await Network.send_message(Message.toJson(message_data));
                Network.getGroups();
                message_controller.updateData();
                setState(() {});
              }),
              Add_Group.res_group_id != 0
                  ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Your Group ID : ',
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            Add_Group.res_group_id.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        ],
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector btn_custome_groupscreen(String text, Function ontap) {
    return GestureDetector(
      onTap: () {
        ontap();
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        decoration: BoxDecoration(
          color: Color_theme.blue,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Row AppBarWidget() {
    return Row(
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
        SizedBox(
          width: 12,
        ),
        Text('Join Group', style: TextStyle(color: Colors.white, fontSize: 25))
      ],
    );
  }

  Container text_fieldCustomized(TextEditingController controller, String hint,
      IconData icon, bool ispassword) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: 18, color: Colors.white),
              obscureText: ispassword,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Color_theme.blue24),
                isCollapsed: true,
                border: InputBorder.none,
                errorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
          Icon(
            icon,
            color: Color_theme.blue24,
          )
        ],
      ),
    );
  }
}
