import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:constyle/utils.dart';
import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'browser.dart';
import 'config.dart';
import 'dialog_cache_files.dart';
import 'firebase_options.dart';
import 'model/cache.dart';
import 'model/download_file.dart';
import 'log_in.dart';
import 'model/gps.dart';
import 'model/notify.dart';
import 'model/offline_storage.dart';
import 'model/orientation.dart';
import 'model/signin.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart' as ui;

late SharedPreferences prefs;
String restart = "";
String imgversion = "";
String splashImage = "";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (firebaseEnable)
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await initDB();
  dprint2("AppStart", color: "blue");
  dprint2(await getAppInfo());

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle( /// прозрачный status bar
    statusBarColor: Colors.transparent, // status bar color
    // systemNavigationBarColor: Colors.transparent, // navigation bar color
  ));

  if (firebaseEnable)
    await firebaseInitApp();
  startOrientation();
  await registerDownloader();
  readLocalStorageSessionFile();
  prefs = await SharedPreferences.getInstance();
  await initCacheDir();
  await serverResponseData.loadParameters();
  countCacheFiles = await getCacheHtmlFilesCount();
  getSaveToCache();
  try {
    if (serverResponseData.site.isNotEmpty){
      dprint("serverResponseData.site=${serverResponseData.site}");
      mainAddress = serverResponseData.site.substring(0, serverResponseData.site.length - 1);
      setIndexPhp();
    }
  }catch(ex){
    dprint("main $ex");
  }
  imgversion = serverResponseData.imgversion;
  var directory = await getApplicationDocumentsDirectory();
  noInternetInCache = "${directory.path}/appinternet.jpg";
  noInternetCacheInCache = "${directory.path}/appcache.jpg";
  splashImage = "${directory.path}/splashImage.jpg";
  // initStat(mainAddress, "1.0");
  dprint2("Старт", color: "blue");
  // runApp(Phoenix(child: const ShopMileApp()));
  runApp(const RestartWidget(
      child: ShopMileApp()));
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({Key? key, required this.child}) : super(key: key);

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

class ShopMileApp extends StatelessWidget {
  const ShopMileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    startRestart = false;
    dprint("ShopMileApp build");
    initCache(context);
    return GetMaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        ui.Locale('ru'),
        ui.Locale('en'),
      ],
      locale: const Locale("ru"),
      theme: ThemeData(
        platform: Platform.isIOS ? TargetPlatform.iOS : TargetPlatform.android,
        primarySwatch: Colors.blue,
        // brightness: Brightness.light,
        // useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoWillPopScopePageTransionsBuilder(),
          },
        ),
      ),
      home: const ShopMileAppHomePage(),
    );
  }
}

class ShopMileAppHomePage extends StatefulWidget {
  const ShopMileAppHomePage({Key? key}) : super(key: key);

  @override
  _ShopMileAppHomePageState createState() => _ShopMileAppHomePageState();
}

class _ShopMileAppHomePageState extends State<ShopMileAppHomePage> {

  @override
  void initState() {
    dprint2("Splash screen start", color: "blue");
    Future.delayed(const Duration(milliseconds: 6000), () {
      determinePosition();
    });
    _wait();
    if (File(splashImage).existsSync())
      logoImage = splashImage;
    super.initState();
  }

  String logoImage = "";

  _wait() async {
    Route route;

    restart = prefs.getString("restart") ?? "";
    if (restart == "true")
      prefs.setString("restart", "");

    if (restart != "true")
      await Future.delayed(const Duration(seconds: 3));
    else
      await Future.delayed(const Duration(milliseconds: 40));
    route = MaterialPageRoute(builder: (context) => const LoginPage());
    dprint2("Запускаем главный экран", color: "blue");
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    if (restart == "true")
      return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container()
      );

    // serverResponseData.firstcover = "YES";
    return Scaffold(
      backgroundColor: constFirstbg,
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              // 4. firstcover – YES или NO, это настройка для картинки первого экрана—
              //  закрывает она весь экран или ставится по ширине.
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    child: logoImage.isNotEmpty
                        ? Image.file(File(logoImage), fit: serverResponseData.firstcover == "YES"
                              ? BoxFit.cover : BoxFit.contain,
                          errorBuilder: (
                              BuildContext context,
                              Object error2,
                              StackTrace? stackTrace,
                              ){
                            return Image.asset(logoFile, fit: BoxFit.contain,);
                          },
                        )
                        : Image.asset(logoFile, fit: serverResponseData.firstcover == "YES"
                        ? BoxFit.cover : BoxFit.contain,)

                )
            ),
          ),
          Center(child: Container(
            margin: EdgeInsets.only(top: Get.height*0.85),
            child: loaderWidget
          ))
        ],
      )
    );
  }
}

loadImageFileNoInternet() async {
  try {
    var response = await http.get(Uri.parse(addressNoInternetImage),);
    if (response.statusCode == 200)
      await File(noInternetInCache).writeAsBytes(response.bodyBytes);
  }catch(ex){
    dprint("_loadImageFileNoInternet1 $ex");
  }

  try {
    var response = await http.get(Uri.parse(addressNoInternetImageCache),);
    if (response.statusCode == 200)
      await File(noInternetCacheInCache).writeAsBytes(response.bodyBytes);
  }catch(ex){
    dprint("_loadImageFileNoInternet2 $ex");
  }

  try {
    var response = await http.get(Uri.parse(addressAppFirst),);
    if (response.statusCode == 200)
      await File(splashImage).writeAsBytes(response.bodyBytes);
  }catch(ex){
    dprint("_loadImageFileNoInternet2 $ex");
  }
}

bool debugNoSave = true;
setSaveToCache() {
  prefs.setString("saveToCache", debugNoSave.toString());
}

getSaveToCache() {
  var t = prefs.getString("saveToCache");
  if (t == "false")
    debugNoSave = false;
}