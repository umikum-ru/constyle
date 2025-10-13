// 5. Дорабатываем механизм /offlinemode/.
// Если открывается /offlinesave/, то новая сессия должна автоматически создаваться, но в режиме автоматической оправки
// данных как post-запрос "getofflinedata". Это даже не сессия, а локальное хранилище, где данные накапливаются
// до момента успешной отправки. То есть, если я вручную захожу на /offlinemode/, создаю или продолжаю сессию, то работаем как
// и раньше – начинаем запускать js и отправка данных на сервер происходит вручную, а вот если я не заходил в /offlinemode/, а
// сразу делаю /offlinesave/, то сессия создаётся сама, но в режиме автоматической отправки любой полученной формы, и так же
// начинаем запускать js.
// При каждом срабатывании /offlinesave/ в режиме автоматической отправки, происходит попытка отправки данных
// как "getofflinedata" и если интернет есть и получен успешный json-ответ, то отправленные данные этой формы из кэша очищаем,
// если не удалось отправить данные, накапливаем их на устройстве и в фоновом режиме периодически пытаемся их отправить.
//
// Данные на сервер пытаемся отправить в той хронологии, как данные накапливались, если это не первая форма, то пытаемся отправить
// все предыдущие, а потом уже её.
// Переход на нужную страницу после обработки /offlinesave/ сейчас работает, ты из полученных в base64 параметрах берёшь
// ID страницы, чтобы потом передать в js, а на значение url ты переводишь после обработки.
// Вот только если работаем с автоматической отправкой post-данных на "getofflinedata", то на backurl из json-ответа переводить уже
// не надо, если backurl получен, значит это просто успешная передача и локальные данные этой формы можно удалить, а
// переводить на url из данных по base64.
// И отправляем в автоматическом режиме по одной форме, что получили в /offlinesave/, то и отправили на "getofflinedata".

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:constyle/config.dart';
import 'package:intl/intl.dart';
import 'package:constyle/browser.dart';
import 'package:constyle/model/send_files.dart';
import 'package:constyle/model/token.dart';
import 'package:constyle/qr_send.dart';
import 'package:constyle/utils.dart';
import 'dart:convert' as convert;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'log_sends.dart';

offlineStorageOnPageLoad(InAppWebViewController controller) async {
  if (_sessionData.data.isEmpty)
    return;
  var ids = "";
  List<String> list = [];
  for (var item in _sessionData.data) {
    if (item.id.isEmpty)
      continue;
    if (!list.contains(item.id))
      list.add(item.id);
  }
  for (var item in list) {
    if (ids.isNotEmpty)
      ids += "-";
    ids += item;
  }
  await controller.callAsyncJavaScript(functionBody: "Spectro_OfflineStart(\"$ids\", ${_sessionData.data.length});");
}

offlineLocalDataStart(String url, InAppWebViewController controller){
  // https://gruzovoz.siteconst.ru/offlinesave/YWRkdG9iYXNrZXQ6OjMtfC3Qn9C+0LrRg9C/0LrQsCAi0JPQu9Cw0LLQvdCw0Y8iLXwtaHR0cHM6Ly
  // 9ncnV6b3Zvei5zaXRlY29uc3QucnUvK3wrY29sLXwt0JrQvtC70LjRh9C10YHRgtCy0L4
  // tfC0xK3wrYTAyLXwt0KHQv9C+0YHQvtCxLXwt0KHQv9C+0YHQvtCxIDErfCs=/

  try{
    var uri = Uri.parse(url);
    var s = uri.pathSegments;
    if (s.isNotEmpty && s[0] != "offlinesave")
      return;

    var id = "";
    if (url.endsWith("/"))
      url = url.substring(0, url.length-1);
    var i = url.indexOf("/offlinesave/");
    url = url.substring(i+"/offlinesave/".length);
    dprint(url);
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    var t2 = stringToBase64.decode(url);
    var t3 = t2.split("-|-");
    if (t3.isNotEmpty){
      var t4 = t3[0].split("::");
      if (t4.length == 2){
        id = t4[1];
      }
    }
    var url2 = "";
    if (t3.length >= 3){
      url2 = t3[2];
      var t7 = url2.split("+|+");
      if (t7.isNotEmpty)
        url2 = t7[0];
    }
    if (id.isNotEmpty) {
      if (_sessionData.data.isEmpty){
        // новый
        _sessionData = LocalStorageDataItem(data: [
          LocalStorageDataItem(data: [],
              dateCreate: DateTime.now().toString(),
              dataCreateForSort: DateTime.now(), data2: url, id: id)
        ], dateCreate: DateTime.now().toString(),
            dataCreateForSort: DateTime.now(), );
      }else{
        //_sessionData.data2 = id;
        _sessionData.data.add(LocalStorageDataItem(data: [],
            dateCreate: DateTime.now().toString(),
            dataCreateForSort: DateTime.now(), data2: url, id: id));
      }
      _writeSessionFile();
    }
    if (url2.isNotEmpty)
      openBrowser(url2);

  }catch(ex){
    dprint("offlineLocalDataStart $ex");
  }
}

