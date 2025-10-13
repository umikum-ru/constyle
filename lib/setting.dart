import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

bool wait = false;
// bool noInCacheDialog = false; // надо написать что такой страницы в кэше нет и предложить открыть онлайн версию
// String urlToOpenOnline = "";
bool noInternet = false;
Position? position;
//String token = "";
var dio = Dio();
bool waiting = true;
bool goBack = false;
// int isCachingProcess = 0;
String source = ""; // "cache" "server"    "cacheEnd"(после 5 сек)

class Behavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

Color mainBackgroundColor = const Color(0xff000000);

// void toast(text, color) {
//   Fluttertoast.showToast(
//       msg: text,
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 10,
//       backgroundColor: color,
//       textColor: Colors.white,
//       fontSize: 16.0
//   );
// }