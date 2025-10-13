import 'package:constyle/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../config.dart';

List<NewsData> newsData = [];

Future<String?> loadNewsData() async{

  try{
    dprint("catalog.json=$mainAddress/news.json");
    var response = await http.get(Uri.parse("$mainAddress/news.json")).timeout(const Duration(seconds: 20));
    // if (response.statusCode == 200){
      var t = response.body;
      String char1 = String.fromCharCode(0xd);
      String char2 = String.fromCharCode(0xa);
      String char3 = String.fromCharCode(0x9);
      t = t.replaceAll("$char1$char2", "");
      t = t.replaceAll(char3, "");
      final body = convert.jsonDecode(t);
      dprint("body=$body");
      newsData = [];
      for (var item in body["news"])
        newsData.add(NewsData.fromJson(item));

  }catch(ex){
    return "loadShopData $ex";
  }

  return null;
}

class NewsData{

  NewsData({required this.page, required this.url, required this.short, required this.descr,
    required this.img});

  String page;
  String url;
  String short;
  String descr;
  String img;

  factory NewsData.fromJson(Map<String, dynamic> data){
    return NewsData(
      page: data["page"] != null ? data["page"].toString() : "",
      url: data["url"] != null ? data["url"].toString() : "",
      short: data["short"] != null ? data["short"].toString() : "",
      descr: data["descr"] != null ? data["descr"].toString() : "",
      img: data["img"] != null ? data["img"].toString() : "",
    );
  }
}
