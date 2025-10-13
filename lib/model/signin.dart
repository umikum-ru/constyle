import 'dart:convert';
import 'dart:io';
import 'package:constyle/browser.dart';
import 'package:constyle/log_in.dart';
import 'package:constyle/model/server_data.dart';
import 'package:constyle/setting.dart';
import 'package:constyle/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';
import 'cache.dart';
import '../config.dart';
import 'gps.dart';
import 'token.dart';

ServerResponseData serverResponseData = ServerResponseData();
var openLocal = false;

Future<void> singIn(Function(BuildContext) authEnter, Function() showDialog,
    Function(BuildContext) loginEnter,
    BuildContext context,
    Function() redraw) async {

  dprint("singIn");

  // проверяем есть ли в кэше начальная страница
  var str = cacheReadUrlFile(context, mainAddress + "/");
  if (str.isNotEmpty) {
    var _file = File(str);
    if (_file.existsSync()) {
      dprint("В кэше начальная страница есть [$str]", color: "green");
      openLocal = true;
      waiting = false;
      signInRun = false;
      if (redrawMainWindow != null)
        redrawMainWindow!();
    }
  }

  var gps = true;
  var storage = true;
  var contacts = true;
  var microphone = true;

  try{
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      gps = false;
    if (await Permission.storage.isDenied)
      storage = false;
    if (await Permission.contacts.isDenied)
      contacts = false;
    if (await Permission.microphone.isDenied)
      microphone = false;
  }catch(_){

  }

  try{
    dprint2("Send HTTP POST regapp $addressAPI", color: "green");
    // if (Platform.isIOS)
    //   await Future.delayed(const Duration(seconds: 2));
    var body = {
      'action': 'regapp',
      'module': 'apk',
      'appid': serverResponseData.getAppId(),
      'gps': "${position != null ? position!.latitude.toString() : '0'}+${position != null ? position!.longitude.toString() : '0'}",
      if (Platform.isAndroid)
        'apk_key': await getDeviceDetails(),
      if (Platform.isIOS)
        'ios_key': await getDeviceDetails(),
      if (firebaseEnable)
        "firebase_key": await FirebaseMessaging.instance.getToken(),
      'gpsPermission': gps.toString(),
      'storagePermission': storage.toString(),
      'contactsPermission': contacts.toString(),
      'microphonePermission': microphone.toString(),
    };
    if (mainAddress.isEmpty)
      return;

    var response = await http.post(Uri.parse(addressAPI),
        body: body).timeout(const Duration(seconds: 10));

    dprint2("Сервер ответил [regapp] statusCode=${response.statusCode}", color: "green");
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      serverResponseData = ServerResponseData.fromJson(data);

      if (kDebugMode){
        // serverResponseData.backclose = "NO";
        // serverResponseData.appdebug = "YES";
       // serverResponseData.native = "YES";
       //  serverResponseData.content = "1";
        // serverResponseData.site = "https://gruzovoz.siteconst.ru/";
      }

      redraw();
      sendLog();

      if (serverResponseData.site.isNotEmpty){
        dprint2("serverResponseData.site= ${serverResponseData.site}", color: "green");
        try{
        var response = await http.get(Uri.parse(serverResponseData.site)).timeout(const Duration(seconds: 10));
          if (response.statusCode == 200){
            if (serverResponseData.site.endsWith("/")){
              //serverResponseData.site = "https://stretch.9lo.ru/";

              if (serverResponseData.site.substring(0, serverResponseData.site.length-1) != mainAddress){
                mainAddress = serverResponseData.site.substring(0, serverResponseData.site.length-1);
                setIndexPhp();
                cacheDeleteAll();
                dprint2("Новый сайт установлен", color: "green");
                openBrowser("$mainAddress/openapp/id${serverResponseData.appid}/id${serverResponseData.userid}/");
              }
            }
          }else
            dprint2("Ошибка при проверке нового сайта response.statusCode=${response.statusCode}", color: "red");
        }catch(ex){
          dprint2("Ошибка при проверке нового сайта $ex", color: "red");
        }
      }
      dprint(data.toString());
      await serverResponseData.saveParameters();
      if (await cacheCheckTimeStamp(context))
        openBrowser(getAddressTwoMode());

      redraw();
      setGPSParam(serverResponseData.appgps, position);
      if(serverResponseData.native == 'YES'){
        //showNativeWindowsTab0.value = true; // нативный список товаров
        showBottomBar = true;
        if (serverResponseData.userEqual()){
          authEnter(context);
          return;
        }
        showDialog();
      } else{
        loginEnter(context);
      }
    } else{
      dprint("index.php return status code=${response.statusCode}", color: "red");
      messageError(context, "index.php return status code=${response.statusCode}");
    }
    if (serverResponseData.imgversion != "0")
      if (imgversion != serverResponseData.imgversion)
        loadImageFileNoInternet();
  } catch(ex){
    dprint("index.php exception: $ex", color: "red");
    if (ex.toString().startsWith("TimeoutException")){
      dprint("index.php TimeoutException", color: "green");
      //noInternet = true;
      waiting = false;
      // firstRun = false;
      // onlyOffline = true;
      dprint2("index.php не отвечает. Только оффлан", color: "green");
      redraw();
      return;
    }
    dprint("singIn $ex", color: "red");
    // if (!ex.toString().contains("Failed host lookup") && !ex.toString().contains("CERTIFICATE_VERIFY"))
      messageError(context, "singIn $ex");
  }
}
