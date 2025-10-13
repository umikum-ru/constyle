import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../config.dart';
import '../utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

List<String> _urls = [];
List<NativeData> _nativeData = [];

List<NativeData> getNativeData() => _nativeData;

clearData(){
  _urls = [];
  _nativeData = [];
}

loadShopList(String body) async {

  _urls = [];
  _nativeData = [];

//<!--{NATIVE[https://reciptorica.9lo.ru/goodslist.json]}-->
  try {
    var i2 = 0;
    do {
      var text = "<!--{NATIVE[";
      var i = body.indexOf(text, i2);
      if (i == -1)
        break;
      i += text.length;
      i2 = body.indexOf("]}-->", i);
      if (i2 == -1)
        break;
      var url = body.substring(i, i2);
      // print("url=$url");
      _urls.add(url);
    } while (i2 < body.length);
  }catch(ex){
    dprint("loadShopList $ex");
  }
  // dprint("urls $_urls");
  for (var item in _urls){
    await _loadShopData(item);
  }

  redrawNativeShopScreens(0);
}

Future<String?> _loadShopData(String name) async{

  try{
    dprint("_loadShopData=$name");
    var response = await http.get(Uri.parse(name)).timeout(const Duration(seconds: 20));
    // if (response.statusCode == 200){
    var t = response.body;
    String char1 = String.fromCharCode(0xd);
    String char2 = String.fromCharCode(0xa);
    String char3 = String.fromCharCode(0x9);
    t = t.replaceAll("$char1$char2", "");
    t = t.replaceAll(char3, "");
    /// utf8
    var body = convert.jsonDecode(t);

    /// windows 1251
    // const codec = Windows1251Codec(allowInvalid: false);
    // t = codec.decode(t.codeUnits);
    // final body = convert.jsonDecode(utf8.decode(response.bodyBytes));

    dprint("body2=$body");

    // if (_first == 1){
    //   _first = 2;
    //   body = {
    //     "design": [
    //       {"columns":"3", "top": "20", "bottom": "0", "height": "80", "blockheight" : "60", "background": "#000000", "namecolor": "#eeeeee", "maincolor": "#ffffff", "paramscolor": "#ffffff", "round": "no", "border": "no", "shadow": "no" }
    //     ],
    //     "blocks": [
    //       { "name":"no", "url": "", "img": "images/menu.svg", "main": "no", "params": "Меню" },
    //       { "name":"no", "url": "shopbasket/", "img": "images/basket.svg", "main": "no", "params": "Корзина" },
    //       { "name":"no", "url": "private/profile/", "img": "images/profile.svg", "main": "no", "params": "Профиль" }
    //
    //     ]
    //   };
    // }else{
    //   body = {
    //     "design": [
    //       {"columns":"1", "top": "100", "bottom": "100", "height": "no", "blockheight" : "300", "background": "#ffffff", "namecolor": "#bd9746", "maincolor": "#000000", "paramscolor": "#707070", "round": "yes", "border": "yes", "shadow": "yes" }
    //     ],
    //     "blocks": [
    //       { "name":"Мохито бризз", "url": "katalog/shaurma-miks-xl-kuritsasvinina/", "img": "img/1432_1.jpg", "main": "250 руб", "params": "Лаваш<br>Свиной шашлык" },
    //       { "name":"Цезарь с ципленком", "url": "katalog/shaurma-miks-kuritsasvinina/", "img": "img/1435_1.jpg", "main": "330 руб", "params": "Лаваш<br>Куриный шашлык" },
    //       { "name":"Лапша с морепродуктами", "url": "katalog/shaurma-miks-xl-kuritsasvinina/", "img": "img/1432_1.jpg", "main": "250 руб", "params": "Лаваш<br>Свиной шашлык" },
    //       { "name":"Овощи", "url": "katalog/shaurma-miks-kuritsasvinina/", "img": "img/1435_1.jpg", "main": "150 руб", "params": "Лаваш<br>Куриный шашлык" }
    //     ]
    //   };
    // }

    _nativeData.add(NativeData.fromJson(body));

  }catch(ex){
    return "loadShopData $ex";
  }

  return null;
}

// var _first = 1;

class NativeData{
  NativeData({required this.design, required this.blocks});

  List<NativeDataDesign> design;
  List<NativeDataBlocks> blocks;

  factory NativeData.fromJson(Map<String, dynamic> data){
    List<NativeDataDesign> design = [];
    if (data["design"] != null)
      for (var item in data["design"])
        design.add(NativeDataDesign.fromJson(item));

    List<NativeDataBlocks> blocks = [];
    if (data["blocks"] != null)
      for (var item in data["blocks"])
        blocks.add(NativeDataBlocks.fromJson(item));

    return NativeData(
      design: design,
      blocks: blocks
    );
  }
}

class NativeDataDesign{
  NativeDataDesign({
    required this.columns, required this.top, required this.bottom,
    required this.height, required this.background,  required this.namecolor,
    required this.maincolor, required this.paramscolor,  required this.round,
    required this.border, required this.shadow, required this.blockheight
  });

  int columns;
  double top;       // ok
  double bottom;      // ok
  double height;    // ok
  Color background;   // ok
  Color namecolor;    // ok
  Color maincolor;    // ok
  Color paramscolor; // ok
  bool round;           // ok
  bool border;          //ok
  bool shadow;          // ok
  double blockheight;   // ok

  factory NativeDataDesign.fromJson(Map<String, dynamic> data){
    return NativeDataDesign(
      columns: data["columns"] != null ? toInt(data["columns"].toString()) : 1,
      top: data["top"] != null ? toInt(data["top"].toString()).toDouble() : 0,
      bottom: data["bottom"] != null ? toInt(data["bottom"].toString()).toDouble() : 0,
      height: data["height"] != null ? toInt(data["height"].toString()).toDouble() : 0,
      background: data["background"] != null ? HexColor(data['background']) : Colors.grey,
      namecolor: data["namecolor"] != null ? HexColor(data['namecolor']) : Colors.grey,
      maincolor: data["maincolor"] != null ? HexColor(data['maincolor']) : Colors.grey,
      paramscolor: data["paramscolor"] != null ? HexColor(data['paramscolor']) : Colors.grey,
      round: data["round"] != null ? data["round"].toString().toLowerCase() == "yes" : false,
      border: data["border"] != null ? data["border"].toString().toLowerCase() == "yes" : false,
      shadow: data["shadow"] != null ? data["shadow"].toString().toLowerCase() == "yes" : false,
      blockheight: data["blockheight"] != null ? toInt(data["blockheight"].toString()).toDouble() : 10.0,
    );
  }
}


class NativeDataBlocks{
  NativeDataBlocks({
    required this.name, required this.url, required this.img,
    required this.main, required this.params,
  });

  String name;
  String url;
  String img;
  String main;
  String params;

  factory NativeDataBlocks.fromJson(Map<String, dynamic> data){
    var name = data["name"] != null ? data["name"].toString() : "";
    if (name == "no")
      name = "";

    var url = data["url"] != null ? data["url"].toString() : "";
    if (url == "no")
      url = "";

    var img = data["img"] != null ? data["img"].toString() : "";
    if (img == "no")
      img = "";
    if (img.isNotEmpty)
      img = mainAddress + "/" + img;

    var main = data["main"] != null ? data["main"].toString() : "";
    if (main == "no")
      main = "";

    var params = data["params"] != null ? data["params"].toString() : "";
    if (params == "no")
      params = "";

    return NativeDataBlocks(
      name: name,
      url: url,
      img: img,
      main: main,
      params: params,
    );
  }
}

Function(int) redrawNativeShopScreens = (_){};

