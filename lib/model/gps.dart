import 'dart:async';
import 'dart:io';
import 'package:constyle/model/signin.dart';
import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:wakelock_plus/wakelock_plus.dart';
import '../config.dart';
import '../main.dart';
import 'permission_dialog.dart';
import 'token.dart';

///
/// Отправка координат каждую минуту
///

const seconds = 60;
bool _inProcess = false;
Position? _lastPosition;

setGPSParam(String param, Position? _latLng) async {
  if (serverResponseData.screenon == "YES")
    WakelockPlus.enable();

  // param = "YES";
  // _sendGPS();
// Future.delayed(const Duration(seconds: 10), () {
//   _sendGPS();
// });

  if (param == "YES"){
    _lastPosition = _latLng;
    Timer.periodic(const Duration(seconds: seconds),
      (Timer timer) {
      dprint("timer");
        if (!_inProcess)
          _sendGPS();
      },);
  }
}

_sendGPS() async {

  bool serviceEnabled;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    dprint('Location services are disabled.');
    return;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    var m = prefs.getString("permission_1") ?? "";
    if (m == "later")
      return;
    /// диалог gps need
    var t = await Navigator.of(Get.context!).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) {
          return const PermissionDialog(flag: 1);
        },
      ),
    );
    if (t == null)
      return;
    if (!t)
      return;
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      dprint('Location permissions are denied');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever){
    dprint('Location permissions are permanently denied, we cannot request permissions.');
    return;
  }

  _inProcess = true;
  dprint("_inProcess=$_inProcess");
  Position _position;

  dprint2("Делаем запрос на геопозицию", color: "green");
  try {
    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high).timeout(
        const Duration(seconds: 20));
  }catch(ex){
    dprint(ex.toString());
    _inProcess = false;
    dprint2("Геопозиция Exception=$ex", color: "red");
    return;
  }
  dprint2("Геопозиция получена", color: "green");
  /*
    Перед отправкой нужно проверить, если текущее значение координаты отличается от предыдущего хотя бы в 3-м знаке после запятой, то отправляем, если значение такое же до 3-го знака, то не отправляем.
    Если было 38.4318275, стало 38.4322222 отправляем
    Если было 38.4318275, стало 38.4311111 не отправляем
    Ну изменение знаков до 3-го естественно тоже отправляем:
    Если было 38.4318275, стало 38.5318275 отправляем
   */
  if (_lastPosition != null){
    var lat = (_lastPosition!.latitude-_position.latitude).abs();
    var lng = (_lastPosition!.longitude-_position.longitude).abs();
    dprint("${_lastPosition!.latitude}-${_position.latitude}=$lat");
    dprint("${_lastPosition!.longitude}-${_position.longitude}=$lng");
    if (lat < 0.001 && lng < 0.001){
      _inProcess = false;

      return;
    }
  }
  _lastPosition = _position;

  //
  // отправка
  //
  var _body = {
    'action': 'updategps',
    'module': 'apk',
    'appid': prefs.getString('appid') ?? '0',
    'gps': "${_position.latitude.toString()}+${_position.longitude.toString()}",
    if (Platform.isAndroid)
      'apk_key': await getDeviceDetails(),
    if (Platform.isIOS)
      'ios_key': await getDeviceDetails(),
  };
  dprint2("updategps отправляем ${_body.toString()}");
  var response = await http.post(Uri.parse(addressAPI),
      body: _body);
  dprint2("updategps ответ ${response.statusCode}");
  _inProcess = false;
  dprint("_inProcess=$_inProcess");
}

determinePosition() {
  if (!geo)
    return;
  _sendGPS();
}