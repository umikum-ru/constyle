import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:constyle/model/token.dart';
import 'package:constyle/model/signin.dart';
import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:constyle/config.dart';

String _path = "";

String getCachePath() {
  // dprint("getCachePath=$_path");
  return _path;
}

initCacheDir() async{
  return await _getDirectory();
}

_getDirectory() async {
  dprint("_getDirectory");
  if (_path.isEmpty) {
    var directory = await getApplicationDocumentsDirectory();
    _path = directory.path + "/webcache";
  }
  var dir = Directory(_path);
  if (!dir.existsSync())
    await dir.create();
  dprint("_getDirectory _path=$_path");
}

// bool _initializedSignIn = false;

cacheDeleteAll(){
  try {
    _getDirectory();
    final dir = Directory(_path);
    dir.deleteSync(recursive: true);
    _settings = SettingsData(cache: [], content: "");
  }catch(ex){
    dprint("cacheDeleteAll: $ex");
  }
}

// true если кэш удален
Future<bool> cacheCheckTimeStamp(BuildContext context) async{
  // _initializedSignIn = true;
  if (!settingsInitialized)
    if (!(await _loadCache(context)))
      return false;
  if (_settings.content != serverResponseData.content){ // удаляем весь кэш
    _getDirectory();
    final dir = Directory(_path);
    dir.deleteSync(recursive: true);
    _settings = SettingsData(cache: [], content: "");
    return true;
  }else
    await _reloadNullImageFiles();
  return false;
}

var _needClearCacheFolder = true;

_clearCacheFolder() async {
  if (!_needClearCacheFolder)
    return;
  _needClearCacheFolder = false;

  try {
    var list = Directory(_path).listSync().whereType<File>();
    for (var item in list) {
      if (item.path.endsWith(".json"))
        continue;
      // print("clearCacheFolder = $item");
      var name = getFileName(item.path);
      var found = false;
      for (var c in _settings.cache){
        // print("clearCacheFolder = ${c.localFile}");
        if (c.localFile == name) {
          found = true;
          break;
        }
      }
      if (!found) {
        dprint("delete file $item", color: "red");
        item.delete();
      }
    }

    //
  }catch(ex){
    dprint("_clearCacheFolder $ex", color: "red");
  }
}

List<String> _inProcess = [];

Future<bool> saveToCache(String url2, String body, BuildContext context, Function() redrawWindow) async {
  var url = mainAddress + "/";
  // <meta name="pageurl" content="remont-tehniki/vskritie-mashin/">

  var whatFind1 = "<meta name=\"pageurl\" content=\"";
  var indexStart = body.indexOf(whatFind1);
  if (indexStart == -1) {
    dprint("--cache--> not found 'meta name=pageurl' url=$url");
    return false;
  }
  indexStart += whatFind1.length;
  var i2 = body.indexOf("\"", indexStart);
  var t2 = body.substring(indexStart, i2);
  url += t2;

  if (url != url2){
    dprint("--cache--> Warning. url!=url2 url=$url url2=$url2");
  }

  if (body.contains("net::ERR_INTERNET_DISCONNECTED")) {
    dprint("--cache--> saveToCache net::ERR_INTERNET_DISCONNECTED", color: "yellow");
    return false;
  }
  await _getDirectory();
  //
  if (!settingsInitialized)
    if (!(await _loadCache(context)))
      return false;

  // debug
  var t = "_inProcess=";
  for (var item in _inProcess)
    t += "$item --";
  dprint(t, color: "red");

  if (_inProcess.contains(url)) {
    dprint("--cache--> already in process $url", color: "red");
    return false;
  }

  _inProcess.add(url);

  // проверка на чистоту папка с кэшем
  await _clearCacheFolder();
  // проверяем все jpg png gif файлы. Если размер 0 - перезагружаем
  await _reloadNullImageFiles();

  // проверяем есть ли в кеше этот файл
  for (var item in _settings.cache)
    if (item.url == url) {
      dprint("HTML Файл уже в кеше $url", color: "red");
      return false;
    }

  dprint("--cache--> saveToCache $url", color: "yellow");

  redrawWindow();

  try {
    body = _cutDynamic(body); /// вырезаем <div mode="online">

    body = await _doWork(body, "<link rel=\"stylesheet\" type=\"text/css\" href=\"");
    body = await _doWork(body, "<link rel=\"stylesheet\" href=\"");
    body = await _doWork(body, "<link rel=\"icon\" href=\"");
    body = await _doWork(body, "style=\"background: url(&quot;", endWith: "&quot;)");
    body = await _doWork(body, "<source src=\""); // mp3, wav

    body = await _doWork2(body, "<img ", "src=\"");
    body = await _doWork2(body, "<script ", "src=\"");

    for (var item in _settings.cache)
      if (item.url == url){
        _settings.cache.remove(item);
        break;
      }
    //body = body.replaceAll("/spectro-open-type", "/appid-${await getDeviceDetails()}");

    if (body.contains("<div data=\"online\">")){
      body = body.replaceAll("<div data=\"online\">", "<center><img src=\"{SITE}/spectro-cms-loading.gif\" width=\"50\" height=\"50\"></center><div style=\"display:none\">");
      String localFile = await saveOneFile("$mainAddress/spectro-cms-loading.gif");
      if (localFile.isNotEmpty)
        body = body.replaceAll("{SITE}/spectro-cms-loading.gif", localFile);
    }
    if (body.contains("view=\"online\"")){
      body = body.replaceAll("view=\"online\"", "style=\"display:none\"");
    }

    var file = await _saveFile(url, null, ext: '.html', dataString: body);
    dprint("--cache--> end url for $url [file=$file]", color: "yellow");
    await _reloadNullImageFiles();
  }catch(ex){
    dprint("--cache--> ERROR saveToCache " + ex.toString(), color: "red");
    //  isCachingProcess--;
    redrawWindow();
    _inProcess.remove(url);
    return false;
  }
  // isCachingProcess--;
  _inProcess.remove(url);
  redrawWindow();
  return true;
}

