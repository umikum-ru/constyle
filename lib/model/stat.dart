import 'dart:convert';
import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:universal_html/html.dart' as html;

import '../utils.dart';

String _serverPath = "https://www.abg-studio.com/stat/public/api/";
// String _serverPath = "http://localhost/stat/public/api/";
bool needStat = true;
bool needDebugText = false;
bool writeDebug = false;

class StatData{
  String appName = "";
  String appVersion = "";
  bool isAndroid = false;
  String androidId = "";
  String androidVer = "";
  bool isPhysicalDevice = true;
  // windows
  bool isWindows = false;
  String computerName = "";
  int numberOfCores = 0;
  int systemMemoryInMegabytes = 0;
  // web
  bool isWeb = false;
  String userAgent = "";
  //
  String pointName = "";
  String locale = "";
  bool debug = false;
  String time = "";
  String error = "";
  String internet = "";
  String screenSize = "";

  StatData({this.appName = "", this.appVersion = "", this.isAndroid = false, this.androidId = "",
    this.androidVer = "", this.isPhysicalDevice = false, this.isWindows = false, this.computerName = "",
    this.numberOfCores = 0, this.systemMemoryInMegabytes = 0, this.isWeb = false, this.userAgent = "",
    this.pointName = "", this.locale = "", this.debug = false, this.time = "", this.error = "",
    this.internet = "", this.screenSize = ""
  });

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'appVersion': appVersion,
    'isAndroid': isAndroid,
    'androidId': androidId,
    'androidVer': androidVer,
    'isPhysicalDevice': isPhysicalDevice,
    'isWindows': isWindows,
    'computerName': computerName,
    'numberOfCores': numberOfCores,
    'systemMemoryInMegabytes': systemMemoryInMegabytes,
    'isWeb': isWeb,
    'userAgent': userAgent,
    'pointName': pointName,
    'locale': locale,
    'debug': debug,
    'time': time,
    'error': error,
    'internet': internet,
    'screenSize': screenSize,
  };

  factory StatData.clone(StatData source){
    return StatData(
      appName: source.appName,
      appVersion: source.appVersion,
      androidId: source.androidId,
      isAndroid: source.isAndroid,
      androidVer: source.androidVer,
      isPhysicalDevice: source.isPhysicalDevice,
      isWindows: source.isWindows,
      computerName: source.computerName,
      numberOfCores: source.numberOfCores,
      systemMemoryInMegabytes: source.systemMemoryInMegabytes,
      isWeb: source.isWeb,
      userAgent: source.userAgent,
      pointName: source.pointName,
      locale: source.locale,
      debug: source.debug,
      time: source.time,
      error: source.error,
      internet: source.internet,
      screenSize: source.screenSize,
    );
  }

  factory StatData.fromJson(Map<String, dynamic> data){
    return StatData(
      appName: (data["appName"] != null) ? data["appName"] : "",
        appVersion: (data["appVersion"] != null) ? data["appVersion"] : "",
        isAndroid: (data["isAndroid"] != null) ? data["isAndroid"] : false,
        androidId: (data["androidId"] != null) ? data["androidId"] : "",
        androidVer: (data["androidVer"] != null) ? data["androidVer"] : "",
        isPhysicalDevice: (data["isPhysicalDevice"] != null) ? data["isPhysicalDevice"] : false,
        isWindows: (data["isWindows"] != null) ? data["isWindows"] : false,
        computerName: (data["computerName"] != null) ? data["computerName"] : "",
        numberOfCores: (data["numberOfCores"] != null) ? data["numberOfCores"] : 0,
        systemMemoryInMegabytes: (data["systemMemoryInMegabytes"] != null) ? data["systemMemoryInMegabytes"] : 0,
        isWeb: (data["isWeb"] != null) ? data["isWeb"] : false,
        userAgent: (data["userAgent"] != null) ? data["userAgent"] : "",
        pointName: (data["pointName"] != null) ? data["pointName"] : "",
        locale: (data["locale"] != null) ? data["locale"] : "",
        debug: (data["debug"] != null) ? data["debug"] : false,
        time: (data["time"] != null) ? data["time"] : "",
        error: (data["error"] != null) ? data["error"] : "",
        internet: (data["internet"] != null) ? data["internet"] : "",
        screenSize: (data["screenSize"] != null) ? data["screenSize"] : "",
    );
  }
}

var _statData = StatData();
List<StatData> queue = [];

bool _initialized = false;

