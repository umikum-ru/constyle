import 'dart:convert';
import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:constyle/model/signin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

import 'config.dart';
import 'model/token.dart';

List<String> _log = [];

final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

/*
красный
\x1B[31mHello\x1B[0m

Black:   \x1B[30m
Red:     \x1B[31m
Green:   \x1B[32m
Yellow:  \x1B[33m
Blue:    \x1B[34m
Magenta: \x1B[35m
Cyan:    \x1B[36m
White:   \x1B[37m
Reset:   \x1B[0m
 */

dprint2(String str, {String color = "", String style = ""}){
  dprint(str, color: color, style: style);
}

Database? _db;

initDB() async {
  try {
      var directory = await getApplicationDocumentsDirectory();
      var directoryPath = directory.path;
      var path = '$directoryPath/app.db';
      if (!File(path).existsSync()){

          _db = sqlite3.open(path);

          if (_db == null)
            return;

          var query = "CREATE TABLE log(id INTEGER PRIMARY KEY AUTOINCREMENT, msg TEXT)";
          if (kDebugMode)
            print("log db: query=$query");
          _db!.execute(query);

      }else
        _db = sqlite3.open(path);

  }catch(ex){
    if (kDebugMode)
      print("log db init: $ex");
  }
}

_log2(String str) async {
  if (serverResponseData.appdebug == "YES"){ /// отправляем на сервер данные
    try{
      if (_db == null)
        return;

      str = "${formatter.format(DateTime.now().toUtc())} $str";
      _db!.execute("INSERT INTO log (msg) VALUES ('${str.replaceAll("'", "")}')");

    }catch(ex){
      if (kDebugMode)
        print("_log2 $ex");
    }
  }
}

Future<bool> sendLog() async {
  if (_db == null)
    return false;

  if (serverResponseData.appdebug != "YES") {
    var query = "DELETE FROM log";
    _db!.execute(query);
    return false;
  }

  try{
    ResultSet ret = _db!.select("SELECT * FROM log ORDER BY id "); // LIMIT 100
    var text = "";
    if (ret.isEmpty)
      return false;
    // if (ret.length < 10)
    //   return false;
    for (var item in ret){
      if (text.isNotEmpty)
        text += "<BR>";
      text += item["msg"].toString();
    }
    text = json.encode(text);
    if (text.isEmpty)
      return false;

    var r = await _send(text);
    if (r != null)
      return false;

    for (var item in ret){
      var query = "DELETE FROM log WHERE id=${item['id']}";
      _db!.execute(query);
    }
    // await sendLog();

  }catch(ex){
    if (kDebugMode) {
      print("sendLog $ex");
    }
  }
  return false;
}

getAppInfo() async {
  PackageInfo appInfo = await PackageInfo.fromPlatform();
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  var text2 = "AppInfo. name:${appInfo.appName} packageName=${appInfo.packageName} version=${appInfo.version}.${appInfo.buildNumber}";
  text2 += "<BR>";
  if (Platform.isAndroid){
    final String? androidId = await const AndroidId().getId();
    AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;
    var t = {
      'id': deviceInfo.id,
      'host': deviceInfo.host,
      'type': deviceInfo.type,
      'model': deviceInfo.model,
      'board': deviceInfo.board,
      'brand': deviceInfo.brand,
      'device': deviceInfo.device,
      'product': deviceInfo.product,
      'display': deviceInfo.display,
      'hardware': deviceInfo.hardware,
      'androidId': androidId,
      'bootloader': deviceInfo.bootloader,
      'version': deviceInfo.version.toMap(),
      'manufacturer': deviceInfo.manufacturer,
      'supportedAbis': deviceInfo.supportedAbis,
      'isPhysicalDevice': deviceInfo.isPhysicalDevice,
      'supported32BitAbis': deviceInfo.supported32BitAbis,
      'supported64BitAbis': deviceInfo.supported64BitAbis,
    };

    text2 += t.toString();
  }
  if (Platform.isIOS){
    IosDeviceInfo deviceInfo = await deviceInfoPlugin.iosInfo;
    text2 += deviceInfo.toMap().toString();
  }
  text2 += "<BR>";
  return text2;
}

Future<String?> _send(String data) async {
  try{
    var _prefs = await SharedPreferences.getInstance();
    var _body = {
      'action': 'getdebugdata',
      "site": mainAddress,
      'module': 'apk',
      'appid': _prefs.getString('appid') ?? '0',
      if (Platform.isAndroid)
        'apk_key': await getDeviceDetails(),
      if (Platform.isIOS)
        'ios_key': await getDeviceDetails(),
      'data': data
    };
    await http.post(Uri.parse(addressAPI), body: _body);
    // dprint("_send");
    // if (response.statusCode == 200) {
    //
    // }else
    //   return "error";
  }catch(ex){
    return "error";
  }
  return null;
}