//
// Александр Constyle, [08.06.2024 11:01]
//
// Тут мы приходим к тому, что перед сохранение м в кэш, надо вырезать динамические вставки, которые всегда идут от:
//
// <div mode="online">
// до:
// <div id="end_of_dynamic"></div>
//
// Например это будет так:
// <div mode="online"> <ul class="spectro_menu">...
//  </ul>
// <div id="end_of_dynamic"></div></div>, надо вырезать из html:
// <div mode="online"><ul class="spectro_menu">...
//  </ul>
// <div id="end_of_dynamic"></div>
//
// И динамических вставок на странице может быть несколько, то есть ищём первый <div mode="online">, ищем ближайший
// к нему <div id="end_of_dynamic"></div>, потом ищем следующий <div mode="online">
//
String _cutDynamic(String body){
  try{
    var find1 = '''<div mode="online">''';
    var find2 = '''<div id="end_of_dynamic"></div>''';
    var indexStart = body.indexOf(find1);
    if (indexStart != -1) {
      var indexEnd = body.indexOf(find2, indexStart);
      if (indexEnd != -1) {
        indexEnd += find2.length;
        String t = body.substring(0, indexStart);
        String t2 = body.substring(indexEnd);
        return _cutDynamic(t+t2);
      }
    }
  }catch(ex){
    dprint("_cutDynamic $ex");
  }
  return body;
}

// <img src=\"

Future<String> _doWork2(String body, String whatFind1, String whatFind2, {String endWith = "\""}) async {
  // dprint("_doWork2 whatFind1=$whatFind1 $whatFind2");
  var indexStart = -1;
  var padding = 0;
  do {
    indexStart = body.indexOf(whatFind1, padding);
    if (indexStart != -1) {
      // var whatFind1t = body.substring(indexStart, indexStart+20);
      var t = body.indexOf(">", indexStart);
      indexStart += whatFind1.length;
      indexStart = body.indexOf(whatFind2, indexStart);
      // var t2 = body.substring(t, t+100);
      // dprint("t=$t indexStart=$indexStart");
      if (indexStart != -1 && (t == -1 || indexStart < t)) {
        indexStart += whatFind2.length;
        var indexEnd = body.indexOf(endWith, indexStart);
        if (indexEnd != -1) {
          String file = body.substring(indexStart, indexEnd);
          // if (!file.startsWith("https"))
          //   dprint("_saveOneFile whatFind1=$whatFind1 $whatFind2 indexStart=$indexStart $indexEnd file=$file");
          String localFile = await saveOneFile(file);
          if (localFile.isNotEmpty)
            body = body.replaceRange(indexStart, indexEnd, localFile);
          //indexStart = indexEnd;
          //dprint("--cache--> file=$file to $localFile", color: "yellow");
        }
      }else{
        dprint("--cache--> op", color: "yellow");
      }
    }
    padding = (indexStart+10);
  }while(indexStart != -1);
  return body;
}


