import 'dart:io';

import 'package:constyle/model/signin.dart';
import 'package:flutter/material.dart';
import 'package:constyle/qr.dart';
import 'package:constyle/utils.dart';
import 'package:constyle/widgets/button2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'browser.dart';
import 'config.dart';
import 'dart:convert' as convert;

import 'model/log_sends.dart';
import 'model/token.dart';

sendQr(BuildContext context){
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SendCodeScreen(),
    ),
  );
}

bool _isShowing = false;

class SendCodeScreen extends StatefulWidget {
  const SendCodeScreen({Key? key}) : super(key: key);

  @override
  _SendCodeScreenState createState() => _SendCodeScreenState();
}

class _SendCodeScreenState extends State<SendCodeScreen> {

  double windowWidth = 0;
  double windowHeight = 0;

  @override
  void initState() {
    _isShowing = true;
    _sendCode(context);
    super.initState();
  }

  @override
  void dispose() {
    _isShowing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    loaderWidget,
                    // const Loader30(color: textColor, size: 25),
                    const SizedBox(height: 30,),
                    Text("Отправляем ...", style: serverResponseData.style14W600White,),
                  ],
                )
            ),
            Container(
              margin: const EdgeInsets.all(20),
              alignment: Alignment.bottomCenter,
              child: button2("Отмена", (){
                Navigator.pop(context);
              }),
            )

            //appbar1(Colors.white.withAlpha(100), Colors.black, "Scan QR/Bar Code", context, () {Navigator.pop(context);})

          ],
        )
    );
  }
}

/*
Давай:
"action" = "appqrcode"
"module" = "apk"
"appid" = "..." - из кэша
"apk_key" = fcm метка
"qrcode" = Значение из qr-кода
 */

_sendCode(BuildContext context) async {
  try{
    var _prefs = await SharedPreferences.getInstance();

    dprint("appqrcode отправляем QR код=$currentQR", color: "cyan");

    var _body = {
      'action': 'appqrcode',
      'module': 'apk',
      'appid': _prefs.getString('appid') ?? '0',
      if (Platform.isAndroid)
        'apk_key': await getDeviceDetails(),
      if (Platform.isIOS)
        'ios_key': await getDeviceDetails(),
      "qrcode": currentQR
    };
    dprint("appqrcode посылаем = $_body", color: "cyan");
    var response = await http.post(Uri.parse(addressAPI), body: _body);
    dprint("appqrcode response.statusCode=${response.statusCode}", color: "cyan");
    if (response.statusCode == 200) {
      final body = convert.jsonDecode(response.body);
      var backUrl = body["backurl"];
      dprint("backUrl=$backUrl", color: "cyan");
      if (_isShowing) {
        addLogResponse("appqrcode", body["answer"] ?? "");
        if (backUrl.isEmpty)
          messageError(context, "Error: API appqrcode => backUrl isEmpty");
        else
          openBrowser(backUrl);
      }
    }else
      messageError(context, "statusCode=${response.statusCode}");
    if (_isShowing){
      dprint("Закрываем окно sendQr");
      Navigator.pop(context);
    }
  }catch(ex){
    messageError(context, "appqrcode " + ex.toString());
  }
}

// 10.05.23
// 6. Дорабатываем механизм qr-сканера.
// Сейчас, при срабатывании /qr-scanner/, ты даешь сканировать и отправляешь post-форму с кодом на «appqrcode».
// Я туда добавил возможные параметры:
// <?=SITE?>qr-scanner/?url=https://appsite.ru/somepage/&params=someparamslist
// Если приходит значение «url» и «params», то переходим в режим отправки через offline, то есть сохраняешь значения на устройстве,
// пытаешься отправить и если нет интернета, накапливаешь данные так же как данные /offlinesave/.
// К post-параметрам добавляем 'add' и в этом параметре передаём значение get-переменной «params».
// Остальные параметры те же: appid, qrcode, apk_key, ios_key и теперь вот «add».
// И так же, если работаем с автоматической отправкой post-данных, то на backurl из json-ответа переводить уже не надо,
// переводишь на «url» из get-параметра.
// Очерёдность отправки опять же в той же последовательности, как отправлялись данные, если сначала сканировался qr-код,
// потом отправилось /offlinesave/, то так же и шлёшь, если сначала /offlinesave/, потом qr-код, потом опять /offlinesave/,
// то тоже всё отправится так же.

Future<String?> sendCodeOffline(String code, String params) async {
  try{
    var _prefs = await SharedPreferences.getInstance();

    dprint("appqrcode отправляем QR код=$code", color: "cyan");

    var _body = {
      'add': params,
      'action': 'appqrcode',
      'module': 'apk',
      'appid': _prefs.getString('appid') ?? '0',
      if (Platform.isAndroid)
        'apk_key': await getDeviceDetails(),
      if (Platform.isIOS)
        'ios_key': await getDeviceDetails(),
      "qrcode": code
    };
    dprint("appqrcode посылаем = $_body", color: "cyan");
    var response = await http.post(Uri.parse(addressAPI), body: _body);
    dprint("appqrcode response.statusCode=${response.statusCode}", color: "cyan");
    if (response.statusCode == 200) {
      dprint("sendCodeOffline backUrl=${response.statusCode}", color: "cyan");
      final body = convert.jsonDecode(response.body);
      var answer = body["answer"];
      addLogResponse("appqrcode", answer);
      return null;
    }
    return "response.statusCode=$response.statusCode";
  }catch(ex){
    dprint("sendCodeOffline: $ex");
    return "$ex";
  }
}