dprint(String str, {String color = "", String style = ""}){
  _log.add("${formatter.format(DateTime.now())} $str");
  _log2(str);

  if (kDebugMode) {
    // addPoint(str, error: color);
    if (Platform.isIOS){
      print(str);
      return;
    }

    str = "${formatter.format(DateTime.now())} $str";

    String text = "";
    switch (color) {
      case "red":
        text = "\x1B[31m$str\x1B[0m";
        break;
      case "green":
        text = "\x1B[32m$str\x1B[0m";
        break;
      case "yellow":
        text = "\x1B[33m$str\x1B[0m";
        break;
      case "blue":
        text = "\x1B[34m$str\x1B[0m";
        break;
      case "magenta":
        text = "\x1B[35m$str\x1B[0m";
        break;
      case "cyan":
        text = "\x1B[36m$str\x1B[0m";
        break;
      case "grey":
        text = "\x1B[37m$str\x1B[0m";
        break;
      case "red_b":
        text = "\x1B[41m$str\x1B[0m";
        break;
      case "green_b":
        text = "\x1B[42m$str\x1B[0m";
        break;
      case "yellow_b":
        text = "\x1B[43m$str\x1B[0m";
        break;
      case "blue_b":
        text = "\x1B[44m$str\x1B[0m";
        break;
      case "magenta_b":
        text = "\x1B[45m$str\x1B[0m";
        break;
      case "cyan_b":
        text = "\x1B[46m$str\x1B[0m";
        break;
      case "grey_b":
        text = "\x1B[47m$str\x1B[0m";
        break;
      default:
        text = "\x1B[37m$str\x1B[0m";
    }

    switch (style) {
      case "b": // bold
        text = "\x1B[1m$text\x1B[22m";
        break;
      case "i": // italic
        text = "\x1B[3m$text\x1B[23m";
        break;
      case "u": // underline
        text = "\x1B[4m$text\x1B[24m";
        break;
      case "n": // inverse
        text = "\x1B[7m$text\x1B[27m";
        break;
      case "s": // зачеркнуто
        text = "\x1B[9m$text\x1B[29m";
        break;
    }
    print(text);
  }
}

String getLogText(){
  var _text = "";
  for (var item in _log)
    _text += "$item\n";
  return _text;
}

String _lastErrorText = "";

messageError(BuildContext context, String _text){
  if (_lastErrorText == _text)
    return;
  _lastErrorText = _text;
  dprint("messageError $_text", color: "red");
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
      action:  SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      content: Text(_text,
        style: const TextStyle(color: Colors.white), textAlign: TextAlign.center,)));
}

messageOk(BuildContext context, String _text){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: buttonbg,
      duration: const Duration(seconds: 5),
      action:  SnackBarAction(
        label: 'Close',
        textColor: buttoncolor,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      content: Text(_text,
        style: const TextStyle(color: Colors.white), textAlign: TextAlign.center,)));
}

Color toColor(String? boardColor){
  if (boardColor == null) {
    return Colors.red;
  }
  var t = int.tryParse(boardColor);
  if (t != null) {
    return Color(t);
  }
  return Colors.red;
}

String? getAppPath(String filename){
  String? _file;
  var _lastIndex = filename.lastIndexOf("/");
  if (_lastIndex != -1)
    _file = filename.substring(0, _lastIndex);
  return _file;
}

String? getFileName(String filename){
  String? _file;
  var _lastIndex = filename.lastIndexOf("/");
  if (_lastIndex != -1)
    _file = filename.substring(_lastIndex+1);
  return _file;
}

String? getFileNameBody(String filename){
  String? _file;
  var _lastIndex = filename.lastIndexOf(".");
  if (_lastIndex != -1)
    _file = filename.substring(0, _lastIndex);
  return _file;
}

String? getFileNameExtension(String filename){
  String? _file;
  var _lastIndex = filename.lastIndexOf(".");
  if (_lastIndex != -1)
    _file = filename.substring(_lastIndex+1);
  return _file;
}

int toInt(String str){
  int ret = 0;
  try {
    ret = int.parse(str);
  }catch(_){}
  return ret;
}

String clearPhoneNumber(String phoneText){
  String s = "";
  for (int i = 0; i < phoneText.length; i++) {
    int c = phoneText.codeUnitAt(i);
    if ((c == "1".codeUnitAt(0)) || (c == "2".codeUnitAt(0)) || (c == "3".codeUnitAt(0)) ||
        (c == "4".codeUnitAt(0)) || (c == "5".codeUnitAt(0)) || (c == "6".codeUnitAt(0)) ||
        (c == "7".codeUnitAt(0)) || (c == "8".codeUnitAt(0)) || (c == "9".codeUnitAt(0)) ||
        (c == "0".codeUnitAt(0))) {
      String h = String.fromCharCode(c);
      s = "$s$h";
    }
  }
  return s;
}