Future<String> _doWork(String body, String whatFind, {String endWith = "\"", String url = ""}) async {
  var indexStart = -1;
  var padding = 0;
  do {
    indexStart = body.indexOf(whatFind, padding);
    if (indexStart != -1){
      indexStart += whatFind.length;
      var indexEnd = body.indexOf(endWith, indexStart);
      if (indexEnd != -1){
        String file = body.substring(indexStart, indexEnd);
        if (file.startsWith("./"))
          file = file.substring(2);
        bool _upOne = false;
        if (file.startsWith("../")){
          file = file.substring(3);
          _upOne = true;
          //dprint("--cache--> file=$file", color: "yellow");
        }
        if (url.isNotEmpty){
          var g = url.lastIndexOf("/");
          if (g != -1 && g+1 <= url.length){
            url = url.substring(0, g+1);
            if (_upOne){ // поднятся на один уровень выше (если можно)
              var u = Uri.tryParse(url);
              if (u != null && u.pathSegments.isNotEmpty){
                u.pathSegments.removeLast();
                url = u.toString();
              }
            }
            file = url + file;
          }
        }
        String localFile = await saveOneFile(file);
        if (localFile.isNotEmpty)
          body = body.replaceRange(indexStart, indexEnd, localFile);
        indexStart = indexEnd;
      }
    }
    padding = (indexStart+10);
  }while(indexStart != -1);
  return body;
}

Future<String> saveOneFile(String url) async{
  // if (url.contains("/spectro-js/spectro-open-type/"))
  //   url = url.replaceAll("spectro-open-type", "appid-${await getDeviceDetails()}");

  if (!url.contains("/spectro-js/spectro-open-type/"))
    for (var item in _settings.cache)
      if (item.url == url) {
        dprint("Файл уже в кеше $url", color: "red");
        return item.localFile;
      }

  try {
    var response = await http.get(Uri.parse(url),);

    if (response.statusCode == 200) {  //
      Uint8List body = response.bodyBytes;
      String t = response.body;

      String ret;
      if (url.contains("/spectro-js/")) {
        t = t.replaceAll("/cms-dynamic/spectro-open-type/",
            "/cms-dynamic/appid-${await getDeviceDetails()}/");
        // if (body.isEmpty)
        //   dprint("js spectro-open-type is empty", color: "red");
        // body = Uint8List.fromList(t.codeUnits);
        ret = await _saveFile(url, null, dataString: t);
      }else
        ret = await _saveFile(url, body);

      // if (t.contains("<div mode=\"online\">")){
        // t = t.replaceAll("<div mode=\"online\">", "<center><img src=\"{SITE}/spectro-cms-loading.gif\" width=\"50\" height=\"50\"></center><div style=\"display:none\">");
        //  String localFile = await saveOneFile("https://app.allmultimaster.com/spectro-cms-loading.gif");
        //  if (localFile.isNotEmpty)
        //    t = t.replaceAll("{SITE}/spectro-cms-loading.gif", localFile);
      // }

      // var body = Uint8List.fromList(t.codeUnits);
      //var ret = await _saveFile(url, null, dataString: t);
      // var ret = await _saveFile(url, null, dataString: t);
      dprint("--cache--> load ${response.statusCode} $url to $ret", color: "yellow");
      return ret;
    }else{
      // не удалось скачать файл
      // добавляем просто запись
      var _lastIndex = url.lastIndexOf(".");
      var _ext = url.substring(_lastIndex);
      var localFile = const Uuid().v4() + _ext;
      _settings.cache.add(FileData(url: url, localFile: localFile));
      _settings.content = serverResponseData.content;
      await File('$_path/settings.json').writeAsString(json.encode(_settings.toJson()));
    }
  }catch(ex){
    return "";
  }
  return "";
}

var settingsInitialized = false;
var _settings = SettingsData(cache: [], content: "");
List<FileData> _removedInThisSession = [];

