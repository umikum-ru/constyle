import 'package:constyle/privacy.dart';
import 'package:constyle/shop/basket.dart';
import 'package:constyle/shop/shop_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';
import 'dialog_login.dart';
import 'model/signin.dart';
import 'news_screen.dart';
import 'shop/shop_screen.dart';
import 'utils.dart';

Widget nativeScreens(BuildContext context){

  Widget _item(String text, String route){
    return Container(
      padding: const EdgeInsets.all(15),
      child: InkWell(
          onTap: (){
            if (route == "exit"){
              userLogged.value = false;
              return;
            }
            if (route == "/webview/appmode.php?logout=1")
              userLogged.value = false;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewPage(route: route,),
              ),
            );
          },
          child: Row(
        children: [
          Container(width: 5, height: 5,
            color: Colors.grey,
          ),
          const SizedBox(width: 10,),
          Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400,
              color: serverResponseData.color),)
        ],
      )),
    );
  }


  if (serverResponseData.native != "YES")
    return Container();

  if (showNativeWindowsTabText.value == "Заказать")
    return const ShopPage();
  if (showNativeWindowsTabText.value == "basket")
    return const BasketScreen();
  if (showNativeWindowsTabText.value == "shop_item")
    return const ShopItemPage();
  if (showNativeWindowsTabText.value == "shop_item2")
    return const ShopItemPage2();

  if (showNativeWindowsTabText.value == "Позвонить")
    return const CallPage();

  if (showNativeWindowsTabText.value == "Новости")
    return const NewsScreen();

  if (showNativeWindowsTabText.value == "Игра")
    return GameScreen(url: serverResponseData.appgame,);

  if (showNativeWindowsTabText.value == "policy")
    return PrivacyScreen(callback: (){
      showNativeWindowsTabText.value = "Сервис";
    },);

  if (showNativeWindowsTabText.value == "Сервис")
    if (userLogged.value){
      List<Widget> nativeItems = [];
      for (var name in nativeMenuName.keys)
        nativeItems.add(_item(name, nativeMenuName[name] ?? ""));

      return  Container(
          width: Get.width,
          height: Get.height,
          color: bgcolor,
          child: Stack(
            children: [
              Container(
                  width: Get.width,
                  margin: const EdgeInsets.all(20),
                  child: Text("Кабинет", style: TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w800, color: serverResponseData.color,),
                    textAlign: TextAlign.center,)),
              Container(
                  margin: EdgeInsets.only(left: Get.width*0.2, top: Get.height*0.2),
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: nativeItems
                  // [
                  //   _item("Профиль", "/private/profile/"),
                  //   _item("История заказов", "/private/shophistory/"),
                  //  _item("Выход", "exit"),
                  // ],
                )),
            ],
          ));
    }else{
      return Container(
        width: Get.width,
        height: Get.height,
        color: bgcolor,
        child: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
              const DialogLogin(),
              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text("Зарегистрироваться", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400))
              ),
              const SizedBox(height: 20),
              InkWell(
                  onTap: (){
                    showNativeWindowsTabText.value = "policy";
                  },
                  child: const Text("Политика конфиденциальности", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400))
              ),

            ],
          )),
      );
    }
  // }

  return Container();
}


class CallPage extends StatefulWidget {
  const CallPage({Key? key}) : super(key: key);

  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: Get.width,
        height: Get.height,
        color: bgcolor,
        child: Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Позвонить", style: TextStyle(fontSize: 30),),
        const SizedBox(height: 30,),
        InkWell(onTap: (){
          final Uri phoneUrl = Uri(
            scheme: 'tel',
            path: serverResponseData.appphone,
          );
          launchUrl(Uri.parse(phoneUrl.toString()), mode: LaunchMode.externalApplication);
        },
          child: Image.asset("assets/call.png", width: 100,),
        )
      ],
    ),));
  }
}


class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _LoginState2 createState() => _LoginState2();
}

class _LoginState2 extends State<RegisterPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri("$mainAddress/private/registration/"))
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key, required this.route}) : super(key: key);

  final String route;

  @override
  _WebViewPage createState() => _WebViewPage();
}

class _WebViewPage extends State<WebViewPage> {

  @override
  void initState() {
    super.initState();
  }

  InAppWebViewController? webController;

  @override
  Widget build(BuildContext context) {

    var url = "$mainAddress/appmode/id${serverResponseData.getAppId()}"
        "/id${serverResponseData.userid}/";

    // url = "https://speakup.9lo.ru/appmode/id5415/id278/";dd
    // dprint("open: $url");
    return Scaffold(
      backgroundColor: Colors.white,
      body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(url)),
            onWebViewCreated: (controller) {
              // webController = controller;
              // webController!.loadUrl(urlRequest: URLRequest(url: Uri.parse("$mainAddress${widget.route}")));;
              // dprint("$mainAddress${widget.route}");
            },
          onLoadStart: (InAppWebViewController controller, Uri? url){
            if (url == null)
              return;
            dprint("url=${url.path}");
        },

      ),
    );
  }
}


class GameScreen extends StatefulWidget {
  const GameScreen({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  _GameScreenState2 createState() => _GameScreenState2();
}

class _GameScreenState2 extends State<GameScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url))
      ),
    );
  }
}