initStat(String appName, String appVersion) async {
  if (!needStat)
    return;
  if (_initialized)
    return;
  _initialized = true;

  // if (kIsWeb) {
  //   html.window.onBeforeUnload.listen((event) async {
  //     addPoint("main_end");
  //   });
  //   html.document.addEventListener("visibilitychange", ((event) async{
  //     if (html.document.visibilityState == 'visible') {
  //       addPoint("background_end");
  //     } else {
  //       addPoint("background_start");
  //     }
  //   }));
  // }

  _statData.appName = appName;
  _statData.appVersion = appVersion;
  try{
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if (kIsWeb){
      WebBrowserInfo _deviceData = await deviceInfoPlugin.webBrowserInfo;
      _statData.isWeb = true;
      _statData.userAgent = "${_deviceData.userAgent}";
      // _statData.userAgent = "${_deviceData.vendor} ${_deviceData.userAgent} ${_deviceData.hardwareConcurrency}";
      // hardwareConcurrency - the number of logical processors available to run threads on the user's computer.
      // _deviceData.vendor - Either "Google Inc.", "Apple Computer, Inc.", or (in Firefox) the empty string.
      /*
            if (sUsrAg.indexOf("Firefox") > -1) {
              sBrowser = "Mozilla Firefox";
              // "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0"
            } else if (sUsrAg.indexOf("SamsungBrowser") > -1) {
              sBrowser = "Samsung Internet";
              // "Mozilla/5.0 (Linux; Android 9; SAMSUNG SM-G955F Build/PPR1.180610.011) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/9.4 Chrome/67.0.3396.87 Mobile Safari/537.36
            } else if (sUsrAg.indexOf("Opera") > -1 || sUsrAg.indexOf("OPR") > -1) {
              sBrowser = "Opera";
              // "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 OPR/57.0.3098.106"
            } else if (sUsrAg.indexOf("Trident") > -1) {
              sBrowser = "Microsoft Internet Explorer";
              // "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; .NET4.0C; .NET4.0E; Zoom 3.6.0; wbx 1.0.0; rv:11.0) like Gecko"
            } else if (sUsrAg.indexOf("Edge") > -1) {
              sBrowser = "Microsoft Edge (Legacy)";
              // "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 Edge/16.16299"
            } else if (sUsrAg.indexOf("Edg") > -1) {
              sBrowser = "Microsoft Edge (Chromium)";
              // Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.64
            } else if (sUsrAg.indexOf("Chrome") > -1) {
              sBrowser = "Google Chrome or Chromium";
              // "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/66.0.3359.181 Chrome/66.0.3359.181 Safari/537.36"
            } else if (sUsrAg.indexOf("Safari") > -1) {
              sBrowser = "Apple Safari";
              // "Mozilla/5.0 (iPhone; CPU iPhone OS 11_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.0 Mobile/15E148 Safari/604.1 980x1306"
            } else {
              sBrowser = "unknown";
            }
       */
    }else{
      if (Platform.isAndroid) {
        final String? androidId = await const AndroidId().getId();

        AndroidDeviceInfo _deviceData = await deviceInfoPlugin.androidInfo;
        _statData.isAndroid = true;
        // if (_deviceData.isPhysicalDevice != null)
          _statData.isPhysicalDevice = _deviceData.isPhysicalDevice;
        _statData.androidVer = _deviceData.version.release;
        if (androidId != null)
          _statData.androidId = androidId;
      }else{
        if (Platform.isIOS) {
          IosDeviceInfo _deviceData = await deviceInfoPlugin.iosInfo;
          if (needDebugText)
            dprint("identifierForVendor=${_deviceData.identifierForVendor}"); // уникальный идентифер
          if (needDebugText)
            dprint("isPhysicalDevice=${_deviceData.isPhysicalDevice}");
        }else{
          WindowsDeviceInfo _deviceData = await deviceInfoPlugin.windowsInfo;
          if (Platform.isWindows){
            _statData.isWindows = true;
            _statData.computerName = _deviceData.computerName;
            _statData.numberOfCores = _deviceData.numberOfCores;
            _statData.systemMemoryInMegabytes = _deviceData.systemMemoryInMegabytes;
          }
        }
      }
    }
  }catch(ex){
    //_addStat();
    dprint("InitStat " + ex.toString(), color: "red");
  }
  await addPoint("main_start");
  _sendLocalSaved();
}

Map<String, String> _requestHeaders = {
  'Content-type': 'application/json',
  'Accept': "application/json",
};

final _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
final _connectivity = Connectivity();

bool _inWork = false;

