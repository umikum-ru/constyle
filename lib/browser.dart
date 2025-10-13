import 'dart:async';
import 'dart:io';
import 'package:constyle/permission.dart';
import 'package:constyle/progress_bar.dart';
import 'package:constyle/setting.dart';
import 'package:constyle/model/signin.dart';
import 'package:constyle/qr.dart';
import 'package:constyle/shop_in_web/shop_load.dart';
import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/cache.dart';
import 'config.dart';
import 'model/contacts.dart';
import 'model/download_file.dart';
import 'main.dart';
import 'model/permission_dialog.dart';
import 'model/notify.dart';
import 'model/offline_save.dart';
import 'model/offline_storage.dart';
import 'model/orientation.dart';
import 'model/send_files.dart';
import 'model/server_data.dart';
import 'sound_record_screen.dart';
import 'model/app_share.dart';

InAppWebViewController? webViewController;
var loadStopFirst = true;

final GlobalKey webViewKey = GlobalKey();
String? lastCacheFileName;
String _onAllowUrl = "";
var whiteScreen = false;
var whiteScreenUrl = "";

// openHTML(){
//   webViewController!.loadData(data: '''
//      <input type="file" multiple name="newimg[]">
//
//   ''');
// }

var _progress = 0;

openBrowser(String address) async{
  if (address.isEmpty)
    address = mainAddress + "/";
   // file:///https://gruzovoz.siteconst.ru/
  if (address.startsWith("file:///https://"))
    address = address.substring("file:///".length);

  if (Platform.isAndroid) {
    if (webViewController != null) {
      dprint("---------> openBrowser $address", color: "magents");
      webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(address)));
    }
  }
  if (Platform.isIOS){
    if (webViewController != null) {
      dprint("openBrowser open page $address controller.isLoading=${await webViewController!.isLoading()}");
      // if (_progress != 0 && _progress == 100){
      //   Timer.periodic(const Duration(seconds: 1),
      //         (Timer timer) async {
      //       dprint("Timer _progress=$_progress controller.isLoading=${await webViewController!.isLoading()}");
      //       if (_progress != 0 && _progress != 100)
      //         return;
      //       timer.cancel();
      //       dprint("Timer open url=$address");
      //       webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(address)));
      //     },);
      // }else
      webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(address)));
    }
  }
}

bool firstRun = true;
Timer? _timer;
bool _startLoadFromFile = false;
String _onLoadStartUrl = "";
// Timer? timer2;
String lastShouldOverrideUrl = "";

