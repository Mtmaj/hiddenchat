import 'package:flutter/material.dart';
import 'package:hiddenchat/colors.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:restart_app/restart_app.dart';

import '../models/user_login.dart';
import '../network/networkApp.dart';
import 'login_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});
  static TextEditingController username_controller =
      new TextEditingController();
  static TextEditingController fullname_controller =
      new TextEditingController();
  static TextEditingController password_controller =
      new TextEditingController();
  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign in Your Account',
              style: TextStyle(color: Colors.white, fontSize: 27),
            ),
            SizedBox(
              height: 35,
            ),
            text_fieldCustomized(SigninScreen.username_controller, 'Username',
                Icons.account_circle_rounded, false),
            SizedBox(
              height: 15,
            ),
            text_fieldCustomized(SigninScreen.fullname_controller, 'Full name',
                Icons.article_rounded, false),
            SizedBox(
              height: 15,
            ),
            text_fieldCustomized(SigninScreen.password_controller, 'Password',
                Icons.lock_rounded, true),
            SizedBox(
              height: 23,
            ),
            loginBtn(),
            SizedBox(
              height: 20,
            ),
            signinbtn()
          ],
        ),
      ),
    ));
  }

  Row signinbtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'You Have Account ? ',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        GestureDetector(
          onTap: () {
            Get.to(LoginScreen());
          },
          child: Container(
            child: Text('Login',
                style: TextStyle(color: Color_theme.blue24, fontSize: 18)),
          ),
        )
      ],
    );
  }

  GestureDetector loginBtn() {
    return GestureDetector(
      onTap: () async {
        String username = SigninScreen.username_controller.text;
        String password = SigninScreen.password_controller.text;
        String fullname = SigninScreen.fullname_controller.text;
        bool response = await Network.signin(username, password, fullname);
        print("ok");
        if (response == true) {
          Hive.box<UserData>('userdataBox')
              .add(UserData(username: username, password: password));
          Restart.restartApp();
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Text(
          'Submit',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color_theme.blue,
        ),
      ),
    );
  }

  Container text_fieldCustomized(TextEditingController controller, String hint,
      IconData icon, bool ispassword) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
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
                hintStyle: TextStyle(color: Colors.white54),
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
            color: Colors.white,
          )
        ],
      ),
    );
  }
}
