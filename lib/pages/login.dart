import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'check_in_out.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _Login createState() => _Login();
}

String username = "";
String password = "";

class _Login extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  String _tips = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text('用户名：'),
                Expanded(
                  child: TextField(
                    controller: _username,
                    decoration: const InputDecoration(hintText: '请输入用户名'
                        // labelText: '用户名',
                        ),
                    // onChanged: (value) {
                    //   _username.text = value;
                    // },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('密   码：'),
                Expanded(
                    child: TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: '请输入密码'),
                  // onChanged: (value) {
                  //   _password.text = value;
                  // },
                )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    child: const Text("登录"),
                    onPressed: _login)
              ],
            ),
            Text(_tips)
          ],
        ),
      ),
    );
  }
  _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    var password = prefs.getString("password");
    if (username != null && password != null) {
      await User().login(username, password);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const FormRoute()));
    }
  }
  _login() async {
    User user = User();
    await user.login(_username.text, _password.text);
    Map<String, dynamic> result = json.decode(user.getResponseData());
    String tips = "";
    if (result["msgcode"].toString() == "0") {
      tips = "登录成功，即将跳转页面";
      Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const FormRoute()),(route) => route == null);
    } else {
      tips = "用户名或密码错误";
    }
    setState(() {
      _tips = tips;
    });
  }
}

class User {
  String responseData = "";
  getResponseData() {
    print('skfjsdk'+responseData);
    return responseData;
  }
  login(String username, String pwd) async {
    if (username != "" && pwd != "") {
      var postData = {};
      postData["islanguid"] = "7";
      postData["loginid"] = username;
      postData["userpassword"] = pwd;
      postData["dynamicPassword"] = "";
      postData["tokenAuthKey"] = "";
      postData["validatecode"] = "";
      postData["validateCodeKey"] = "";
      postData["logintype"] = "1";
      postData["messages"] = "";
      postData["isie"] = "false";

      BaseOptions options = BaseOptions();
      options.headers["Accept"] = "*/*";
      options.headers["X-Requested-With"] = "XMLHttpRequest";
      options.headers["Content-Type"] =
      "application/x-www-form-urlencoded; charset=utf-8";
      options.headers["Origin"] = oaBaseURL;
      options.headers["Referer"] = oaMainURL;
      options.headers["User-Agent"] = defaultUserAgent;
      List<Cookie> cookies =
      await Api.cookieJar.loadForRequest(Uri.parse(oaLoginURL));
      Dio dio = Dio(options);
      dio.interceptors.add(CookieManager(Api.cookieJar));
      Response response = await dio.post(oaLoginURL, data: postData);
      print('Response status:${response.statusCode}');
      print('Response data:${response.data}');
      //Save cookies
      Api.cookieJar.saveFromResponse(Uri.parse(oaLoginURL), cookies);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("username",username);
      prefs.setString("password", pwd);
      responseData = response.data;
      print('skfdjksdfkd'+responseData);
    }
  }
}