Widget browser(String url, BuildContext context, Function(String) redraw, Function() redrawWindow,
    PullToRefreshController pullToRefreshController){

  if (url.endsWith("appmode/id/id/"))
    url = mainAddress + "/";

  var str = cacheReadUrlFile(context, url.toString());
  if (str.isNotEmpty) {
    var _file = File(str);
    if (_file.existsSync()) {
      dprint("Файл найден [$str]", color: "green");
      _startLoadFromFile = true;
      url = str;
      lastCacheFileName ??= str;
      // lastCacheUrl = str;
    }
  }

  firstRun = false;

  Future<bool> _loadFromCache(String url, controller) async {
    if (url.contains(appModeUrl))
    // if (url.contains("/appmode/id")) // https://inside.onux.ru/appmode/id5407/id0/
      url = mainAddress + "/";
    dprint("---------> Ищем в кэше: $url");
    var str = cacheReadUrlFile(context, url.toString());
    if (str.isNotEmpty) {
      var _file = File(str);
      if (await _file.exists()) {
        dprint("---------> _loadFromCache Found $str");
        // if (onlyOffline){
        // Вместо 'mode=\"online\"' пишем 'style="display:none"', когда сохраняем в кэш?
        // Заменяем когда в стартовом меню нажали офлайн версия
        // str = await _isOfflineVersion(str);
        // }
        if (Platform.isAndroid) {
          controller.loadUrl(urlRequest: URLRequest(url: WebUri(str))); // scheme: "file", path: str)));
        }else{
          dprint("openBrowser open page $str controller.isLoading=${await webViewController!.isLoading()} _progress=$_progress");
          // if (timer2 != null && timer2!.isActive)
          //   timer2!.cancel();
          // if (_progress != 0 && _progress != 100 && (await webViewController!.isLoading())){
          //   timer2 = Timer.periodic(const Duration(seconds: 1),
          //         (Timer timer) async {
          //       dprint("Timer open page $str controller.isLoading=${await webViewController!.isLoading()} _progress=$_progress");
          //       if (_progress != 0 && _progress != 100 && (await webViewController!.isLoading()))
          //         return;
          //       timer.cancel();
          //       dprint("getCachePath=file://${getCachePath()}/");
          //       await controller.loadUrl(urlRequest: URLRequest(url: Uri(scheme: "file", path: str)),
          //           allowingReadAccessTo: Uri.parse("file://" + getCachePath() + "/")
          //       );
          //     },);
          // }else
          await controller.loadUrl(urlRequest: URLRequest(url: WebUri(str)), //Uri(scheme: "file", path: str)),
              allowingReadAccessTo: Uri.parse("file://" + getCachePath() + "/")
          );
        }
        lastCacheFileName = str;
        // lastCacheUrl = url;
        redraw(fromCache);
        noInternet = false;
        dprint("---------> _loadFromCache noInternet=$noInternet");
        return true;
      }else
        dprint("---------> _loadFromCache File Not Found");
    }else
      dprint("---------> _loadFromCache Cache Not found");
    return false;
  }

  _startTimer(){
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: timeForGreenCircleForDeleteCache),
          (Timer timer) {
        _timer?.cancel();
        source = "cacheEnd";
        redrawWindow();
      },);
  }

  _onLoadStart(String _url, InAppWebViewController controller) async{
    // noInCacheDialog = false;
    _onLoadStartUrl = _url;
    source = "server";
    dprint("_onLoadStart $_url");
    // if (_url == "file:///private/")
    //   dprint("file private ");

    if (serverResponseData.content == "0")
      return;

    if (_url.contains("/restart/")){
      restartApp(context);
      return;
    }
    if (_url.startsWith("file:///https://")) {
      try{
        openBrowser(_url.substring("file:///".length));
      }catch(_){}
    }

    if (!_url.startsWith("file:")) {
      if (Platform.isAndroid) {
        if (await _loadFromCache(_url, controller)) {
          redraw("");
          source = "cache";
          redrawWindow();
          _startTimer();
          return;
        }
      }
      source = "server";
      redraw("");
    }else{
      source = "cache";
      _startTimer();
    }
    dprint2("---------> onLoadStart $_url");
    redrawWindow();
  }

  _onLoadStop(_url, InAppWebViewController controller) async {

    if (loadStopFirst){
      loadStopFirst = false;
      dprint("AppFinish");
    }
    _url = _onLoadStartUrl;
    //await controller.evaluateJavascript(source: "document.getElementById('staticpages').innerHTML = '$countCacheFiles'; ");
    if (_url.contains("/restart/")){
      dprint("---------> OnLoadStop Не сохраняем [_url.contains(/restart/]");
      return;
    }
    if (serverResponseData.content == "0" || !debugNoSave) {
      dprint("---------> OnLoadStop Не сохраняем [serverResponseData.content=0]");
      return;
    }
    // if (_url.startsWith("file:"))
    //   lastCacheFileName = _url;
    if (!_url.startsWith("file:") && (source == "server")) {
      redraw("");
      if (await _saveToCache(controller, _url, context, redrawWindow)){
        noInternet = false;
        redrawWindow();
      }
    }else
      dprint("---------> OnLoadStop Не сохраняем");
  }

  var startUrl = !_startLoadFromFile ? URLRequest(url: WebUri(url))
      : URLRequest(url: WebUri(url)); //Uri(scheme: "file", path: url));

  return InAppWebView(
      key: webViewKey,
      pullToRefreshController: pullToRefreshController,
      initialUrlRequest: startUrl,
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            useOnLoadResource: true,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
          ),
          ios: IOSInAppWebViewOptions(
              allowsInlineMediaPlayback: true,
              allowingReadAccessTo: Uri.parse("file://" + getCachePath() + "/")
          )),
      onWebViewCreated: (controller) {
        webViewController = controller;
        if (pageForOpenFromNotify.isNotEmpty) {
        //   dprint("open url from notify: $pageForOpenFromNotify");
        //   var t = prefs.getString("notifyOpenpage");
        //   if (t != null) {
            openBrowser(pageForOpenFromNotify);
          //   prefs.setString("notifyOpenpage", "");
          // }
        }
        // if (mainAddress.isEmpty)
        //   webViewController?.loadFile(assetFilePath: "assets/preload/index.html");

      },
      onLoadStart: (InAppWebViewController controller, url) async {
        showProgressBar.value = true;
        progressBarValue.value = 0;
        progressBarColor.value = progressBarColorDefault;
        _onLoadStart(url.toString(), controller);
      },
      onLoadStop: (controller, url) async {
        // var t = await controller.getHtml();
        progressBarWork(controller);
        _onLoadStop(url.toString(), controller);
        if (whiteScreen){
          if (whiteScreenUrl != url.toString()){
            dprint("onLoadStop--> whiteScreenUrl=$whiteScreenUrl url=${url.toString()}");
            whiteScreenUrl = "";
            whiteScreen = false;
            redrawWindow();
          }
        }
      },
      onLoadHttpError: (InAppWebViewController controller, Uri? url,
          int statusCode, String description){
        dprint("---------> onLoadHttpError $url $statusCode", color: "red");
        // if (url != null && url.toString().contains("/appstaticmenu/") && statusCode == 404) {
        //   openBrowser(mainAddress);
        // }
        messageError(context, "HTTP error $statusCode");
      },
      androidOnPermissionRequest: (controller, origin, resources) async {
        return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT);
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        _dontSave = false;
        if (navigationAction.request.url.toString() != " null" &&
            navigationAction.request.url.toString() != "about:blank"
            && !navigationAction.request.url.toString().startsWith("file")
        ){
          lastShouldOverrideUrl = navigationAction.request.url.toString();
          dprint("_lastShouldOverrideUrl=$lastShouldOverrideUrl");
        }

        if (navigationAction.request.url.toString().startsWith("file")){
          var t = findInCacheByLocalAddress(navigationAction.request.url.toString());
          if (t.isNotEmpty)
            lastShouldOverrideUrl = t;
          dprint("_lastShouldOverrideUrl=$lastShouldOverrideUrl");
        }

        if (navigationAction.request.url == null)
          return NavigationActionPolicy.ALLOW;
        var uri = navigationAction.request.url!;

        if (uri.toString().contains("/restart/")){
          restartApp(context);
          return NavigationActionPolicy.CANCEL;
        }

        var t = uri.toString();
       // t = "https://tea.9lo.ru/apprefresh/?url=https://tea.9lo.ru/spectro.css";
       //  if (t.contains("/apprefresh/")){
       //    var pattern = "?url=";
       //    if (t.contains(pattern)) {
       //      try{
       //        var i = t.indexOf(pattern);
       //        if (i != -1){
       //          i += pattern.length;
       //          var str = t.substring(i);
       //          await cacheDeletePageFromCache(str);
       //          openBrowser(str);
       //          return NavigationActionPolicy.CANCEL;
       //        }
       //      }catch(ex){
       //        dprint("apprefresh $ex");
       //      }
       //    }
       //  }

        //t = "https://tea.9lo.ru/apphorizontal/?url=https://tea.9lo.ru/spectro.css";
        // И вот ещё, ты говорил что мы можем менять ориентацию экрана. Может тоже по таким ссылкам сделать?
        // https://tea.9lo.ru/apphorizontal/?url=https://tea.9lo.ru/somepage/ перевернёт экран горизонтально и перейдёт на https://tea.9lo.ru/somepage/
        // а https://tea.9lo.ru/appvertical/?url=https://tea.9lo.ru/somepage/ перевернёт экран вертикально и перейдёт на https://tea.9lo.ru/somepage/
        if (t.contains("/apphorizontal/")){
          var pattern = "?url=";
          if (t.contains(pattern)) {
            try{
              var i = t.indexOf(pattern);
              if (i != -1){
                i += pattern.length;
                var str = t.substring(i);
                if (makeLandscape())
                  openBrowser(str);
                return NavigationActionPolicy.CANCEL;
              }
            }catch(ex){
              dprint("apphorizontal $ex");
            }
          }
        }

        //t = "https://tea.9lo.ru/appvertical/?url=https://tea.9lo.ru/spectro.css";
        if (t.contains("/appvertical/")){
          var pattern = "?url=";
          if (t.contains(pattern)) {
            try{
              var i = t.indexOf(pattern);
              if (i != -1){
                i += pattern.length;
                var str = t.substring(i);
                if (makePortrait())
                  openBrowser(str);
                return NavigationActionPolicy.CANCEL;
              }
            }catch(ex){
              dprint("appvertical $ex");
            }
          }
        }

        if (uri.toString().contains("/offlinemode/")){
          openDialogOfflineMode(context);
          return NavigationActionPolicy.CANCEL;
        }

        if (uri.toString().contains("/offlinesave/")){
          offlineSave(uri.toString(), controller);
          return NavigationActionPolicy.CANCEL;
        }

        if (Platform.isIOS) {
          if (_onAllowUrl == uri.toString())
            if (uri.toString().startsWith(mainAddress)){
              dprint("---------> одинаковые адреса: не загружаем $uri = $_onAllowUrl");
              return NavigationActionPolicy.CANCEL;
            }
        }

        if (uri.toString().contains("/loadfiles/")) {
          var ps = uri.queryParameters;
          var url = ps["url"];
          var params = ps["params"];
          sendFiles(context, url, params);
          return NavigationActionPolicy.CANCEL;
        }

        if (uri.toString().contains("/qr-scanner/")) {
          openQr(context, uri, "/qr-scanner/");
          return NavigationActionPolicy.CANCEL;
        }
        if (uri.toString().contains("/line-scanner/")) {
          openQr(context, uri, "/line-scanner/");
          return NavigationActionPolicy.CANCEL;
        }
        if (uri.toString().contains("/view-scanner/")) {
          openQr(context, uri, "/view-scanner/");
          return NavigationActionPolicy.CANCEL;
        }

        if (uri.toString().contains("/appshare/?url=")) {
          try{
            var str = uri.toString();
            var index = str.indexOf("/appshare/?url=");
            index += "/appshare/?url=".length;
            str = str.substring(index);
            dprint("share: $str");
            Share.share(str);
          }catch(ex){
            messageError(context, ex.toString());
          }
          return NavigationActionPolicy.CANCEL;
        }

        if (uri.toString().contains("/appshare/?image=")){
          appShare(uri.toString(), context);
          return NavigationActionPolicy.CANCEL;
        }

        if (uri.toString().contains("/phonebook/")) {
          sendPhoneBook(context);
          return NavigationActionPolicy.CANCEL;
        }

        // if (uri.toString().contains("/audiorecord/")) {
        //   writeSound(context);
        //   return NavigationActionPolicy.CANCEL;
        // }

        if (uri.toString().startsWith("$mainAddress/files/")){
          startDownload(navigationAction.request.url.toString(), context);
          return NavigationActionPolicy.CANCEL;
        }

        if (!["http",
          "https",
          "file",
          "chrome",
          "data",
          "javascript",
          "about"].contains(uri.scheme)
        ) {
          launchUrl(uri, mode: LaunchMode.externalApplication,);
          return NavigationActionPolicy.CANCEL;
        }

        if (Platform.isIOS) {
          if (uri.toString().startsWith("file://")) {
            var f = File(uri.path);
            if (!f.existsSync()) {
              dprint("---------> Файл не найден $uri");
              controller.goBack();
              var str = cacheGetOnlineUrlFromDeleted(uri.toString());
              if (str.isNotEmpty) {
                dprint("---------> Нашли в удаленных. $str");
                openBrowser(str);
              }
              return NavigationActionPolicy.CANCEL;
            }
          }
        }

        if (serverResponseData.content != "0")
          if (!uri.toString().startsWith("file:")) {
            dprint("---------> shouldOverrideUrlLoading Смотрим есть ли в кэше");
            if (await _loadFromCache(uri.toString(), controller)) {
              redraw("");
              source = "cache";
              redrawWindow();
              _startTimer();
              return NavigationActionPolicy.CANCEL;
            }
          }

        _onAllowUrl = uri.toString();
        return NavigationActionPolicy.ALLOW;
      },

      onLoadError: (controller, url1, code, message) async {
        dprint("---------> onLoadError $code $message $url1");
        if (code == -2 && url1.toString().isNotEmpty) {
          whiteScreen = true;
          whiteScreenUrl = url1.toString();
          redrawWindow();
        }
        if (Platform.isIOS && code == -999)
          return;
        if (Platform.isIOS && (code == 1 || code == 102)) {
          await controller.loadData(data: "<html></html>");
          Future.delayed(const Duration(milliseconds: 100), () async {
            openBrowser(lastShouldOverrideUrl);
            _onAllowUrl = "";
          });
          _progress = 0;
          return;
        }

        if (serverResponseData.content != "0"){
          if (url1 != null ){
            String url = url1.toString();
            dprint("---------> onLoadError Адрес недоступен. Пытаемся загрузить из кэша $url");
            if (url.startsWith("file:")){
              dprint("---------> onLoadError Это и так кэш. Значит он недоступен. Пытаемся загрузить онлайн версию.");
              var str = cacheGetOnlineUrlFromDeleted(url);
              if (str.isNotEmpty){
                dprint("---------> onLoadError Нашли в удаленных. $str");
                openBrowser(str);
                return;
              }else {
                dprint("---------> onLoadError Не нашли в удаленных. $str");
                openBrowser(mainAddress);
              }
              return;
            }else {
              if (await _loadFromCache(url, controller)) {
                return;
              }else{
                // urlToOpenOnline = url.toString();
                openBrowser(mainAddress); /// открываем начальную страницу
                // noInCacheDialog = true;
              }
            }
          }
        }

        noInternet = true;
        dprint("---------> onLoadError noInternet=$noInternet");
        redrawWindow();
      },

      onProgressChanged: (controller, progress) {
        progressBarValue.value = progress;
        _progress = progress;
        dprint("---------> onProgressChanged $progress");
        if (progress == 100) {
          _isNeedPermissionFile(controller, context);
          offlineOnPageLoad(controller);
          offlineStorageOnPageLoad(controller);
        }
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        //_url = url.toString();
      },
      onConsoleMessage: (controller, ConsoleMessage consoleMessage) async {
        var msg = consoleMessage.message;
        // msg = "OpenPermissionScreen";
        // if (kDebugMode && first) {
        //   msg = "needPermissionContacts";
        //   first = false;
        // }

        /// MakeAppVertical  MakeAppHorizontal
        checkOrientation(msg);
        /// MakeAudioRecord
        if (msg == "MakeAudioRecord")
          writeSound(context);

        // apprefresh/?url=https://bnf.9lo.ru/
        var pattern = "apprefresh/?url=";
        if (msg.startsWith(pattern)){
          try{
            var str = msg.substring(pattern.length);
            dprint("apprefresh= $str");
            await cacheDeletePageFromCache(str);
            // openBrowser(str);
          }catch(ex){
            dprint("apprefresh $ex");
          }
        }
        if (msg == "OpenPermissionScreen")
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PermissionScreen(),
              ));

        if (msg == "CleanPush")
          await flutterLocalNotificationsPlugin.cancelAll(); // Cancelling/deleting all notifications
        if (msg == "needPermissionStorage")
          storagePermissionDialog();
        if (msg == "needPermissionContacts")
          contactsPermissionDialog();
        if (msg == "needPermissionGPS")
          gpsPermissionDialog();
        if (msg == "needPermissionMicrophone")
          microphonePermissionDialog();

        dprint("onConsoleMessage $consoleMessage");
      },
      onLoadResource: (InAppWebViewController controller, LoadedResource resource){
        //dprint("${resource.url}");
      },
      onLoadResourceCustomScheme: (InAppWebViewController controller, Uri url) async{
        dprint("$url");
        return null;
      }
  );
}

