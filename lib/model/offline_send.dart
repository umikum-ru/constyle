
/*
Отправка данных. Аналогично всем нашим отправкам для приложений:
'appid',
'datetime' – в виде строки вида «2023.01.17 - 13:00», чтоб потом отсортировать можно было
'data' – соджержимое кэша в виде:
«
addtobasket::111-|-Покупка "Бургер"-|-http://site1/burger/+|+col-|-Количество-|-1+|+a02-|-Способ-|-Способ 1+|+_|_
addtobasket::107-|-Покупка "Картофель фри"-|-http://site1/kartofely-fri/+|+col-|-Количество-|-1+|+a02-|-Способ-|-Способ 1+|+_|_
«
'apk_key' – если андройд
'ios_key' – если айфон

Передаём и копируем не в виде base64, а обычным текстом

 */

import 'dart:io';
import 'package:constyle/model/token.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../browser.dart';
import '../config.dart';
import '../utils.dart';
import 'package:intl/intl.dart';
import 'dart:convert' as convert;

import 'log_sends.dart';

sendOffline(BuildContext context, String data) async {
  try{
    var _prefs = await SharedPreferences.getInstance();

    ///  – в виде строки вида «2023.01.17 - 13:00», чтоб потом отсортировать можно было
    final formatter = DateFormat('yyyy.MM.dd - HH:mm');
    var date = formatter.format(DateTime.now());

    var _body = {
      'action': 'getofflinedata',
      'module': 'apk',
      'appid': _prefs.getString('appid') ?? '0',
      if (Platform.isAndroid)
        'apk_key': await getDeviceDetails(),
      if (Platform.isIOS)
        'ios_key': await getDeviceDetails(),
      'datetime': date,
      'data': data
  };
    dprint("offline посылаем addressAPI=$addressAPI =$_body ", color: "cyan");
    var response = await http.post(Uri.parse(addressAPI), body: _body);
    dprint("offline response.statusCode=${response.statusCode}", color: "cyan");
    if (response.statusCode == 200) {
      // messageOk(context, "Данные отправлены");
      final body = convert.jsonDecode(response.body);
      var backUrl = body["backurl"];
      dprint("backUrl=$backUrl", color: "cyan");
      openBrowser(backUrl);
      var answer = body["answer"];
      addLogResponse("getofflinedata", answer);
    }else
      messageError(context, "offline send statusCode=${response.statusCode}");
  }catch(ex){
    messageError(context, "offline send " + ex.toString());
  }
}

