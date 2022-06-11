import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:date_format/date_format.dart' as d;
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled1/pages/login.dart';
import 'dart:convert' as convert;

var oaBaseURL = "https://oa.bangcle.com";
var oaMainURL = "https://oa.bangcle.com/wui/index.html";
var defaultUserAgent =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.96 Safari/537.36 Edg/88.0.705.56";
var oaLoginURL = "https://oa.bangcle.com/api/hrm/login/checkLogin";

class Api {
  static final CookieJar cookieJar = CookieJar();
}

class FormRoute extends StatefulWidget {
  const FormRoute({Key? key}) : super(key: key);

  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<FormRoute> {
  String forData = "";
  var nowStr = getNow();
  // var nowStr = "";
  // print(now);
  @override
  initState() {
    super.initState();
    const timeout = Duration(seconds: 1);
    Timer.periodic(timeout, (timer) { //callback function
      setState(() {
        nowStr = getNow();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('签到签退'),
          // leading: BackButton(
          //   onPressed: (){
          //     Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()),(route) => route == null);
          //
          //   },
          // )
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(flex: 15),
              Text('当前时间为：'+nowStr,style: TextStyle(fontSize: 20),),
              Spacer(flex: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text(
                      "签到",
                      style: TextStyle(fontSize: 40),
                    ),
                    onPressed: _checkIn,
                    style: ButtonStyle(
                        minimumSize:
                            MaterialStateProperty.all(const Size(150, 150)),
                        shape: MaterialStateProperty.all(const CircleBorder())),
                  ),
                ],
              ),
              Spacer(flex: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text(
                      "签退",
                      style: TextStyle(fontSize: 40),
                    ),
                    onPressed: _checkOut,
                    style: ButtonStyle(
                        minimumSize:
                            MaterialStateProperty.all(const Size(150, 150)),
                        shape: MaterialStateProperty.all(const CircleBorder())),
                  )
                ],
              ),
              Spacer(flex: 5),
              Text(forData),
              Spacer(flex: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                      child: const Text("切换账号登录"),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (route) => route == null);
                      })
                ],
              ),
              Spacer(flex: 20),
            ]));
  }

  _checkIn() async {
    var address = await getRandAddress();
    print(address);
    // Response result = await checkLogin();
    // print(result);
    // http.Response res = await checkLogin();
    // print("dskfdjskf:${res.body}");
    var map = {};
    var now = DateTime.now();
    print(now);
    var formatter = d.formatDate(now, ['yyyy', '-', 'mm', '-', 'dd']);
    print(formatter);
    map["date"] = formatter;
    map["belongtime"] = "09:00";
    map["type"] = "on";
    map["canSignTime"] = "05:00";
    map["across"] = "0";
    map["belongdate"] = formatter;
    map["datetime"] = formatter + " 09:00:00";
    map["min"] = "480";
    map["isfirstsign"] = "1";
    map["signSectionTime"] = formatter + " 05:00:00";
    map["signSectionBeginTime"] = "";
    map["isYellow"] = "1";
    map["isPunchOpen"] = "1";
    map["isacross"] = "0";
    map["pre"] = "0";

    var nowTime = d.formatDate(now, ['HH', ':', 'nn', ':', 'ss']);
    print(nowTime);
    map["signTime"] = nowTime;
    map["signSection"] =
        formatter + " 00:00:00" + "#" + formatter + " 23:59:59";
    map["signbelongspan"] = "今天";
    map["active"] = "0";
    map["needSign"] = "0";
    map["workmins"] = "480";
    map["signbelong"] = "今天";
    map["reSign"] = "1";
    map["min_next"] = "-1";
    map["signfrom"] = "e9pc";
    map["serialid"] = "1";
    map["signAcross"] = "0";
    map["signAcross_next"] = "0";
    map["time"] = "18:00";
    //地理位置 todo
    map["posttion"] = address;
    map["locationshowaddress"] = "1";

    // GPS坐标
    map["longitude"] = "104.071987";
    map["latitude"] = "30.539615";
    map["locationid"] = "68";
    // WIFI信息
    map["sid"] = "";
    map["mac"] = "";
    map["deviceId"] = "";
    // 设备信息，json格式
    map["deviceInfo"] = "";
    // 固定数据
    map["browser"] = "emobile";
    map["_ec_ismobile"] = "true";
    map["_ec_browser"] = "EMobile";
    map["_ec_browserVersion"] = "7.0.41.20201208";
    map["_ec_os"] = "Android";
    map["_ec_osVersion"] = "8.1.0";
    map["ismobile"] = "1";

    var oaCheckInOutURL =
        "https://oa.bangcle.com/api/hrm/kq/attendanceButton/punchButton";

    BaseOptions options = BaseOptions();
    options.headers["Accept"] = "*/*";
    options.headers["X-Requested-With"] = "XMLHttpRequest";
    options.headers["Content-Type"] =
        "application/x-www-form-urlencoded; charset=utf-8";

    options.headers["Origin"] = oaBaseURL;

    options.headers["Referer"] = oaMainURL;
    options.headers["User-Agent"] = defaultUserAgent;
    // options.headers["cookie"] =
    Dio dio = Dio(options);
    // var cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(Api.cookieJar));
    Response response = await dio.post(oaCheckInOutURL, data: map);
    print('Response status:${response.data}');
    Map<String, dynamic> result = json.decode(response.data);
    String message = "";
    if (result["kqstatus"] == "0") {
      message = result["message"];
    }else {
      message = convert.jsonEncode(response.data);
    }
    setState(() {
      forData = message;
    });
  }

  Future<Response> checkLogin() async {
    var postData = {};
    postData["islanguid"] = "7";
    postData["loginid"] = username;
    postData["userpassword"] = password;
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
    Api.cookieJar.loadForRequest(Uri.parse(oaLoginURL));

    Dio dio = Dio(options);
    dio.interceptors.add(CookieManager(Api.cookieJar));
    Response response = await dio.post(oaLoginURL, data: postData);

    print('Response status:${response.statusCode}');
    print('Response data:${response.data}');
    return response;
  }

  Future<String> getRandAddress() async {
    // var address = [];
    try {
      var address = await rootBundle.loadString('assets/address.txt');
      var ress = address.split("\n");
      var num = Random().nextInt(ress.length);
      return ress[num];
    } catch (e) {
      print(e);
    }
    return "";
  }

  _checkOut() async {
    var address = await getRandAddress();
    print(address);
    // Response result = await checkLogin();
    // print(result);
    // http.Response res = await checkLogin();
    // print("dskfdjskf:${res.body}");
    var map = {};
    var now = DateTime.now();
    print(now);
    var formatter = d.formatDate(now, ['yyyy', '-', 'mm', '-', 'dd']);
    print(formatter);
    map["date"] = formatter;
    map["belongtime"] = "18:00";
    map["type"] = "off";
    map["canSignTime"] = "23:59";
    map["across"] = "0";
    map["belongdate"] = formatter;
    map["datetime"] = formatter + " 18:00:00";
    map["min"] = "480";
    map["isfirstsign"] = "1";
    map["signSectionTime"] = formatter + " 23:59:59";
    map["signSectionBeginTime"] = "";
    map["isYellow"] = "1";
    map["isPunchOpen"] = "1";
    map["isacross"] = "0";
    map["pre"] = "0";

    var nowTime = d.formatDate(now, ['HH', ':', 'nn', ':', 'ss']);
    print(nowTime);
    map["signTime"] = nowTime;
    map["signSection"] =
        formatter + " 00:00:00" + "#" + formatter + " 23:59:59";
    map["signbelongspan"] = "今天";
    map["active"] = "0";
    map["needSign"] = "0";
    map["workmins"] = "480";
    map["signbelong"] = "今天";
    map["reSign"] = "1";
    map["min_next"] = "-1";
    map["signfrom"] = "e9pc";
    map["serialid"] = "1";
    map["signAcross"] = "0";
    map["signAcross_next"] = "0";
    map["time"] = "18:00";
    //地理位置
    map["posttion"] = address;
    map["locationshowaddress"] = "1";

    // GPS坐标
    map["longitude"] = "104.071987";
    map["latitude"] = "30.539615";
    map["locationid"] = "68";
    // WIFI信息
    map["sid"] = "";
    map["mac"] = "";
    map["deviceId"] = "";
    // 设备信息，json格式
    map["deviceInfo"] = "";
    // 固定数据
    map["browser"] = "emobile";
    map["_ec_ismobile"] = "true";
    map["_ec_browser"] = "EMobile";
    map["_ec_browserVersion"] = "7.0.41.20201208";
    map["_ec_os"] = "Android";
    map["_ec_osVersion"] = "8.1.0";
    map["ismobile"] = "1";

    var oaCheckInOutURL =
        "https://oa.bangcle.com/api/hrm/kq/attendanceButton/punchButton";

    BaseOptions options = BaseOptions();
    options.headers["Accept"] = "*/*";
    options.headers["X-Requested-With"] = "XMLHttpRequest";
    options.headers["Content-Type"] =
        "application/x-www-form-urlencoded; charset=utf-8";

    options.headers["Origin"] = oaBaseURL;

    options.headers["Referer"] = oaMainURL;
    options.headers["User-Agent"] = defaultUserAgent;
    // options.headers["cookie"] =
    Dio dio = Dio(options);
    // var cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(Api.cookieJar));
    Response response = await dio.post(oaCheckInOutURL, data: map);
    print('Response status:${response.data}');
    setState(() {
      forData = convert.jsonEncode(response.data);
    });
  }
}

getNow() {
  var now = DateTime.now();
  print(now);
  var formatter = d.formatDate(now, ['yyyy', '-', 'mm', '-', 'dd',' ','HH', ':', 'nn', ':', 'ss']);
  return formatter;
}
