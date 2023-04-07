import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hiddenchat/colors.dart';
import 'package:hiddenchat/models/user_login.dart';
import 'package:hiddenchat/screens/signin_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/networkApp.dart';
import 'package:restart_app/restart_app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static TextEditingController username_controller =
      new TextEditingController();
  static TextEditingController password_controller =
      new TextEditingController();
  static String validText = '';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
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
              'Login Your Account',
              style: TextStyle(color: Colors.white, fontSize: 27),
            ),
            SizedBox(
              height: 35,
            ),
            text_fieldCustomized(LoginScreen.username_controller, 'Username',
                Icons.account_circle_rounded, false),
            SizedBox(
              height: 15,
            ),
            text_fieldCustomized(LoginScreen.password_controller, 'Password',
                Icons.lock_rounded, true),
            SizedBox(
              height: LoginScreen.validText == '' ? 0 : 15,
            ),
            Text(
              LoginScreen.validText,
              style: TextStyle(color: Colors.red, fontSize: 17),
            ),
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
          'Dont Have Account ? ',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        GestureDetector(
          onTap: () {
            Get.to(SigninScreen());
          },
          child: Text('Sign in',
              style: TextStyle(color: Color_theme.blue24, fontSize: 18)),
        )
      ],
    );
  }

  GestureDetector loginBtn() {
    return GestureDetector(
      onTap: () async {
        String username = LoginScreen.username_controller.text;
        String password = LoginScreen.password_controller.text;
        var response = await Network.login(username, password);
        if (response['vu'] == false) {
          LoginScreen.validText = 'Username Not Found';
          setState(() {});
        } else if (response['vp'] == false) {
          LoginScreen.validText = 'The Entered Password Is Incorrect';
          setState(() {});
        } else {
          LoginScreen.validText = '';
          setState(() {});
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
          'Login',
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
