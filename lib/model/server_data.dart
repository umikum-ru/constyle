
import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../config.dart';
import '../main.dart';

// 09.2024
// 1. Не помню, используется ли apptitle, сделал его просто "title"
// 2. loadcolor — цвет индикатора загрузки на первом экране. Но у нас там есть индикатор ещё в самом webview,
// когда браузер грузится — он там не в цвет и не того вида, как индикатор первого экрана, надо их сделать одинаковыми
// и одного цвета, и чтоб можно было менять из настроек если что.
// 3. Надо иметь возможность менять картинку первого экрана, такое уже бывало не раз. Думаю сделать «firstimg» как путь на картинку на
// сервере.
// Или как это лучше сделать?
// Унас есть параметр «imgversion», он вообще используется? И для чего?
// А в исходнике в настройках есть logoSize, который всегда= 1, он там не особо то нужен я думаю.
// 4. firstcover – YES или NO, это настройка для картинки первого экрана— закрывает она весь экран или ставится по ширине.
// Это в config.dart тоже надо вывести.
// 5. gps надо переносить в настройки, которые после regapp, мы вот сейчас опубликовали Pudra с gps, а там нет gps, и всё, никак не поменяешь.
// Я сделал 2 параметра - «usegps» и «sendgps», usegps — требует разрешение, а  sendgps — режим, который всегда шлёт изменение координат (раньше он назывался appgps).
// Если regapp даёт “usegps»: «YES», значит сохраняем это значение и при каждом запуске и перезагрузке шлём координаты, как сейчас. Если потом начнёт отдавать «NO», тоже сохраняем и перестаём слать при запуске и перезагрузке.
// 6. screenon — тут была проблема, этот режим работал только если есть интернет, это значение надо сохранять, если regapp отдал
// «YES», все последующие запуски и перезагрузки уже с запретом гашения экрана, пока когда-нибудь не получим в ответе «NO»
// 7. topmarging —верхний отступ

/*
Я обновил параметры:
{
"appid": "..", - как и раньше
"apptitle": "…", название окна приложения в config.dart
"site": "http://site1/", - домен в config.dart. Только закрывающий слэш на конце всегда
"userid": "…", - как и раньше
"native": "YES",  - как и раньше
"appgps": "NO",  - как и раньше
"viewbg": "#eeeeee",  - как и раньше
"firstbg": "#ffffff", - цвет фона первого экрана
"color":"#333333", - цвет шрифта на нативном окне авторизации
"buttonbg": "#333333", - цвет фона кнопки на нативном окне, а также цвет для твоих сообщений (подождите пока кэш делается и пр.)
"buttoncolor": "#ffffff", - цвет шрифта на кнопке нативного окна, а также цвет надписи сообщений (подождите пока кэш делается и пр.)
"screenon": "NO",   - как и раньше
"content": "1649683731",   - как и раньше
"appconsole": "NO", - переменная в config.dart - Console
"appfiles": "NO",  - переменная в config.dart – All Files
"appsourse": "NO",  - переменная в config.dart - Sourse
}

Все картинки для asset доступны по адресам:
«site» + images/appfirst.jpg – картинка первого экрана
«site» + images/appinternet.jpg – картинка что нет интернета
«site» + images/appcache.jpg – картинка что нет интернета
appfirst.jpg – 730 на 1300, остальные 730 на 730
 */

class ServerResponseData{

  Color loadcolor = constLoaderColor;
  String firstcover = firstCover;
  String topmarging = upTitleMarginEnable;
  String backclose = backClose;
  String appid;
  String userid;
  // String appsTitle;

  String native;
  String appgps;
  String site;

  // Color firstbg;
  // Color viewbg;
  Color color;
  // Color buttonbg;
  // Color bgcolor;
  // Color textColor;
  // Color buttoncolor;

  String screenon;
  String content;

  String appconsole;
  String appfiles;
  String appsourse;
  String imgversion;

  String appphone;
  String appdebug;

  // Александр, [23.06.2023 16:18]
  //  Всё, в regapp вывел "nativenews" и "appgame". "nativenews" либо YES либо NO, если YES, то берём /news.json
  // "appgame" либо пустое либо это ссылка на страницу с игрой
  String nativenews;
  String appgame;

  ServerResponseData({this.appid = "", this.userid = "", this.native = "",
    // this.viewbg = mainViewBg,
    this.color = Colors.black,
    this.appgps = "",
    // this.buttonbg = Colors.blue,
    // this.buttoncolor = Colors.green,
    this.screenon = "",
    // this.bgcolor = Colors.white,
    // this.textColor = Colors.black,
    this.content = "",
    // this.firstbg = constFirstbg,
    // this.appsTitle = "",
    this.site = "",
    this.appconsole = "NO", this.appfiles = "NO", this.appsourse = "NO",
    this.imgversion = "", this.appphone = "", this.appdebug = "YES",
    this.nativenews = "NO", this.appgame = "", this.backclose = "YES"
  }){
    _initFonts();
  }

  _initFonts(){
    style12W800MainColor = const TextStyle(letterSpacing: 0.6,
        fontSize: 12, fontWeight: FontWeight.w800, color: textColor);
    styleText = const TextStyle(letterSpacing: 0.6,
        fontSize: 14, fontWeight: FontWeight.w800, color: textColor);
    style14W600White = const TextStyle(letterSpacing: 0.6,
        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white);
  }

  late TextStyle style12W800MainColor;
  late TextStyle style14W600White;
  late TextStyle styleText;

