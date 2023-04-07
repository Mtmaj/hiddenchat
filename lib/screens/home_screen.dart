import 'package:flutter/material.dart';
import 'package:hiddenchat/colors.dart';
import 'package:get/get.dart';
import 'package:hiddenchat/controllers/groupController.dart';
import 'package:hiddenchat/screens/chat_screen.dart';
import '../controllers/messageController.dart';
import '../main.dart';
import '../models/messageModel.dart';
import '../models/groupModel.dart';
import './join_group.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static List<Message> MessageList = [];
  static List<Group> GroupList = [];
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    MyApp.load_data();
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(GroupController());
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Add_Group.group_id_input.text = '';
              Add_Group.join_group_password.text = '';
              Add_Group.new_group_password.text = '';
              Add_Group.group_name.text = '';
              Get.to(Add_Group());
            },
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
            ),
            backgroundColor: Color_theme.blue),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 26, vertical: 22),
          child: GetBuilder<GroupController>(builder: (context) {
            print(HomeScreen.GroupList);
            MyApp.sorted_group();
            return Column(
              children: [
                AppBar(),
                SizedBox(
                  height: 15,
                ),
                SearchInput(),
                SizedBox(
                  height: 15,
                ),
                groupsList()
              ],
            );
          }),
        ),
      ),
    );
  }

  Expanded groupsList() {
    return Expanded(
      child: Stack(
        children: [
          ListView.builder(
            itemCount: HomeScreen.GroupList.length,
            itemBuilder: (context, index) {
              int not_seen = HomeScreen.MessageList.where((element) =>
                  (element.to == HomeScreen.GroupList[index].group_id) &&
                  (element.isSeen == false)).length;

              return ItemGroup(
                data: HomeScreen.GroupList[index],
                message_not_seen: not_seen,
              );
            },
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Color.fromARGB(151, 0, 0, 0)
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
              ),
              Spacer(),
              Container(
                width: double.infinity,
                height: 30,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color.fromARGB(151, 0, 0, 0),
                  Color.fromARGB(0, 0, 0, 0)
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
              )
            ],
          )
        ],
      ),
    );
  }

  Container SearchInput() {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: Color.fromARGB(31, 255, 255, 255),
              cursorHeight: 18,
              decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.white70)),
            ),
          ),
          Icon(
            Icons.search_rounded,
            color: Colors.white,
            size: 18,
          )
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Color_theme.blue, width: 0.8),
          borderRadius: BorderRadius.circular(100)),
    );
  }

  Row AppBar() {
    return Row(
      children: [
        Text(
          'Hidden Chat',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        Spacer(),
        GestureDetector(
          child: Icon(
            Icons.more_vert_rounded,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}

class ItemGroup extends StatelessWidget {
  final Group data;
  final int message_not_seen;
  const ItemGroup(
      {Key? key, required this.data, required this.message_not_seen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeScreen.GroupList.forEach((element) {
      print(element);
    });
    return GestureDetector(
        onTap: () {
          ChatScreen.message_input.text = '';
          ChatScreen.replay_id = '';
          Get.to(ChatScreen(group_info: data));
        },
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Text(
                data.group_name!,
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "ID : " + data.group_id.toString(),
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              Spacer(),
              Text(
                message_not_seen != 0 ? message_not_seen.toString() : '',
                style: TextStyle(fontSize: 13, color: Colors.red),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
          decoration: BoxDecoration(
              border: Border.all(color: Color_theme.blue, width: 1.5),
              borderRadius: BorderRadius.circular(8)),
        ));
  }
}
