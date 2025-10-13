// import 'dart:convert';
import 'package:constyle/utils.dart';
// import 'package:enough_convert/enough_convert.dart';
// import 'package:enough_convert/enough_convert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../config.dart';

List<ShopData> catalog = [];

Future<String?> loadShopData() async{

  try{
    dprint("catalog.json=$mainAddress/catalog.json");
    var response = await http.get(Uri.parse("$mainAddress/catalog.json")).timeout(const Duration(seconds: 20));
    // if (response.statusCode == 200){
      var t = response.body;
      String char1 = String.fromCharCode(0xd);
      String char2 = String.fromCharCode(0xa);
      String char3 = String.fromCharCode(0x9);
      t = t.replaceAll("$char1$char2", "");
      t = t.replaceAll(char3, "");

      /// загрузка магазина для Apple проверки (когда выкладываем в стор)

      /// utf 8
      final body = convert.jsonDecode(t);

      /// windows 1251
      // const codec = Windows1251Codec(allowInvalid: false);
      // t = codec.decode(t.codeUnits);
      // final body = convert.jsonDecode(utf8.decode(response.bodyBytes));

      dprint("body=$body");
      var ret = ShopDataResponse.fromJson(body);
      catalog = ret.catalog;
    // }
  }catch(ex){
    return "loadShopData $ex";
  }

  return null;
}

class ShopDataResponse{
  ShopDataResponse({required this.catalog});

  List<ShopData> catalog;

  factory ShopDataResponse.fromJson(Map<String, dynamic> json){

    List<ShopData> _catalog = [];
    if (json['catalog'] != null)
      for (var item in json['catalog'])
        _catalog.add(ShopData.fromJson(item));

    return ShopDataResponse(
      catalog: _catalog,
    );
  }
}

class ShopData{
  ShopData({required this.page, required this.url, required this.price,
    required this.descr, required this.img, });

  String page;
  String url;
  String price;
  String descr;
  String img;
  var controller = TextEditingController();

  factory ShopData.fromJson(Map<String, dynamic> data){
    return ShopData(
      page: data["page"] ?? "",
      url: data["url"] ?? "",
      price: data["price"] ?? "",
      descr: data["descr"] ?? "",
      img: data["img"] ?? "",
    );
  }
}

