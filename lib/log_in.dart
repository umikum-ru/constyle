import 'dart:async';
import 'dart:io';
import 'package:constyle/page2.dart';
import 'package:constyle/progress_bar.dart';
import 'package:constyle/shop_in_web/shop_widget.dart';
import 'package:constyle/widgets/button2.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:constyle/model/signin.dart';
import 'package:constyle/utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'debug_screens/all_files_screen.dart';
import 'bottom_bar.dart';
import 'browser.dart';
import 'dialog_login.dart';
import 'debug_screens/cache_source_screen.dart';
import 'config.dart';
import 'dialog_cache_files.dart';
import 'log_screen.dart';
import 'native_screens.dart';
import 'setting.dart';
import 'shop/shop_screen.dart';

var lastConnectivityResult = ConnectivityResult.none;
Function()? redrawMainWindow;
// bool _firstRun = true;
bool signInRun = false;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> with TickerProviderStateMixin{

  String? imageData;
  bool dataLoaded = false;
  String? mainurl;

  void setPrefs() async {
    dprint2("Определение типа интернета", color: "green");
    Connectivity().onConnectivityChanged.listen((ConnectivityResult connectivityResult) async {
      dprint2("listen: Тип интернета $connectivityResult", color: "green");
      if (lastConnectivityResult == connectivityResult)
        return;
      lastConnectivityResult = connectivityResult;
      if (connectivityResult != ConnectivityResult.none) {
        noInternet = false;
        //waiting = false;
        openBrowser(lastShouldOverrideUrl);
        _redraw();
      }else{
        dprint2("Интернет выключен. Начальную страницы с выбором онлайн/офлайн не показываем", color: "green");
        //dprint2("Показываем страницы только из кэша.", color: "green");
        await showDialogCacheFiles(context);
        //waiting = false;
        // onlyOffline = true;
        _redraw();
      }
    });
    waiting = false;
    // var connectivityResult = await Connectivity().checkConnectivity();
    // if (connectivityResult != ConnectivityResult.none) {
    //
    // }
  }

  Future<bool> _exitApp(BuildContext context) async {
    dprint("onWill Go Back");
    // if (isCachingProcess > 0) {
    //   messageOk(context, stringPleaseWait);
    //   return false;
    // }
    if (await webViewController!.canGoBack()) {
      dprint("onWill Go Back можно перейти назад");
      goBack = true;
      //if (webViewController != null && isCachingProcess <= 0) {
      if (webViewController != null) {
        var url = await webViewController!.getUrl();
        if (await webViewController!.canGoBack())
          webViewController!.goBack();
        if (url.toString().startsWith("file:") && mainAddress.isNotEmpty)
          webViewController!.goBack();
        if (url.toString().startsWith("https:") && noInternet)
          webViewController!.goBack();
        noInternet = false;
      }
    } else {
      dprint("No back history item. Exit from app", color: "red");
      if (serverResponseData.backclose == "YES")
        FlutterExitApp.exitApp();
      return true;
    }
    return false;
  }

  late PullToRefreshController pullToRefreshController;
  late TabController _tabController;
  var _index = 0;

  @override
  void initState() {
    ever(showNativeWindowsTabText, _redraw2);
    ever(userLogged, _redraw2);
    _tabController = TabController(vsync: this, length: 2);

    _tabController.addListener((){
      _index = _tabController.index;
      _redraw();
    });

    setPrefs();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
        pullToRefreshController.endRefreshing();
      },
    );
    redrawMainWindow = _redraw;

  // if (countCacheFiles == 0 && _firstRun)
  //   if (_firstRun)
      _init();

    super.initState();
  }

  _init() async {
    signInRun = true;
    dprint("login file _init");
    await singIn(authEnter, _showDialog, loginEnter, context, _redraw);

    ///  Про автоматическую перезагрузку я и раньше говорил, но тут смысл такой — приложение проверяет,
    ///  когда последний раз происходил regapp, и если это было более суток назад, запрашивать
    ///  regapp, если не удалось, выводить сообщение «Не удалось обновить данные.Возможно
    ///  информация устарела. Пожалуйста,
    /// проверьте соединения с Интернетом» - это окно можно будет закрыть.
    Timer.periodic(const Duration(hours: 23),
      (Timer timer) async {
        await singIn(authEnter, _showDialog, loginEnter, context, _redraw);
    },);

    signInRun = false;
    // _firstRun = false;
    redrawMainWindow!();
  }

  String _fromCacheText = "";

  _redraw(){
    if (mounted)
      setState(() {
      });
  }
  _redraw2(value){
    _redraw();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: mainViewBg,
        body: waiting ? Center(child: loaderWidget)
            :
        PopScope(
          canPop: false,
            onPopInvokedWithResult: (bool didPop, result){
            if (_index == 1){
              _tabController.animateTo(0);
              return;
            }
            _exitApp(context);
          },
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              _page1(),
              Page2Screen(animateTo0: (){
                _tabController.animateTo(0);
              }),
            ],
          )
    ));
  }

  Widget _page1(){
    double windowWidth = MediaQuery.of(context).size.width;
    double windowHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        if (!signInRun)
          Container(
            margin: EdgeInsets.only(top: serverResponseData.topmarging == "YES"
                ? MediaQuery.of(context).padding.top : 0,
                bottom: (showBottomBar && !noInternet) ? 60 : 0),
            child: browser(
                openLocal ? mainAddress + "/"
                    : getAddressTwoMode(),
                //"$mainAddress$appModeUrl${serverResponseData.appid}$appModeUrlUserId${serverResponseData.userid}/",

                  // "$mainAddress/appmode/id${serverResponseData.appid}/id${serverResponseData.userid}/",
                context, (String text){
              _fromCacheText = text;
              _redraw();
            }, _redraw, pullToRefreshController),
          ),

        if (_fromCacheText.isNotEmpty && showNoInternetRedBox)
          Container(
              margin: EdgeInsets.only(bottom: showBottomBar ? 60 : 0),
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                color: fromCacheBackgroundColor,
                child: Text(_fromCacheText, style: const TextStyle(color: Colors.white),),
              )),

        if (whiteScreen)
          Container(
            color: Colors.white,
          ),

        if (noInternet)
          Container(
              width: windowWidth,
              height: windowHeight,
              color: Colors.white,
              child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: windowWidth,
                        child: Image.file(File(noInternetInCache,), fit: BoxFit.contain,
                          errorBuilder: (
                              BuildContext context,
                              Object error2,
                              StackTrace? stackTrace,
                              ){
                            return Image.asset(noInternetImage, fit: BoxFit.contain, );
                          },
                        ),
                      ),
                      const SizedBox(height: 20,),
                      const Text("Нет соединения с сервером", style: TextStyle(fontSize: 18),),
                      const SizedBox(height: 20,),
                      Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: button2("Перезагрузить", (){
                            restartApp(context);
                          }))

                    ],
                  ))
          ),

        // if (showIndicators && !noInternet)
        // Container(
        //     alignment: Alignment.topRight,
        //     margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
                // if (isCachingProcess > 0)
                //   Container(
                //     margin: const EdgeInsets.all(10),
                //     width: 20,
                //     height: 20,
                //     child: Loader30(color: serverResponseData.textColor, size: 10),
                //   ),
                // const SizedBox(width: 5,),
                //if (isCachingProcess <= 0 && source == "cache" && !onlyOffline)
                // if (source == "cache")
                //   InkWell(
                //       onTap: () async {
                //         if (lastCacheFileName != null) {
                //           var ret = await cacheDeleteCurrentPage(lastCacheFileName!);
                //           if (ret.isNotEmpty)
                //             messageOk(context, "Кэш для $ret удален");
                //         }
                //       },
                //       child: Container(
                //           width: 30,
                //           height: 30,
                //           decoration: BoxDecoration(
                //             color: Colors.green.withAlpha(0),
                //             shape: BoxShape.circle,
                //           ),
                //           child: UnconstrainedBox(
                //               child: Container(
                //                 width: 10,
                //                 height: 10,
                //                 decoration: const BoxDecoration(
                //                   color: colorCacheIndicator,
                //                   shape: BoxShape.circle,
                //                 ),
                //               )
                //           ))),
        //         const SizedBox(width: 5,),
        //       ],
        //     )
        // ),

        // if (noInCacheDialog)
        //   screenOfflineMode(windowWidth, windowHeight),

        nativeScreens(context),

        if (showBottomBar && !noInternet)
          bottomBar(),

        // if (lastCacheFileName != null)
        //   Text(cacheGetUrlByLocalFileFullPath(lastCacheFileName!)),

        if (serverResponseData.appconsole == "YES")
          Container(
            margin: const EdgeInsets.only(top: 125, right: 5),
            alignment: Alignment.topRight,
            child: SizedBox(
                width: 100,
                child: button2("Console", (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LogScreen(),
                    ),
                  );
                }, )),
          ),

        if (serverResponseData.appsourse == "YES" && !noInternet &&
            source != "server"
            && lastCacheFileName != null
        )
          Container(
            margin: const EdgeInsets.only(top: 175, right: 5),
            alignment: Alignment.topRight,
            child: SizedBox(
                width: 100,
                child: button2("Source", (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CacheSourceScreen(fileName: lastCacheFileName!,),
                    ),
                  );
                }, )),
          ),

        if (serverResponseData.appfiles == "YES")
          Container(
            margin: const EdgeInsets.only(top: 225, right: 5),
            alignment: Alignment.topRight,
            child: SizedBox(
                width: 100,
                child: button2("All Files", (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllFilesScreen(),
                    ),
                  );
                }, )),
          ),

        // Container(
        //   margin: const EdgeInsets.only(top: 300, right: 5),
        //   alignment: Alignment.topRight,
        //   child: SizedBox(
        //       width: 100,
        //       child: button2("View Log", (){
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => const ResponseLogScreen(),
        //           ),
        //         );
        //       }, )),
        // ),

        // Container(
        //   margin: const EdgeInsets.only(top: 300, right: 5),
        //   alignment: Alignment.topRight,
        //   child: SizedBox(
        //       width: 100,
        //       child: button2("Pick file", () async {
        //         startWriteSound(context);
        //
        //         // sendPhoneBook(context);
        //
        //         // List<XFile>? image = await ImagePicker().pickMultiImage();
        //         // print(image);
        //       }, )),
        // ),

        // Container(
        //   margin: const EdgeInsets.only(top: 225, right: 5),
        //   alignment: Alignment.topRight,
        //   child: SizedBox(
        //       width: 100,
        //       child: button2("QR", (){
        //         // sendPhoneBook(context);
        //         openBrowser("$mainAddress/qr-scanner/");
        //         // openQr(context, Uri());
        //         //   openQr(context, Uri(), "/qr-scanner/");
        //         //   openQr(context, Uri(), "/line-scanner/");
        //         //   openQr(context, Uri(), "/view-scanner/");
        //         // restartApp(context);
        //       }, )),
        // ),

        // Container(
        //   margin: const EdgeInsets.only(top: 225, right: 5),
        //   alignment: Alignment.topRight,
        //   child: SizedBox(
        //       width: 100,
        //       child: button2("запись звука ", (){
        //         // sendPhoneBook(context);
        //         openBrowser("$mainAddress/audiorecord/");
        //         // openQr(context);
        //       }, )),
        // ),

        const NativeShopScreens(),

        if (wait || signInRun)
          Center(child: loaderWidget),

        ProgressBar(settings: (){
          _tabController.animateTo(1);
        },),

      ],
    );
  }

  _showDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return ScrollConfiguration(
          behavior: Behavior(),
          child: Dialog(
            backgroundColor: bgcolor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 16,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: const DialogLogin()
            ),
          ),
        );
      },
    );
  }
}

void authEnter(BuildContext context) async {
  await serverResponseData.saveUserId();
  showDialogCacheFiles(context);
}

void loginEnter(BuildContext context) async {
  await serverResponseData.saveAppId();
  showDialogCacheFiles(context);
}