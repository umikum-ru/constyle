import 'dart:io';
import 'package:constyle/browser.dart';
import 'package:constyle/model/token.dart';
import 'package:constyle/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:record_mp3/record_mp3.dart';
import 'package:constyle/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:record_mp3_plus/record_mp3_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

import '../main.dart';
import 'permission_dialog.dart';

Future<bool> _checkPermission() async {
  if (!await Permission.microphone.isGranted) {
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }
  }
  return true;
}

bool getSoundWriteState() => _work;

var _work = false;

startWriteSound(BuildContext context) async {

  if (await Permission.microphone.isDenied) {
    var m = prefs.getString("permission_4") ?? "";
    if (m == "later")
      return;

    var t = await Navigator.of(Get.context!).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) {
          return const PermissionDialog(flag: 4,);
        },
      ),
    );
    if (!t)
      return;
  }

  bool hasPermission = await _checkPermission();
  if (hasPermission) {
    var tempDir = await getApplicationDocumentsDirectory();
    var _mPath = '${tempDir.path}/record';
    var d = Directory(_mPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    //start record
    _work = true;
    RecordMp3.instance.start(_mPath + "/flutter_sound.mp3", (RecordErrorType type) {
      dprint(type.toString());
      _work = false;
      messageError(context, type.toString());
      // record fail callback
    });
  }
}

stopWhiteSound(){
  if (_work) {
    RecordMp3.instance.stop();
    _work = false;
  }
}

deleteSound() async {
  var tempDir = await getApplicationDocumentsDirectory();
  var _mPath = '${tempDir.path}/record';
  var d = Directory(_mPath);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
  }
}

final audioPlayer = AudioPlayer();

initMp3State() async {
  tempDir = await getApplicationDocumentsDirectory();
}

Directory? tempDir;

bool isMp3FilePresent()  {
  if (tempDir == null)
    return false;
  var _mPath = '${tempDir!.path}/record';
  return File("$_mPath/flutter_sound.mp3").existsSync();
}

stopSound(){
  audioPlayer.stop();
}

playSound(BuildContext context, Function(String) callback) async {
  try{
    var tempDir = await getApplicationDocumentsDirectory();
    var _mPath = '${tempDir.path}/record';
    var d = Directory(_mPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }

    audioPlayer.onPlayerStateChanged.listen((PlayerState s)  {
      dprint('Current player state: $s');
      if (s == PlayerState.playing)
        callback("play");
      else{
        callback("stop");
      }
    });

    await audioPlayer.play(DeviceFileSource("$_mPath/flutter_sound.mp3"));

    // int result = await audioPlayer.play(, isLocal: true);
    // if (result != 1) {
    //   messageError(context, stringMp3Write3);
    // }


  }catch(ex){
    messageError(context, ex.toString());
  }
}

playerIsPlaying() => audioPlayer.state == PlayerState.playing;

sendSound(BuildContext context, Function() _close) async {
  try{
    var tempDir = await getApplicationDocumentsDirectory();
    var _mPath = '${tempDir.path}/record';
    var d = Directory(_mPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    var _file = "$_mPath/flutter_sound.mp3";
    if (!File(_file).existsSync())
      return;

    dprint("getsound отправляем файл =$_file", color: "cyan");

    var _prefs = await SharedPreferences.getInstance();
    //
    var request = http.MultipartRequest("POST", Uri.parse(addressAPI));
    // request.headers.addAll(requestHeaders);
    var pic = await http.MultipartFile.fromPath("file", _file);
    request.fields['action'] = 'getsound';
    request.fields['module'] = 'apk';
    request.fields['appid'] = _prefs.getString('appid') ?? '0';
    if (Platform.isAndroid)
      request.fields['apk_key'] = await getDeviceDetails();
    if (Platform.isIOS)
      request.fields['ios_key'] = await getDeviceDetails();

    request.files.add(pic);

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    dprint("getsound responseString=$responseString", color: "cyan");
    dprint("getsound response.statusCode=${response.statusCode}", color: "cyan");
    if (response.statusCode == 200) {
      final body = convert.jsonDecode(responseString);
      var backUrl = body["backurl"];
      dprint("backUrl=$backUrl", color: "cyan");
      if (backUrl.isEmpty)
        messageError(context, "Error: API getsound => backUrl isEmpty");
      else {
        // messageOk(context, "Данные отправлены");
        openBrowser(backUrl);
        _close();
      }
    }else
      messageError(context, "statusCode=${response.statusCode}");
  }catch(ex){
    messageError(context, "getsound " + ex.toString());
  }
}