Future<String> _saveFile(String url, Uint8List? data, {String ext = "", String dataString = ""} ) async {
  try {
    var _ext = ext;
    if (ext.isEmpty) {
      var _lastIndex = url.lastIndexOf(".");
      _ext = url.substring(_lastIndex);
    }
    if (_ext.contains("/"))
      _ext = "";
    if (_ext == ".css" && data != null){
      // dataString = await _doWork(String.fromCharCodes(data), 'background:url(./', endWith: ")", url: url);
      // Не кэшируются фоновые картинки из css вида:  url(../images/lock.png), сможешь поправить?
      dataString = await _doWork(String.fromCharCodes(data), 'background:url(', endWith: ")", url: url);
      data = null;
    }
    //
    var localFile = const Uuid().v4() + _ext;
    if (data != null)
      await File('$_path/$localFile').writeAsBytes(data);
    else
      await File('$_path/$localFile').writeAsString(dataString);
    // bool _found = false;
    // for (var item in _settings.cache)
    //   if (item.url == url){
    //     var fileToDelete = File('$_path/${item.localFile}');
    //     try {
    //       fileToDelete.deleteSync();
    //     }catch(ex){
    //       dprint("--cache--> Delete file: $fileToDelete $ex", color: "yellow");
    //     }
    //     item.localFile = localFile;
    //     _found = true;
    //     break;
    //   }
    // if (!_found)
    _settings.cache.add(FileData(url: url, localFile: localFile));
    _settings.content = serverResponseData.content;
    await File('$_path/settings.json').writeAsString(json.encode(_settings.toJson()));
    return localFile;
  }catch(ex){
    dprint("--cache--> " + ex.toString(), color: "red");
  }
  return "";
}

bool loadFromCache = true;

class SettingsData{
  SettingsData({this.startPage = "", required this.cache, required this.content});
  String startPage;
  String content;
  List<FileData> cache = [];

  Map toJson() => {
    'startPage' : startPage,
    'content': content,
    'files' : cache.map((i) => i.toJson()).toList(),
  };

  factory SettingsData.fromJson(Map<String, dynamic> data){

    List<FileData> _cache = [];
    if (data['files'] != null)
      for (var element in List.from(data['files'])) {
        _cache.add(FileData.fromJson(element));
      }

    return SettingsData(
        startPage: data["startPage"] ?? "",
        content: data["content"] ?? "",
        cache: _cache
    );
  }
}

class FileData{
  FileData({required this.url, required this.localFile,});
  String url;
  String localFile;

  Map toJson() => {
    'fileName' : url,
    'path' : localFile,
  };

  factory FileData.fromJson(Map<String, dynamic> data){
    return FileData(
      url: data["fileName"] ?? "",
      localFile: data["path"] ?? "",
    );
  }
}

String cacheReadUrlFile(BuildContext context, String url) {
  // dprint("--cache--> cacheReadUrlFile settingsInitialized=$settingsInitialized", color: "yellow");
  // if (!settingsInitialized)
  //   if (!(await _loadCache(context)))
  //     return "";
  dprint("--cache--> cacheReadUrlFile _settings.cache.length=${_settings.cache.length}", color: "yellow");
  for (var item in _settings.cache)
    if (item.url == url) {
      return "$_path/${item.localFile}";
    }
  return "";
}

Future<String> cacheReadFileByUrl(BuildContext context, String url) async {
  if (!settingsInitialized)
    if (!(await _loadCache(context)))
      return "";

  String str = "";
  try{
    for (var item in _settings.cache)
      if (item.url == url) {
        var _file = File('$_path/${item.localFile}');
        if (await _file.exists()) {
          str = await _file.readAsString();
          break;
        }
      }
  }catch(ex){
    dprint("--cache--> ERROR cacheReadFileByUrl " + ex.toString(), color: "red");
  }
  return str;
}

initCache(BuildContext context) async {
  if (!settingsInitialized)
    await _loadCache(context);
}

Future<bool> _loadCache(BuildContext? context) async {
  try {
    await _getDirectory();
    var _file = File('$_path/settings.json');
    if (await _file.exists()) {
      final contents = await _file.readAsString();
      var data = json.decode(contents);
      _settings = SettingsData.fromJson(data);
    }
    settingsInitialized = true;
    dprint("--cache--> _loadCache settingsInitialized=$settingsInitialized _settings.cache.length=${_settings.cache.length}", color: "yellow");
  }catch(ex){
    // messageError(context, "_loadCache $ex");
    return false;
  }
  return true;
}

Future<String?> loadCacheSource(BuildContext context, String name) async {
  try {
    var _file = File(name);
    if (await _file.exists()) {
      return await _file.readAsString();
    }
  }catch(ex){
    messageError(context, "loadCacheSource $ex");
    return null;
  }
  return null;
}

