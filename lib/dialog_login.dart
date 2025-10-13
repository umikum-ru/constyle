import 'dart:io';

import 'package:constyle/setting.dart';
import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'config.dart';
import 'log_in.dart';
import 'model/signin.dart';
import 'package:http/http.dart' as http;

import 'model/token.dart';
import 'shop/shop_screen.dart';
import 'widgets/button2.dart';

var userLogged = false.obs;

class DialogLogin extends StatefulWidget {
  const DialogLogin({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<DialogLogin> {

  TextEditingController textEditingControllerEmail = TextEditingController();
  TextEditingController textEditingControllerPassword = TextEditingController();

  @override
  void dispose() {
    textEditingControllerEmail.dispose();
    textEditingControllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        // const SizedBox(height: 20),
        // Container(
        //     padding: const EdgeInsets.only(left: 20, right: 20),
        //     child: ClipRRect(
        //       borderRadius: const BorderRadius.all(Radius.circular(5)),
        //       child: Image.network(data['appimg']),
        //     )
        // ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              controller: textEditingControllerEmail,
              textCapitalization: TextCapitalization.none,
              style: TextStyle(color: serverResponseData.color,),
              decoration: InputDecoration(
                hintText: 'Логин',
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: serverResponseData.color,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: serverResponseData.color,
                    width: 2.0,
                  ),
                ),
              )
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: TextFormField(
              obscureText: true,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              controller: textEditingControllerPassword,
              style: TextStyle(color: serverResponseData.color,),
              decoration: InputDecoration(
                hintText: 'Пароль',
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: serverResponseData.color,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: serverResponseData.color,
                    width: 2.0,
                  ),
                ),
              )
          ),
        ),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.all(15),
          child: button2("Войти", _login,),
        ),
        // const SizedBox(height: 10),
        // Container(
        //   margin: const EdgeInsets.only(left: 15, right: 15),
        //   child: button2("Войти без регистрации", _login2,),
        // ),
        const SizedBox(height: 20),
      ],
    );
  }

  // _login2(){
  //   if (!showNativeWindowsTab1.value)
  //     Navigator.pop(context);
  //   loginEnter(context);
  // }

  _login() async {
    if(textEditingControllerEmail.text.isNotEmpty && textEditingControllerPassword.text.isNotEmpty){
      var body = {
        'action': 'auth',
        'module': 'apk',
        if (Platform.isAndroid)
          'apk_key': await getDeviceDetails(),
        if (Platform.isIOS)
          'ios_key': await getDeviceDetails(),
        'login': textEditingControllerEmail.text,
        'pass': textEditingControllerPassword.text,
      };
      dprint("check user $body");
      var responseAuth = await http.post(Uri.parse(addressAPI),
        body: body
      );

      dprint(responseAuth.statusCode.toString());

      if (responseAuth.statusCode == 200) {
        final authData = jsonDecode(responseAuth.body);
        dprint("ret=$authData");
        if (int.parse(authData['userid']) > 0){
          serverResponseData.login(authData['userid']);
          authEnter(context);
          userLogged.value = true;
          if (showNativeWindowsTabText.value != "Сервис")
            Navigator.pop(context);
        }
        else{
          Get.snackbar("", 'Пользователь не найден');
        }
      }
      else{
        Get.snackbar("", 'Ошибка входа');
      }
    }
    else
      Get.snackbar("", 'Заполните все поля!');
  }
}