var first = true;

bool _request = false;

_isNeedPermissionFile(InAppWebViewController controller, BuildContext context,) async {
  var t = await controller.getHtml();
  if (t == null)
    return;

  if (t.contains('<meta name="sitemode" content="site">')) {
    restartApp(context);
    return;
  }

  if (t.contains("<!--{RESTART}-->")) {
    // var url = await controller.getUrl();
    restartApp(context);
  }

  if (t.contains("<!--{NATIVE[")) {
      //<!--{NATIVE[https://reciptorica.9lo.ru/goodslist.json]}-->
    loadShopList(t);
  }

  if (t.contains("<!--{APPFILE}-->")){
    if (_request)
      return;
    _request = true;
    if (await Permission.storage.isDenied){
      var m = prefs.getString("permission_2") ?? "";
      if (m == "later")
        return;
      /// диалог permission need
      bool t = await Navigator.of(Get.context!).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) {
            return const PermissionDialog(flag: 2,);
          },
        ),
      );
      if (t){
        await Permission.storage.request();
        await Permission.camera.request();
      }
    }
    _request = false;
  }
}

bool startRestart = false;

restartApp(BuildContext context) async {
  if (startRestart)
    return;
  startRestart = true;
  await prefs.setString("restart", "true");
  dprint("restartApp restart = ${prefs.getString("restart")}", color: "blue");

  serverResponseData = ServerResponseData();
  noInternet = false;
  waiting = true;
  goBack = false;
  source = "";
  firstRun = true;
  settingsInitialized = false;
  dprint("---------> restart settingsInitialized=$settingsInitialized");
  // noInCacheDialog = false;
  // Phoenix.rebirth(context);
  // Restart.restartApp();

  await Get.deleteAll(force: true);
  ///You can use normal context here within widget.
  // Phoenix.rebirth(Get.context!);
  RestartWidget.restartApp(context);
  Get.reset();

}

