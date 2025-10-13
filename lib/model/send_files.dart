import 'dart:io';
import 'package:constyle/browser.dart';
import 'package:http/http.dart' as http;
import 'package:constyle/model/token.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import '../config.dart';
import '../utils.dart';
import 'log_sends.dart';
import 'offline_storage.dart';


sendFiles(BuildContext context, String? url, String? params){
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) => StatefulBuilder(builder: (context, setState) {

        photo(ImageSource source) async {
          Navigator.pop(context);
          _sendFiles2(context, source, url, params);
        }

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Color(0xffF2F2F7),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const SizedBox(height: 5,),
                  buttonText("Открыть галерею", (){
                    photo(ImageSource.gallery);
                  }),
                  const SizedBox(height: 10,),
                  buttonText("Открыть камеру", (){
                    photo(ImageSource.camera);
                  }),
                  const SizedBox(height: 25,),
                ],
              ),

            ],
          ),
        );
      })
  );
}

buttonText(String text, Function callback, {bool enable = true}){
  return Stack(
    children: [

      Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(15),
        child: Text(text, textAlign: TextAlign.center,),
      ),

      if (enable)
        Positioned.fill(
          child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                splashColor: Colors.white.withOpacity(0.2),
                onTap: (){
                  callback();
                }, // needed
              )),
        )

    ],
  );
}

_sendFiles2(BuildContext context, ImageSource source, String? url, String? params) async {
  var _prefs = await SharedPreferences.getInstance();

  try{
    List<XFile> images = [];

    // Pick multiple images
    if (source == ImageSource.camera){
      final pickedFile = await ImagePicker().pickImage(
          source: source);
      if (pickedFile == null)
        return;
      images.add(pickedFile);
    }else{
      images = await ImagePicker().pickMultiImage();
      if (images.isEmpty)
        return;
      // for (var item in images) {
      //   var fileSize = await item.length();
      //   print("Размер файла ${item.path} =$fileSize");
      // }
      // int length = images.length;
      // openBrowser("http://address.ru/?length=$length");
    }

    if (url != null && params != null) {
      openBrowser(url);
      for (var item in images)
        saveFileOfflineStorage(item.path, params);
      return;
    }

    for (var item in images){
      dprint("sendFiles отправляем файл=${item.path}", color: "cyan");

      var request = http.MultipartRequest("POST", Uri.parse(addressAPI));
      var pic = await http.MultipartFile.fromPath("file", item.path);
      request.fields['action'] = 'getfile';
      request.fields['module'] = 'apk';
      if (params != null)
        request.fields['add'] = params;
      request.fields['appid'] = _prefs.getString('appid') ?? '0';
      if (Platform.isAndroid)
        request.fields['apk_key'] = await getDeviceDetails();
      if (Platform.isIOS)
        request.fields['ios_key'] = await getDeviceDetails();

      request.files.add(pic);

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      dprint("sendFile responseString=$responseString", color: "cyan");
      dprint("sendFile response.statusCode=${response.statusCode}", color: "cyan");
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(responseString);
        var answer = body["answer"];
        addLogResponse("getfile", answer);
      }else
        return messageError(context, "statusCode=${response.statusCode}");
    }
  }catch(ex){
    messageError(context, "sendFiles " + ex.toString());
    return;
  }
  // if (url == null)
  openBrowser("javascript:Spectro_Frame('spectro_images', 'cms-imgtemp/')");
}

Future<String?> sendFileOfflineMode(String path, String params) async {
  var _prefs = await SharedPreferences.getInstance();
  try{
    dprint("sendFiles отправляем файл=$path", color: "cyan");

    var request = http.MultipartRequest("POST", Uri.parse(addressAPI));
    var pic = await http.MultipartFile.fromPath("file", path);
    request.fields['action'] = 'getfile'; ///  getsound
    request.fields['module'] = 'apk';
    request.fields['add'] = params;
    request.fields['appid'] = _prefs.getString('appid') ?? '0';
    if (Platform.isAndroid)
      request.fields['apk_key'] = await getDeviceDetails();
    if (Platform.isIOS)
      request.fields['ios_key'] = await getDeviceDetails();

    request.files.add(pic);

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    dprint("sendFile responseString=$responseString", color: "cyan");
    dprint("sendFile response.statusCode=${response.statusCode}", color: "cyan");
    if (response.statusCode == 200) {
      final body = convert.jsonDecode(responseString);
      var answer = body["answer"];
      addLogResponse("getfile", answer);
      return null;
    }else
      return "statusCode=${response.statusCode}";
  }catch(ex){
    return "$ex";
  }
}