  factory ServerResponseData.fromJson(Map<String, dynamic> data){
    var ret = ServerResponseData(
      appid: (data["appid"] != null) ? data["appid"] : "",
      userid: (data["userid"] != null) ? data["userid"] : "",
      // appsTitle: (data["appTitle"] != null) ? data["appTitle"] : "",
      site: (data["site"] != null) ? data["site"] : "",

      native: (data["native"] != null) ? data["native"] : "",
      color: (data["color"] != null) ? HexColor(data["color"]) : Colors.black,
      appgps: (data["usegps"] != null) ? data["usegps"] : upTitleMarginEnable,
      backclose: (data["backclose"] != null) ? data["backclose"] : backClose,

      // viewbg: (data["viewbg"] != null) ? HexColor(data['viewbg']) : Colors.white,
      // buttonbg: (data["buttonbg"] != null) ? HexColor(data['buttonbg']) : Colors.blue,
      // bgcolor: data['bgcolor'] != null ? HexColor(data['bgcolor']) : Colors.white,
      // textColor: data['textColor'] != null ? HexColor(data['textColor']) : Colors.black,
      // buttoncolor: data['buttoncolor'] != null ? HexColor(data['buttoncolor']) : Colors.green,
      // firstbg: data['firstbg'] != null ? HexColor(data['firstbg']) : Colors.transparent,

      screenon: (data["screenon"] != null) ? data["screenon"] : "",
      content: (data["content"] != null) ? data["content"] : "",

      appconsole: (data["appconsole"] != null) ? data["appconsole"] : "",
      appfiles: (data["appfiles"] != null) ? data["appfiles"] : "",
      appsourse: (data["appsourse"] != null) ? data["appsourse"] : "",

      appphone: (data["appphone"] != null) ? data["appphone"] : "",
      appdebug: (data["appdebug"] != null) ? data["appdebug"].toString() : "NO",

      nativenews: (data["nativenews"] != null) ? data["nativenews"].toString() : "NO",
      appgame: (data["appgame"] != null) ? data["appgame"].toString() : "",

    );

    var t = data["loadcolor"];
    if (t != null)
      ret.loadcolor = HexColor(t);
    t = data["firstcover"];
    if (t != null)
      ret.firstcover = t;
    t = data["topmarging"];
    if (t != null)
      ret.topmarging = t;

    return ret;
  }

  saveParameters(){
    prefs.setString("appid", appid);
    prefs.setString("userid", userid);
    prefs.setString("screenon", screenon);

    // prefs.setString("appTitle", appsTitle);
    prefs.setString("site", site);

    /// new
    prefs.setString("loadcolor", loadcolor.value.toString());
    prefs.setString("appgps", appgps);

    // prefs.setString("bgcolor", bgcolor.value.toString()); // Цвет фона приложения
    prefs.setString("color", color.value.toString());    // Цвет шрифта приложения
    // prefs.setString("viewbg", viewbg.value.toString());
    prefs.setString("buttonbg", buttonbg.value.toString()); // Цвет кнопки приложения
    prefs.setString("buttoncolor", buttoncolor.value.toString());  // Цвет шрифта кнопки приложения
    // prefs.setString("firstbg", firstbg.value.toString());

    prefs.setString("appconsole", appconsole);
    prefs.setString("appfiles", appfiles);
    prefs.setString("appsourse", appsourse);

    prefs.setString("imgversion", imgversion);
    prefs.setString("backclose", backclose);

  }

  loadParameters() {
    dprint("loadParameters");
    try {
      prefs.getString('appid') ?? '0';
      prefs.getString('userid') ?? '0';

      var t = prefs.getString("site");
      if (t != null) site = t;

      t = prefs.getString("imgversion");
      if (t != null) imgversion = t;

      t = prefs.getString("loadcolor");
      if (t != null) loadcolor = toColor(t);

      t = prefs.getString("screenon");
      if (t != null) screenon = t;

      t = prefs.getString("appgps");
      if (t != null) appgps = t;

      // t = prefs.getString("buttoncolor");
      // if (t != null) buttoncolor = toColor(t);

      // t = prefs.getString("viewbg");
      // if (t != null)
      //   viewbg = toColor(t);
      // else
      //   viewbg = mainViewBg;

      t = prefs.getString("color");
      if (t != null) color = toColor(t);

      // t = prefs.getString("buttonbg");
      // if (t != null) buttonbg = toColor(t);

      // t = prefs.getString("bgcolor");
      // if (t != null) bgcolor = toColor(t);

      // t = prefs.getString("color");
      // if (t != null) bgcolor = toColor(t);

      // t = prefs.getString("firstbg");
      // if (t != null)
      //   firstbg = toColor(t);
      // else
      //   firstbg = constFirstbg;

      // t = prefs.getString("appTitle");
      // if (t != null)
      //   appsTitle = t;
      // else
      //   appsTitle = appTitle;

      t = prefs.getString("appconsole");
      if (t != null) appconsole = t;
      t = prefs.getString("appfiles");
      if (t != null) appfiles = t;
      t = prefs.getString("appsourse");
      if (t != null) appsourse = t;

      t = prefs.getString("backclose");
      if (t != null) backclose = t;

      _initFonts();
    }catch(ex){
      dprint("loadParameters " + ex.toString());
    }
    dprint("loadParameters end");
  }

  String getAppId() {
    return prefs.getString('appid') ?? '0';
  }

  String _getUserId() {
    return prefs.getString('userid') ?? '';
  }

  bool userEqual() {
    if (userid.isEmpty)
      false;
    if (_getUserId() != userid)
      return false;
    return true;
  }

  saveAppId() {
    prefs.setString("appid", appid);
    // prefs!.setString("offlinetext", offlinetext']);
    // prefs!.setString("offlineimg", data['offlineimg']);
  }

  login(String id){
    userid = id;
  }

  saveUserId() {
    prefs.setString("userid", userid);
    // prefs!.setString("offlinetext", offlinetext']);
    // prefs!.setString("offlineimg", data['offlineimg']);
  }

}
