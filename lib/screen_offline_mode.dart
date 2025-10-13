// import 'dart:io';
//
// import 'package:constyle/log_in.dart';
// import 'package:constyle/setting.dart';
// import 'package:constyle/utils.dart';
// import 'package:constyle/widgets/button2.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
//
// import 'browser.dart';
// import 'config.dart';
//
// screenOfflineMode(double windowWidth, double windowHeight){
//   return Container(
//       width: windowWidth,
//       height: windowHeight,
//       color: Colors.white,
//       child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: windowWidth,
//                 margin: const EdgeInsets.all(30),
//                 child: Image.file(File(noInternetCacheInCache,),
//                   errorBuilder: (
//                       BuildContext context,
//                       Object error2,
//                       StackTrace? stackTrace,
//                       ){
//                     return Image.asset(noInCacheImage, fit: BoxFit.contain,);
//                   },
//                 )
//               ),
//               const SizedBox(height: 20,),
//               const Text("Данная страница в кэше отсутствует",
//                   style: TextStyle(letterSpacing: 0.6, fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black)),
//               const SizedBox(height: 40,),
//               Container(
//                 margin: const EdgeInsets.only(left: 20, right: 20),
//                 child: button2("Вернуться на главную страницу?", (){
//                   noInCacheDialog = false;
//                   dprint("Вернуться на главную страницу");
//                   if (lastConnectivityResult == ConnectivityResult.none){
//                     noInternet = true;
//                   }else{
//                     openBrowser(mainAddress);
//                   }
//                   if (redrawMainWindow != null)
//                     redrawMainWindow!();
//                 },),
//               )
//             ],
//           ))
//   );
// }