Future<String> cacheDeleteCurrentPage(String lastCacheFileName) async{
  dprint("--cache--> cacheDeleteCurrentPage $lastCacheFileName", color: "yellow");
  String localFile = basename(lastCacheFileName);
  if (lastCacheFileName.isEmpty || localFile.isEmpty) {
    dprint("--cache--> cacheDeleteCurrentPage is Empty -$lastCacheFileName-", color: "yellow");
    return "";
  }
  try {
    for (var item in _settings.cache)
      if (item.localFile == localFile) {
        try {
          File(lastCacheFileName).deleteSync();
        }catch(ex){
          dprint("--cache--> cacheDeleteCurrentPage " + ex.toString(), color: "red");
        }
        dprint("--cache--> Delete file: $lastCacheFileName", color: "yellow");
        _removedInThisSession.add(item);
        _settings.cache.remove(item);
        await File('$_path/settings.json').writeAsString(json.encode(_settings.toJson()));
        dprint("--cache--> cacheDeleteCurrentPage success", color: "yellow");
        return item.url;
      }
  }catch(ex){
    dprint("--cache--> cacheDeleteCurrentPage " + ex.toString(), color: "red");
  }
  return "";
}

Future<String> cacheDeletePageFromCache(String path) async{
  dprint("--cache--> cacheDeletePageFromCache $path", color: "yellow");
  if (path.isEmpty) {
    dprint("--cache--> cacheDeletePageFromCache path is Empty", color: "yellow");
    return "";
  }
  try {
    for (var item in _settings.cache)
      if (item.url == path) {
        try {
          File("$_path/${item.localFile}").deleteSync();
        }catch(ex){
          dprint("--cache--> cacheDeletePageFromCache " + ex.toString(), color: "red");
        }
        dprint("--cache--> Delete file: ${item.localFile}", color: "yellow");
        _removedInThisSession.add(item);
        _settings.cache.remove(item);
        await File('$_path/settings.json').writeAsString(json.encode(_settings.toJson()));
        dprint("--cache--> cacheDeletePageFromCache success", color: "yellow");
        return item.url;
      }
  }catch(ex){
    dprint("--cache--> cacheDeletePageFromCache " + ex.toString(), color: "red");
  }
  return "";
}

String cacheGetOnlineUrlFromDeleted(String url){
  var fileName = getFileName(url);
  for (var item in _removedInThisSession)
    if (fileName == item.localFile)
      return item.url;
  return "";
}

getAllFiles(){
  return _settings.cache;
}

Future<String> cacheGetPath(String localFile) async {
  await _getDirectory();
  return "$_path/$localFile";
}

String cacheGetUrlByLocalFileFullPath(String localFile) {
  String? name = getFileName(localFile);
  if (name == null)
    return "";
  for (var item in _settings.cache)
    if (item.localFile == name)
      return item.url;
  return "";
}

Future<int> getCacheHtmlFilesCount() async {
  dprint("--cache--> getCacheHtmlFilesCount settingsInitialized=$settingsInitialized", color: "yellow");
  var count = 0;
  if (!settingsInitialized)
    if (!(await _loadCache(null)))
      return 0;
  dprint("--cache--> getCacheHtmlFilesCount _settings.cache.length=${_settings.cache.length}", color: "yellow");
  for (var item in _settings.cache)
    if (item.localFile.endsWith(".html") || item.localFile.endsWith(".htm"))
      count++;
  return count;
}

_reloadNullImageFiles() async{
  List<FileData> list = [];
  for (var item in _settings.cache)
    list.add(item);

  for (var item in list){
    //if (item.url.endsWith(".png") || item.url.endsWith(".gif") || item.url.endsWith(".jpg") || item.url.endsWith(".css")) {
    var file = File('$_path/${item.localFile}');
    if (!file.existsSync() || (await file.length()) == 0) {
      try {
        var response = await http.get(Uri.parse(item.url),);
        if (response.statusCode == 200) {
          var body = response.bodyBytes;
          await File('$_path/${item.localFile}').writeAsBytes(body);
          dprint("--cache--> reload file ${item.localFile} ${item.url}", color: "yellow");
        }
      }catch(ex){
        dprint("--cache--> reload file ${item.localFile} ${item.url} $ex", color: "red");
      }
    }
  }
  //}
}

String findInCacheByLocalAddress(String need){
  var local = getFileName(need);
  if (local == null)
    return "";
  if (settingsInitialized)
    for (var item in _settings.cache){
      if (item.localFile == local)
        return item.url;
    }
  return "";
}