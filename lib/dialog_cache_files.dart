import 'package:constyle/setting.dart';
import 'package:flutter/material.dart';

import 'log_in.dart';

var countCacheFiles = 0;

showDialogCacheFiles(BuildContext context) async {
  waiting = false;
  if (redrawMainWindow != null)
    redrawMainWindow!();
  return;
  // if (countCacheFiles == 0){
  //   waiting = false;
  //   if (redrawMainWindow != null)
  //     redrawMainWindow!();
  //   return;
  // }
  //
  // Navigator.of(context).push(
  //   PageRouteBuilder(
  //     opaque: false,
  //     pageBuilder: (_, __, ___) {
  //       return _DialogBody(count: countCacheFiles);
  //     },
  //   ),
  // );
}

// class _DialogBody extends StatefulWidget {
//   const _DialogBody({Key? key, required this.count}) : super(key: key);
//
//   final int count;
//
//   @override
//   _DialogBodyState createState() => _DialogBodyState();
// }
//
// class _DialogBodyState extends State<_DialogBody> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Center(
//           child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(20),
//               color: Colors.white,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   button2("Открыть онлайн-версию", serverResponseData.buttonbg, (){
//                     waiting = false;
//                     Navigator.pop(context);
//                     if (redrawMainWindow != null)
//                       redrawMainWindow!();
//                   }, style: style12W600White),
//                   const SizedBox(height: 20,),
//                   button2("Открыть офлайн-версию (${widget.count} стр)", serverResponseData.buttonbg, (){
//                     waiting = false;
//                     onlyOffline = true;
//                     Navigator.pop(context);
//                     if (redrawMainWindow != null)
//                       redrawMainWindow!();
//                   }, style: style12W600White)
//                 ],
//               )),
//         ));
//   }
// }
//
//
