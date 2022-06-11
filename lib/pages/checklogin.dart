import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'check_in_out.dart';
import 'login.dart';
import 'dart:async';
class CheckLoginPage extends StatefulWidget {
  const CheckLoginPage({Key? key}) : super(key: key);

  @override
  _CheckLogin createState() => _CheckLogin();
}

class _CheckLogin extends State<CheckLoginPage> {
  @override
  initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1),(){
      _checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      appBar: AppBar(
        title:  const Text('欢迎'),
      ),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('欢迎来到偷懒摸鱼打卡APP',style: TextStyle(fontSize: 25),),
            ],
          )
        ],
      )
    );
  }

  _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    var password = prefs.getString("password");


    if (username != null && password != null) {
      await User().login(username, password);
      Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const FormRoute()),(route) => route == null);
    } else {
      Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()),(route) => route == null);
    }

  }
}
