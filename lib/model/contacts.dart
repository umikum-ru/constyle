import 'dart:convert';
import 'dart:io';
import 'package:constyle/browser.dart';
import 'package:constyle/log_in.dart';
import 'package:constyle/model/token.dart';
import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../config.dart';
import '../main.dart';
import '../setting.dart';
import 'permission_dialog.dart';

sendPhoneBook(BuildContext context) async {
  wait = true;
  if (redrawMainWindow != null)
    redrawMainWindow!();
  await _sendPhoneBook(context);
  wait = false;
  if (redrawMainWindow != null)
    redrawMainWindow!();
}

_sendPhoneBook(BuildContext context) async {
  if (await Permission.contacts.isDenied) {
    var m = prefs.getString("permission_3") ?? "";
    if (m == "later")
      return;

    var t = await Navigator.of(Get.context!).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) {
          return const PermissionDialog(flag: 3,);
        },
      ),
    );
    if (!t)
      return;
  }

  var contacts = await FlutterContacts.requestPermission(readonly: true);
  if (contacts) {
    List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);

    // for (var item in contacts){
    //   var t = json.encode(item.toJson());
    //   print(t);
    // }

    var t = contacts.map((i) => i.toJson()).toList();

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    dprint("getphonebook отправляем", color: "cyan");

    var _body = {
      'action': 'getphonebook',
      'module': 'apk',
      'appid': _prefs.getString('appid') ?? '0',
      if (Platform.isAndroid)
        'apk_key': await getDeviceDetails(),
      if (Platform.isIOS)
        'ios_key': await getDeviceDetails(),
      "phonebook": json.encode(t)
    };

    var response = await http.post(Uri.parse(addressAPI), body: _body);
    dprint("getphonebook response.statusCode=${response.statusCode}", color: "cyan");
    if (response.statusCode == 200) {
      final body = convert.jsonDecode(response.body);
      var backUrl = body["backurl"];
      dprint("backUrl=$backUrl", color: "cyan");
      // messageOk(context, stringDataSend);
      if (backUrl.isEmpty)
        messageError(context, "Error: API appqrcode => backUrl isEmpty");
      else {
        openBrowser(backUrl);
      }
    }else
      messageError(context, "statusCode=${response.statusCode}");
  }
}




