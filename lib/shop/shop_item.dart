import 'dart:io';

import 'package:constyle/shop/shop_screen.dart';
import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../model/load_shop.dart';
import '../model/token.dart';
import '../widgets/button2.dart';
import '../widgets/image.dart';
import 'package:http/http.dart' as http;

var itemShopItemPage = ShopData.fromJson({});

class ShopItemPage extends StatefulWidget {
  const ShopItemPage({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<ShopItemPage> {

  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String _desc = itemShopItemPage.descr;
    _desc = _desc.replaceAll("<br>", "\n");

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(
                  height: 200,
                  width: Get.width,
                  child: showImage(itemShopItemPage.img, width: Get.width, height: 200)
              ),
              const SizedBox(height: 15,),
              Container(
                margin: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(itemShopItemPage.page, style: const TextStyle(fontSize: 18, color: Colors.black),)),
                        if (itemShopItemPage.price.isNotEmpty && itemShopItemPage.price != "0")
                          Text("${itemShopItemPage.price} ₽", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),),
                      ],
                    ),
                    const SizedBox(height: 15,),
                    Text(_desc, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400),),
                    const SizedBox(height: 20,),
                    button2("Подробнее", (){
                      showNativeWindowsTabText.value = "shop_item2";
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ShopItemPage2(item: itemShopItemPage),
                      //   ),
                      // );
                    }, ),
                    const SizedBox(height: 20,),
                    if (itemShopItemPage.price.isNotEmpty && itemShopItemPage.price != "0")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Для заказа заполните форму ниже:", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),),
                          const SizedBox(height: 15,),
                          const Text("Имя:", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),),
                          const SizedBox(height: 5,),
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(20),
                                shape: BoxShape.rectangle,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: TextField(
                                controller: nameController,
                                onChanged: (_){
                                  setState((){});
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10, right: 13),
                                  // hintStyle: themeSmallGreyText,
                                  // hintText: _recorderTxt,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              )),


                          const SizedBox(height: 15,),
                          const Text("Телефон:", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),),
                          const SizedBox(height: 5,),
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(20),
                                shape: BoxShape.rectangle,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: TextField(
                                controller: phoneController,
                                onChanged: (_){
                                  setState((){});
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10, right: 13),
                                  // hintStyle: themeSmallGreyText,
                                  // hintText: _recorderTxt,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              )),

                          const SizedBox(height: 15,),
                          const Text("Адрес:", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),),
                          const SizedBox(height: 5,),
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(20),
                                shape: BoxShape.rectangle,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: TextField(
                                controller: addressController,
                                onChanged: (_){
                                  setState((){});
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10, right: 13),
                                  // hintStyle: themeSmallGreyText,
                                  // hintText: _recorderTxt,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              )),

                          const SizedBox(height: 15,),
                          button2("Заказать", _sendData, enable: nameController.text.isNotEmpty && phoneController.text.isNotEmpty && addressController.text.isNotEmpty),
                          const SizedBox(height: 15,),
                          if (nameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty)
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Все поля обязательны для заполнения", style: TextStyle(fontSize: 12,
                                    color: Colors.red, fontWeight: FontWeight.w800),)
                              ],
                            ),
                        ],
                      )

                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
          Container(
              margin: const EdgeInsets.only(left: 20, top: 30),
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(onPressed: (){
                showNativeWindowsTabText.value = "Заказать";
              }, icon: const Icon(Icons.arrow_back_sharp)))
        ],
      )
      // InAppWebView(
      //     initialUrlRequest: URLRequest(url: Uri.parse("$mainAddress/${itemShopItemPage.url}"))
      // ),
    );
  }

  _sendData() async {
    try{
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var order = "Заказ: ${itemShopItemPage.page}-${itemShopItemPage.price} ₽\n"
                  "Заказчик: ${nameController.text}\n"
                  "Телефон: ${phoneController.text}\n"
                  "Адрес: ${addressController.text}";

      var _body = {
        'action': 'getorder',
        'module': 'apk',
        'appid': _prefs.getString('appid') ?? '0',
        "order": order,
        if (Platform.isAndroid)
          'apk_key': await getDeviceDetails(),
        if (Platform.isIOS)
          'ios_key': await getDeviceDetails(),
      };
// https://kupikrevetki.9lo.ru/index.php
      dprint("getorder $_body", color: "cyan");
      var response = await http.post(Uri.parse(addressAPI), body: _body);
      dprint("getorder response.statusCode=${response.statusCode}", color: "cyan");
      if (response.statusCode == 200) {
        messageOk(context, "Вашь заказ отправлен");
        Navigator.pop(context);
      }else
        messageError(context, "statusCode=${response.statusCode}");
    }catch(ex){
      messageError(context, "getorder " + ex.toString());
    }
  }
}



class ShopItemPage2 extends StatefulWidget {
  const ShopItemPage2({Key? key}) : super(key: key);

  @override
  _LoginState2 createState() => _LoginState2();
}

class _LoginState2 extends State<ShopItemPage2> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri("$mainAddress/${itemShopItemPage.url}"))
            )),

            Container(
                margin: const EdgeInsets.only(left: 0, top: 30),
                child: IconButton(onPressed: (){
                  showNativeWindowsTabText.value = "shop_item";
                }, icon: const Icon(Icons.arrow_back_sharp))
            ),

          ],
        ),
    );
  }
}