bool _dontSave = false;

Future<bool> _saveToCache(InAppWebViewController controller, String url, BuildContext context, Function() redrawWindow) async {
  if (mainAddress.isEmpty)
    return true;

  if (_dontSave){
    _dontSave = false;
    dprint("---------> _saveToCache _dontSave=true");
    return true;
  }

  var t = await controller.getHtml();

  if (t == null) {
    dprint("---------> _saveToCache controller.getHtml = null");
    return false;
  }

  if (!t.contains("spectro_data")) {
    dprint("---------> _saveToCache Страница не содержит spectro_data. Не кэшируем");
    return false;
  }

  if (!t.contains("spectro_appmenu")) {
    dprint("---------> _saveToCache Страница не содержит spectro_appmenu. Не кэшируем");
    return false;
  }

  if (t.contains("<!--{NOSTATIC}-->")) {
    dprint("---------> _saveToCache Страница содержит <!--{NOSTATIC}-->. Не кэшируем");
    return false;
  }
  if (t.contains('''<meta name="sitemode" content="app">''')) {
    dprint("---------> _saveToCache Страница содержит <meta name=\"sitemode\" content=\"app\">. Не кэшируем");
    return false;
  }
  if (t.contains("<!--{RESTART}-->")) {
    dprint("---------> _saveToCache Страница содержит <!--{RESTART}-->. Не кэшируем");
    return false;
  }
  dprint("---------> _saveToCache $url");
  if (t.length > 1000 || url.contains("/appstaticmenu/"))
    return await saveToCache(url, t, context, redrawWindow);
  else
    dprint("---------> ERROR t.length < 1000 url=$url");
  return false;
}


