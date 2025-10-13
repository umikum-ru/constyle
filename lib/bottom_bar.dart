import 'package:constyle/model/signin.dart';
import 'package:flutter/material.dart';
import 'config.dart';
import 'shop/shop_screen.dart';
import 'widgets/bottom13.dart';

int _currentsState = 0;

bottomBar(){

  List<String> bottomBarText = [
    "Заказать",
   // "Кабинет",
    "Позвонить",
    // "Профиль"
  ];

  // иконки
  List<String> bottomBarIcons = [
    "assets/home2.png",
 //   "assets/031-book.png",
    "assets/phone.png",
    // "assets/008-user.png",
  ];

  if (serverResponseData.nativenews == "YES") {
    bottomBarText.add("Новости");
    bottomBarIcons.add("assets/news.png");
  }
  if (serverResponseData.appgame.isNotEmpty) {
    bottomBarText.add("Игра");
    bottomBarIcons.add("assets/game.png");
  }
  if (serverResponseData.native == "YES") {
    bottomBarText.add("Сервис");
    bottomBarIcons.add("assets/index.png");
  }

  return Container(
    alignment: Alignment.bottomCenter,
    child: BottomBar13(
      colorBackground: bgcolor,
      colorSelect: textColor,
      colorUnSelect: Colors.grey,
      textStyle: const TextStyle(letterSpacing: 0.6, fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
      textStyleSelect: serverResponseData.style12W800MainColor,
      radius: 9,
      callback: (int y, String text){
        _currentsState = y;
        if (serverResponseData.native == "YES") {
          showNativeWindowsTabText.value = text;
          // if (y == 0) {
          //   showNativeWindowsTab0.value = true; // нативный список товаров
          //   // showNativeWindowsTab1.value = false;
          //   showNativeWindowsTab2.value = false;
          //   showNativeWindowsTab3.value = false;
          //   showNativeWindowsTab4.value = false;
          //   showNativeWindowsTab5.value = false;
          // }

          // if (y == 1) {
          //   showNativeWindowsTab0.value = false;
          //   // showNativeWindowsTab1.value = true;
          //   showNativeWindowsTab2.value = false;
          //   showNativeWindowsTab3.value = false;
          //   showNativeWindowsTab4.value = false;
          // }
          // if (y == 1) {
          //   showNativeWindowsTab0.value = false; // позвонить
          //   // showNativeWindowsTab1.value = false;
          //   showNativeWindowsTab2.value = true;
          //   showNativeWindowsTab3.value = false;
          //   showNativeWindowsTab4.value = false;
          //   showNativeWindowsTab5.value = false;
          // }
          // if (y == 2) {
          //   showNativeWindowsTab0.value = false; // новости
          //   // showNativeWindowsTab1.value = false;
          //   showNativeWindowsTab2.value = false;
          //   showNativeWindowsTab3.value = true;
          //   showNativeWindowsTab4.value = false;
          //   showNativeWindowsTab5.value = false;
          // }
          // if (y == 3) {
          //   showNativeWindowsTab0.value = false; // игра
          //   // showNativeWindowsTab1.value = false;
          //   showNativeWindowsTab2.value = false;
          //   showNativeWindowsTab3.value = false;
          //   showNativeWindowsTab4.value = true;
          //   showNativeWindowsTab5.value = false;
          // }
          // if (y == 4) {
          //   showNativeWindowsTab0.value = false; // сайт
          //   // showNativeWindowsTab1.value = false;
          //   showNativeWindowsTab2.value = false;
          //   showNativeWindowsTab3.value = false;
          //   showNativeWindowsTab4.value = false;
          //   showNativeWindowsTab5.value = true;
          // }
        }
        // else{
        //   openBrowser(bottomBarAddress[y]);
        // }
      }, //initialSelect: _currentPage,
      getItem: (){
        return _currentsState;
      },
      text: bottomBarText,
      icons: bottomBarIcons,
      getUnreadMessages: (int index) {
        return 0;
      },
    ),
  );
}