addPoint(String name, {String error = ""}) async {
  if (!needStat)
    return;

  var _data = StatData.clone(_statData);

  _data.locale = "no";
  _data.error = error;

  var _debug = false;
  assert(() {
    // ...debug-only code here...
       _debug = true;
       return true;
     }());

  _data.debug = _debug;
  if (!writeDebug && _debug)
    return;

  if (name == "main_start")
    _data.time = _formatter.format(DateTime.now().subtract(const Duration(seconds: 5)).toUtc());
  else
    _data.time = _formatter.format(DateTime.now().toUtc());
  _data.pointName = name;

  if (_inWork || _data.appName.isEmpty){
    if (needDebugText)
      dprint("queue.add ${_data.pointName}");
    queue.add(_data);
    return;
  }
  _inWork = true;
  await _doWork(_data);
  await _doQueue();
  _inWork = false;
}

_doQueue() async {
  if (needDebugText)
    dprint("_doQueue ${queue.length}");
  if (queue.isNotEmpty){
    if (needDebugText)
      dprint("_doQueue не пусто ${queue[0].pointName}");
    await _doWork(queue[0]);
    if (needDebugText)
      dprint("_doQueue ${queue.length}");
    var q = queue[0];
    var t = q.pointName;
    queue.remove(q);
    if (needDebugText)
      dprint("_doQueue remove $t");
    return await _doQueue();
  }
}

double _windowWidth = 0;
double _windowHeight = 0;

addScreenSize(double w, double h){
  _windowWidth = w;
  _windowHeight = h;
}

_doWork(StatData _data) async {
  if (_data.appName.isEmpty){
    _data.appName = _statData.appName;
    _data.appVersion = _statData.appVersion;
    _data.isWeb = _statData.isWeb;
    _data.userAgent = _statData.userAgent;
    _data.isAndroid = _statData.isAndroid;
    _data.isPhysicalDevice = _statData.isPhysicalDevice;
    _data.androidVer = _statData.androidVer;
    _data.isWindows = _statData.isWindows;
    _data.computerName = _statData.computerName;
    _data.numberOfCores = _statData.numberOfCores;
    _data.systemMemoryInMegabytes = _statData.systemMemoryInMegabytes;
  }
  var _internet = "";
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.mobile) {
      _internet = "mobile";
    } else if (result == ConnectivityResult.wifi) {
      _internet = "wifi";
    } else if (result == ConnectivityResult.bluetooth) {
      _internet = "bluetooth";
    } else if (result == ConnectivityResult.ethernet) {
      _internet = "ethernet";
    } else if (result == ConnectivityResult.none) {
      _internet = "none";
    }
  } on PlatformException catch (e) {
    if (needDebugText)
      dprint('Couldn\'t check connectivity status $e');
  }

  _data.internet = _internet;
  _data.screenSize = "${_windowWidth}x$_windowHeight";

  late http.Response response;
  var body = json.encoder.convert(_data.toJson()); //_getBody();
  var url = "${_serverPath}addStat";
  try{
    if (needDebugText)
      dprint("add point call server ${_data.pointName}");
    response = await http.post(Uri.parse(url), headers: _requestHeaders, body: body).timeout(const Duration(seconds: 30));
  }catch(ex){
    if (needDebugText)
      dprint("exception: save local ${_data.pointName}");
    await _saveLocal(_data);
    return;
  }

  if (needDebugText) {
    dprint('Response status: ${response.statusCode}');
    dprint('Response body: ${response.body}');
  }

  if (response.statusCode == 500) { // внутренняя ошибка сервера, тоже сохраним
    await _saveLocal(_data);
    //
    var jsonResult = json.decode(response.body);
    var body = json.encoder.convert({
      'pointName': "error",
      'error': jsonResult["message"]
    });
    var url = "${_serverPath}addStat500";
    response = await http.post(Uri.parse(url), headers: _requestHeaders, body: body).timeout(const Duration(seconds: 30));
    if (needDebugText) {
      dprint('Response status: ${response.statusCode}');
      dprint('Response body: ${response.body}');
    }
    return;
  }
  if (response.statusCode != 200)
    await _saveLocal(_data);
  else
    await _sendLocalSaved();
}