String? saveQrOfflineStorage(String qr, String param){
  try{
    // if (_sessionData.data.isEmpty){
    //   return "Сессия не началась";
    // }else{
      _sessionData.data.add(LocalStorageDataItem(data: [],
          dateCreate: DateTime.now().toString(),
          dataCreateForSort: DateTime.now(),
          param: param,
          data2: qr, isQRCode: true));
    // }
    _writeSessionFile();
  }catch(ex){
    return "saveQrOfflineStorage $ex";
  }
  return null;
}

saveFileOfflineStorage(String path, String params){
  try{
    // if (_sessionData.data.isEmpty){
    //   return "Сессия не началась";
    // }else{
      _sessionData.data.add(LocalStorageDataItem(data: [],
          dateCreate: DateTime.now().toString(),
          param: params,
          dataCreateForSort: DateTime.now(), data2: path, isFile: true));
    // }
    _writeSessionFile();
  }catch(ex){
    return "saveQrOfflineStorage $ex";
  }
}

var _sessionData = LocalStorageDataItem(data: [], dataCreateForSort: DateTime.now());

Future<String?> _writeSessionFile() async {
  try {
    var directory = await getApplicationDocumentsDirectory();
    var t = _sessionData.toJson();
    await File('${directory.path}/localStorage.json').writeAsString(json.encode(t));

  }catch(ex){
    return ex.toString();
  }
  return null;
}

Future<String?> readLocalStorageSessionFile() async {
  try {
    var directory = await getApplicationDocumentsDirectory();
    var _file = File('${directory.path}/localStorage.json');
    if (await _file.exists()) {
      var str = await _file.readAsString();
      var data = json.decode(str);
      _sessionData = LocalStorageDataItem.fromJson(data);
    }
  }catch(ex){
    return ex.toString();
  }
  Timer.periodic(const Duration(seconds: 5),
        (Timer timer) async {
          if (_inProcess)
            return;
          _inProcess = true;
          for (var item in _sessionData.data){
            if (item.isQRCode) {
              var ret = await sendCodeOffline(item.data2, item.param);
              if (ret == null) {
                _sessionData.data.remove(item);
                _writeSessionFile();
              }
              break;
            }
            if (item.isFile) {
              var ret = await sendFileOfflineMode(item.data2, item.param);
              if (ret == null) {
                _sessionData.data.remove(item);
                _writeSessionFile();
              }
              break;
            }
            var ret = await _sendOffline(item.data2);
            if (ret == null) {
              _sessionData.data.remove(item);
              _writeSessionFile();
            }
            break;
          }
          _inProcess = false;
    },);
  return null;
}

bool _inProcess = false;

class LocalStorageDataItem{
  LocalStorageDataItem({required this.data, this.dateCreate = "",
    this.isFile = false, this.isQRCode = false, this.data2 = "", this.param = "",
    this.id = "",
    required this.dataCreateForSort});

  String dateCreate;
  DateTime dataCreateForSort;
  List<LocalStorageDataItem> data;
  bool isFile;
  bool isQRCode;
  String param;
  String data2;
  String id;

  Map toJson() => {
    'data' : data.map((i) => i.toJson()).toList(),
    'dateCreate': dateCreate,
    'isFile': isFile,
    'isQRCode': isQRCode,
    'data2' : data2,
    "param": param,
    "id": id
  };

  factory LocalStorageDataItem.fromJson(Map<String, dynamic> data){

    List<LocalStorageDataItem> _cache = [];
    if (data['data'] != null)
      for (var element in List.from(data['data'])) {
        _cache.add(LocalStorageDataItem.fromJson(element));
      }

    List<String> ids = [];
    if (data['ids'] != null)
      for (var element in List.from(data['ids'])) {
        ids.add(element.toString());
      }

    var dateCreate = data["dateCreate"] != null ? data["dateCreate"].toString() : "";
    DateTime dataCreateForSort = DateTime.parse(dateCreate);

    return LocalStorageDataItem(
      dataCreateForSort: dataCreateForSort,
      dateCreate: dateCreate,
      data: _cache,
      isFile: data["isFile"],
      isQRCode: data["isQRCode"],
      data2: data["data2"],
      param: data["param"],
      id: data["id"],
    );
  }

}

Future<String?> _sendOffline(String data) async {
  try{
    var _prefs = await SharedPreferences.getInstance();

    ///  – в виде строки вида «2023.01.17 - 13:00», чтоб потом отсортировать можно было
    final formatter = DateFormat('yyyy.MM.dd - HH:mm');
    var date = formatter.format(DateTime.now());

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    data = stringToBase64.decode(data);

    var _body = {
      'action': 'getofflinedata',
      'module': 'apk',
      //'add':
      'appid': _prefs.getString('appid') ?? '0',
      if (Platform.isAndroid)
        'apk_key': await getDeviceDetails(),
      if (Platform.isIOS)
        'ios_key': await getDeviceDetails(),
      'datetime': date,
      'data': data
    };
    dprint("offline посылаем addressAPI=$addressAPI =$_body ", color: "cyan");
    var response = await http.post(Uri.parse(addressAPI), body: _body);
    dprint("offline response.statusCode=${response.statusCode}", color: "cyan");
    if (response.statusCode == 200) {
      final body = convert.jsonDecode(response.body);
      var answer = body["answer"];
      addLogResponse("getofflinedata", answer);
      return null;
    }else
      return "offline send statusCode=${response.statusCode}";
  }catch(ex){
    return "offline send $ex";
  }
}