// _getBody(){
//   return json.encoder.convert({
//     'appName': _statData.appName,
//     'appVersion': _statData.appVersion,
//     'isAndroid': _statData.isAndroid,
//     'isPhysicalDevice': _statData.isPhysicalDevice,
//     'androidId': _statData.androidId,
//     'androidVer': _statData.androidVer,
//     'pointName': _statData.pointName,
//     //
//     'isWindows': _statData.isWindows,
//     'computerName': _statData.computerName,
//     'numberOfCores': _statData.numberOfCores,
//     'systemMemoryInMegabytes': _statData.systemMemoryInMegabytes,
//     //
//     'isWeb': _statData.isWeb,
//     'userAgent': _statData.userAgent,
//     //
//     'debug': _statData.debug,
//     'locale': _statData.locale,
//     'time': _statData.time,
//     'error': _statData.error,
//     'internet': _statData.internet,
//   });
// }

_sendLocalSaved() async {
  await _getLocal();
  if (_localData.isNotEmpty){
      var body = json.encoder.convert({
        'data': _localData.map((i) => i.toJson()).toList(),
      }); //_getBody();
      var url = "${_serverPath}addStatList";
      var response = await http.post(Uri.parse(url), headers: _requestHeaders, body: body).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200){
        _localData = [];
        await _saveLocal2();
      }
  }
  // for (var item in _localData){
  //   var body = json.encoder.convert(item.toJson()); //_getBody();
  //   var url = "${_serverPath}addStat";
  //   var response = await http.post(Uri.parse(url), headers: _requestHeaders, body: body).timeout(const Duration(seconds: 30));
  //   if (response.statusCode == 200){
  //     _localData.remove(item);
  //     await _saveLocal(null);
  //     Future<void>.delayed(Duration(seconds: 1));
  //     return _sendLocalSaved();
  //   }else
  //     return;
  // }
}

List<StatData> _localData = [];

_getLocal() async {
  _localData = [];

  work(_data){
    if (_data['data'] != null){
      for (var element in List.from(_data['data'])) {
        // dprint(element.toString());
        // dprint(element["id"]);

        var _newItem = StatData.fromJson(element);
        _localData.add(_newItem);
      }
    }
  }

  // if (kIsWeb) {
  //   MapEntry<String, String>? data;
  //   try {
  //     data = localStorage.entries.firstWhere((i) => i.key == "stat.json");
  //   } on StateError {
  //     data = null;
  //   }
  //   if (data != null) {
  //     var _data = json.decode(data.value) as Map<String, dynamic>;
  //     work(_data);
  //     if (needDebugText) {
  //       print("get local read ${_localData.length}");
  //       for (var item in _localData)
  //         print("------------->read ${item.pointName}");
  //     }
  //   }
  // }else{
    try{
      var directory = await getApplicationDocumentsDirectory();
      var directoryPath = directory.path;
      var _file = File('$directoryPath/stat.json');
      if (await _file.exists()){
        final contents = await _file.readAsString();
        var _data = json.decode(contents);
        work(_data);
      }
    }catch(ex){
      if (needDebugText)
        dprint("exception _getLocal $ex");
    }
  // }
}

_saveLocal(StatData? _data) async {
  // сначало читаем
  await _getLocal();

  if (_data != null) {
    _localData.add(_data); // добавляем
    if (needDebugText) {
      dprint("_saveLocal add ${_data.pointName}");
      for (var item in _localData)
        dprint("-------------> ${item.pointName}");
    }
  }

  if (needDebugText)
    dprint("_saveLocal2");
  await _saveLocal2();
}

_saveLocal2() async {
  // записываем
  // if (kIsWeb){
  //   try {
  //     localStorage.update(
  //       "stat.json",
  //           (val) {
  //         return json.encode({"data": _localData.map((i) {
  //           return i.toJson();
  //         }).toList()});
  //       },
  //       ifAbsent: () {
  //         return json.encode({"data": _localData.map((i) {
  //           return i.toJson();
  //         }).toList()});
  //       },
  //     );
  //   }catch(ex){
  //     if (needDebugText)
  //       dprint("_saveLocal stat $ex");
  //     return;
  //   }
  // }else {
    var directory = await getApplicationDocumentsDirectory();
    var directoryPath = directory.path;
    await File('$directoryPath/stat.json')
        .writeAsString(json.encode({"data": _localData.map((i) {
      var m = i.toJson();
      // dprint("$m");
      return m;
    }).toList()}));
  // }
}


// String _lastStat = "";

// statWork() async {
//   if (_lastStat == state)
//     return;
//
//   var _lastStat2 = _lastStat;
//   _lastStat = state;
//   var _state = state;
//
//   if (_lastStat2.isNotEmpty) {
//     if (needDebugText)
//       print("statWork ${_lastStat2}_end");
//     await addPoint("${_lastStat2}_end");
//   }
//
//   if (needDebugText)
//     print("statWork ${_state}_start");
//   await addPoint("${_state}_start");
// }
