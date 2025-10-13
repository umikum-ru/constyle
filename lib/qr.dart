import 'package:constyle/model/offline_storage.dart';
import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'package:constyle/qr_send.dart';
import 'package:constyle/widgets/button2.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'browser.dart';
import 'config.dart';

String currentQR = "";

openQr(BuildContext context, Uri uri, String code){
  var ps = uri.queryParameters;
  var url = ps["url"];
  var params = ps["params"];

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ScanCode2PageScreen(url: url, params: params, code: code),
    ),
  );
}

// 10.05.23
// 6. Дорабатываем механизм qr-сканера.
// Сейчас, при срабатывании /qr-scanner/, ты даешь сканировать и отправляешь post-форму с кодом на «appqrcode».
// Я туда добавил возможные параметры:
// <?=SITE?>qr-scanner/?url=https://appsite.ru/somepage/&params=someparamslist
// Если приходит значение «url» и «params», то переходим в режим отправки через offline, то есть сохраняешь значения на устройстве,
// пытаешься отправить и если нет интернета, накапливаешь данные так же как данные /offlinesave/.
// К post-параметрам добавляем 'add' и в этом параметре передаём значение get-переменной «params».
// Остальные параметры те же: appid, qrcode, apk_key, ios_key и теперь вот «add».
// И так же, если работаем с автоматической отправкой post-данных, то на backurl из json-ответа переводить уже не надо,
// переводишь на «url» из get-параметра.
// Очерёдность отправки опять же в той же последовательности, как отправлялись данные, если сначала сканировался qr-код,
// потом отправилось /offlinesave/, то так же и шлёшь, если сначала /offlinesave/, потом qr-код, потом опять /offlinesave/,
// то тоже всё отправится так же.

class ScanCode2PageScreen extends StatefulWidget {
  const ScanCode2PageScreen({Key? key, this.url, this.params,
    required this.code}) : super(key: key);

  final String? url;
  final String? params;
  final String code;

  @override
  _ScanCode2PageScreenState createState() => _ScanCode2PageScreenState();
}

class _ScanCode2PageScreenState extends State<ScanCode2PageScreen> {

  double windowWidth = 0;
  double windowHeight = 0;

  @override
  void initState() {
    currentQR = "";
    // _perm();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Stack(
          children: <Widget>[

            MobileScanner(
                // allowDuplicates: false,
                onDetect: (BarcodeCapture barcodes) {
                  for (var barcode in barcodes.barcodes){
                    currentQR = "";

                    // А разные режимы можно? Что /qr-scanner/ - только qr? где на экране рамочка - подсказка.
                    // /line-scanner/ - только штрихкода,
                    // а /view-scanner/ - всё подряд

                    if (widget.code == "/qr-scanner/") { //  только qr,
                      if (barcode.format == BarcodeFormat.dataMatrix
                          || barcode.format == BarcodeFormat.qrCode
                          || barcode.format == BarcodeFormat.pdf417
                          || barcode.format == BarcodeFormat.aztec) {

                      }else{
                        dprint("------ bad bar code: format=${barcode.format} ${barcode.rawValue}");
                        setState(() {
                        });
                        return;
                      }
                    }

                    if (widget.code == "/line-scanner/") { //  только штрихкод
                      if (barcode.format == BarcodeFormat.dataMatrix
                          || barcode.format == BarcodeFormat.qrCode
                          || barcode.format == BarcodeFormat.pdf417
                          || barcode.format == BarcodeFormat.aztec) {
                        dprint("------ bad bar code: format=${barcode.format} ${barcode.rawValue}");
                        setState(() {
                        });
                        return;
                      }
                    }

                    if (barcode.rawValue == null) {
                      debugPrint('Failed to scan Barcode');
                    } else {
                      final String code = barcode.rawValue!;
                      debugPrint('Barcode found! $code');
                      // _qrCallback(scanData.code!);
                      currentQR = code;
                      setState(() {
                      });
                    }
                  }
                }),
            // _scannerView(),

            if (widget.code == "/qr-scanner/")
              ..._ramka(),

            if (widget.code == "/qr-scanner/")
              Container(
                margin: EdgeInsets.only(top: 100, left: Get.width*0.1),
                width: Get.width*0.8,
                child: const Text("Для распознования данных наведите камеру на QR код",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white),
                ),
              ),

            Container(
                margin: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                alignment: Alignment.bottomCenter,
                child:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currentQR, style: style12W600White,),
                    const SizedBox(height: 10,),
                    button2("Готово", (){
                      if (widget.url != null && widget.params != null) {
                        // currentQR = "12334222";
                        var ret = saveQrOfflineStorage(currentQR, widget.params!);
                        if (ret != null)
                          messageError(context, ret);
                        else {
                          //  sendCodeOffline(widget.url!, widget.params!);
                          openBrowser(widget.url!);
                          Navigator.pop(context);
                        }
                      }else
                        sendQr(context,);
                    }, enable: true),
                    //currentQR.isNotEmpty),
                    const SizedBox(height: 10,),
                    button2("Отмена", (){
                      Navigator.pop(context);
                    }),
                  ],
                )
            )

            //appbar1(Colors.white.withAlpha(100), Colors.black, "Scan QR/Bar Code", context, () {Navigator.pop(context);})

          ],
        )
    );
  }

  List<Widget> _ramka(){
    var w = Get.width*0.8;
    return [
      Container(
        width: Get.width,
        height: (Get.height-w)/2,
        color: Colors.black.withOpacity(0.5),
      ),
      Container(
          alignment: Alignment.bottomCenter,
          child:
          Container(
            width: Get.width,
            height: (Get.height-w)/2,
            color: Colors.black.withOpacity(0.5),
          )),
      // слева
      Container(
          alignment: Alignment.centerLeft,
          child: Container(
            width: Get.width*0.1,
            height: w,
            color: Colors.black.withOpacity(0.5),
          )),
      // справа
      Container(
          alignment: Alignment.centerRight,
          child: Container(
            width: Get.width*0.1,
            height: w,
            color: Colors.black.withOpacity(0.5),
          )),

      if (currentQR.isEmpty)
        ...[
          // левый верхний угол
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.1),
            height: 6,
            width: 40, // горизонтальная
            color: Colors.white,
          ),
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.1-3),
            height: 40, // вертикальная
            width: 6,
            color: Colors.white,
          ),

          // левый нижний угол
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2-3+w, left: Get.width*0.1),
            height: 6, // горизонтальная
            width: 40,
            color: Colors.white,
          ),
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2+w-40+3, left: Get.width*0.1-3),
            height: 40, // вертикальная
            width: 6,
            color: Colors.white,
          ),

          // правый верхний угол
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.9-40),
            height: 6,
            width: 40, // горизонтальная
            color: Colors.white,
          ),
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.9-3),
            height: 40, // вертикальная
            width: 6,
            color: Colors.white,
          ),

          // правый нижний угол
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2-3+w, left: Get.width*0.9-40),
            height: 6,
            width: 40, // горизонтальная
            color: Colors.white,
          ),
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2+3+w-40, left: Get.width*0.9-3),
            height: 40, // вертикальная
            width: 6,
            color: Colors.white,
          ),
        ]
      else
        ...[
          // левый верхний угол
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.1),
            height: 6,
            width: w, // горизонтальная
            color: Colors.white,
          ),
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.1-3),
            height: w, // вертикальная
            width: 6,
            color: Colors.white,
          ),

          // левый нижний угол
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2-3+w, left: Get.width*0.1),
            height: 6, // горизонтальная
            width: w,
            color: Colors.white,
          ),

          // правый верхний угол
          Container(
            margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.9-3),
            height: w, // вертикальная
            width: 6,
            color: Colors.white,
          ),
        ]
    ];
  }

  // final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // Barcode? result;
  // QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (Platform.isAndroid) {
  //     controller!.pauseCamera();
  //   } else if (Platform.isIOS) {
  //     controller!.resumeCamera();
  //   }
  // }

  // bool isOk = false;

  // _scannerView(){
  //   if (isOk) {
  //     dprint ("ok. return QRView");
  //     return Container(
  //       width: Get.width,
  //       height: Get.height,
  //       color: Colors.red,
  //         child: QRView(
  //       key: qrKey,
  //       onQRViewCreated: _onQRViewCreated,
  //     ));
  //   }else {
  //     dprint ("no ok. return container ");
  //     return Container();
  //   }
  // }

  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) {
  //     if (scanData.code == null)
  //       return;
  //     dprint(scanData.code!);
  //     _qrCallback(scanData.code!);
  //     setState(() {
  //     });
  //   });
  // }

  @override
  void dispose() {
    // controller?.dispose();
    super.dispose();
  }

// _qrCallback(String code) {
//   currentQR = code;
// }

// _perm() async {
//   if (Platform.isIOS){
//     isOk = true;
//     setState(() {
//     });
//   }else {
//     var status = await Permission.camera.status;
//     if (status.isDenied)
//       status = await Permission.camera.request();
//     if (status.isGranted) {
//       dprint("permissions ok");
//       isOk = true;
//       print("redraw");
//       setState(() {
//       });
//     }
//   }
// }

}


// import 'dart:async';
//
// import 'package:constyle/model/offline_storage.dart';
// import 'package:constyle/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:constyle/qr_send.dart';
// import 'package:constyle/widgets/button2.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'browser.dart';
// import 'config.dart';
//
// String currentQR = "";
//
// openQr(BuildContext context, Uri uri, String code){
//   var ps = uri.queryParameters;
//   var url = ps["url"];
//   var params = ps["params"];
//
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => ScanCode2PageScreen(url: url, params: params, code: code),
//     ),
//   );
// }
//
// // 10.05.23
// // 6. Дорабатываем механизм qr-сканера.
// // Сейчас, при срабатывании /qr-scanner/, ты даешь сканировать и отправляешь post-форму с кодом на «appqrcode».
// // Я туда добавил возможные параметры:
// // <?=SITE?>qr-scanner/?url=https://appsite.ru/somepage/&params=someparamslist
// // Если приходит значение «url» и «params», то переходим в режим отправки через offline, то есть сохраняешь значения на устройстве,
// // пытаешься отправить и если нет интернета, накапливаешь данные так же как данные /offlinesave/.
// // К post-параметрам добавляем 'add' и в этом параметре передаём значение get-переменной «params».
// // Остальные параметры те же: appid, qrcode, apk_key, ios_key и теперь вот «add».
// // И так же, если работаем с автоматической отправкой post-данных, то на backurl из json-ответа переводить уже не надо,
// // переводишь на «url» из get-параметра.
// // Очерёдность отправки опять же в той же последовательности, как отправлялись данные, если сначала сканировался qr-код,
// // потом отправилось /offlinesave/, то так же и шлёшь, если сначала /offlinesave/, потом qr-код, потом опять /offlinesave/,
// // то тоже всё отправится так же.
//
// class ScanCode2PageScreen extends StatefulWidget {
//   const ScanCode2PageScreen({Key? key, this.url, this.params,
//     required this.code}) : super(key: key);
//
//   final String? url;
//   final String? params;
//   final String code;
//
//   @override
//   _ScanCode2PageScreenState createState() => _ScanCode2PageScreenState();
// }
//
// class _ScanCode2PageScreenState extends State<ScanCode2PageScreen> with WidgetsBindingObserver{
//
//   final MobileScannerController controller = MobileScannerController(
//     // required options for the scanner
//   );
//
//   StreamSubscription<Object?>? _subscription;
//
//   double windowWidth = 0;
//   double windowHeight = 0;
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // If the controller is not ready, do not try to start or stop it.
//     // Permission dialogs can trigger lifecycle changes before the controller is ready.
//     if (!controller.value.hasCameraPermission) {
//       return;
//     }
//
//     switch (state) {
//       case AppLifecycleState.detached:
//         return;
//       case AppLifecycleState.hidden:
//         return;
//       case AppLifecycleState.paused:
//         return;
//       case AppLifecycleState.resumed:
//       // Restart the scanner when the app is resumed.
//       // Don't forget to resume listening to the barcode events.
//         _subscription = controller.barcodes.listen(_handleBarcode);
//
//         unawaited(controller.start());
//         return;
//       case AppLifecycleState.inactive:
//       // Stop the scanner when the app is paused.
//       // Also stop the barcode events subscription.
//         unawaited(_subscription?.cancel());
//         _subscription = null;
//         unawaited(controller.stop());
//     }
//   }
//
//   _handleBarcode(BarcodeCapture barcodeCapture){
//
//     final barcode = barcodeCapture.barcodes.first;
//     // allowDuplicates: false,
//     // onDetect: (Barcode barcode, args) {
//     currentQR = "";
//
//     // А разные режимы можно? Что /qr-scanner/ - только qr? где на экране рамочка - подсказка.
//     // /line-scanner/ - только штрихкода,
//     // а /view-scanner/ - всё подряд
//
//     if (widget.code == "/qr-scanner/") { //  только qr,
//       if (barcode.format == BarcodeFormat.dataMatrix
//           || barcode.format == BarcodeFormat.qrCode
//           || barcode.format == BarcodeFormat.pdf417
//           || barcode.format == BarcodeFormat.aztec) {
//
//       }else{
//         dprint("------ bad bar code: format=${barcode.format} ${barcode.rawValue}");
//         setState(() {
//         });
//         return;
//       }
//     }
//
//     if (widget.code == "/line-scanner/") { //  только штрихкод
//       if (barcode.format == BarcodeFormat.dataMatrix
//           || barcode.format == BarcodeFormat.qrCode
//           || barcode.format == BarcodeFormat.pdf417
//           || barcode.format == BarcodeFormat.aztec) {
//         dprint("------ bad bar code: format=${barcode.format} ${barcode.rawValue}");
//         setState(() {
//         });
//         return;
//       }
//     }
//
//     if (barcode.rawValue == null) {
//       debugPrint('Failed to scan Barcode');
//     } else {
//       final String code = barcode.rawValue!;
//       debugPrint('Barcode found! $code');
//       // _qrCallback(scanData.code!);
//       currentQR = code;
//       setState(() {
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     WidgetsBinding.instance.addObserver(this);
//     currentQR = "";
//     // _perm();
//
//     // Start listening to the barcode events.
//     _subscription = controller.barcodes.listen(_handleBarcode);
//
//     // Finally, start the scanner itself.
//     unawaited(controller.start());
//
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     windowWidth = MediaQuery.of(context).size.width;
//     windowHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//         body: Stack(
//           children: <Widget>[
//
//             MobileScanner(
//               fit: BoxFit.contain,
//               // scanWindow: scanWindow,
//               controller: controller,
//             ),
//             // _scannerView(),
//
//             if (widget.code == "/qr-scanner/")
//               ..._ramka(),
//
//             if (widget.code == "/qr-scanner/")
//               Container(
//                 margin: EdgeInsets.only(top: 100, left: Get.width*0.1),
//                 width: Get.width*0.8,
//                 child: const Text("Для распознования данных наведите камеру на QR код",
//                 textAlign: TextAlign.center, style: TextStyle(color: Colors.white),
//                 ),
//               ),
//
//             Container(
//                 margin: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
//                 alignment: Alignment.bottomCenter,
//                 child:
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(currentQR, style: style12W600White,),
//                     const SizedBox(height: 10,),
//                     button2("Готово", (){
//                       if (widget.url != null && widget.params != null) {
//                        // currentQR = "12334222";
//                         var ret = saveQrOfflineStorage(currentQR, widget.params!);
//                         if (ret != null)
//                           messageError(context, ret);
//                         else {
//                           //  sendCodeOffline(widget.url!, widget.params!);
//                           openBrowser(widget.url!);
//                           Navigator.pop(context);
//                         }
//                       }else
//                         sendQr(context,);
//                     }, enable: true),
//                     //currentQR.isNotEmpty),
//                     const SizedBox(height: 10,),
//                     button2("Отмена", (){
//                       Navigator.pop(context);
//                     }),
//                   ],
//                 )
//             )
//
//             //appbar1(Colors.white.withAlpha(100), Colors.black, "Scan QR/Bar Code", context, () {Navigator.pop(context);})
//
//           ],
//         )
//     );
//   }
//
//   List<Widget> _ramka(){
//     var w = Get.width*0.8;
//     return [
//       Container(
//         width: Get.width,
//         height: (Get.height-w)/2,
//         color: Colors.black.withOpacity(0.5),
//       ),
//       Container(
//         alignment: Alignment.bottomCenter,
//           child:
//         Container(
//           width: Get.width,
//           height: (Get.height-w)/2,
//           color: Colors.black.withOpacity(0.5),
//         )),
//       // слева
//       Container(
//         alignment: Alignment.centerLeft,
//           child: Container(
//         width: Get.width*0.1,
//         height: w,
//         color: Colors.black.withOpacity(0.5),
//       )),
//       // справа
//       Container(
//           alignment: Alignment.centerRight,
//           child: Container(
//             width: Get.width*0.1,
//             height: w,
//             color: Colors.black.withOpacity(0.5),
//           )),
//
//       if (currentQR.isEmpty)
//         ...[
//           // левый верхний угол
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.1),
//             height: 6,
//             width: 40, // горизонтальная
//             color: Colors.white,
//           ),
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.1-3),
//             height: 40, // вертикальная
//             width: 6,
//             color: Colors.white,
//           ),
//
//           // левый нижний угол
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2-3+w, left: Get.width*0.1),
//             height: 6, // горизонтальная
//             width: 40,
//             color: Colors.white,
//           ),
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2+w-40+3, left: Get.width*0.1-3),
//             height: 40, // вертикальная
//             width: 6,
//             color: Colors.white,
//           ),
//
//           // правый верхний угол
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.9-40),
//             height: 6,
//             width: 40, // горизонтальная
//             color: Colors.white,
//           ),
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.9-3),
//             height: 40, // вертикальная
//             width: 6,
//             color: Colors.white,
//           ),
//
//           // правый нижний угол
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2-3+w, left: Get.width*0.9-40),
//             height: 6,
//             width: 40, // горизонтальная
//             color: Colors.white,
//           ),
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2+3+w-40, left: Get.width*0.9-3),
//             height: 40, // вертикальная
//             width: 6,
//             color: Colors.white,
//           ),
//         ]
//       else
//         ...[
//           // левый верхний угол
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.1),
//             height: 6,
//             width: w, // горизонтальная
//             color: Colors.white,
//           ),
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.1-3),
//             height: w, // вертикальная
//             width: 6,
//             color: Colors.white,
//           ),
//
//           // левый нижний угол
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2-3+w, left: Get.width*0.1),
//             height: 6, // горизонтальная
//             width: w,
//             color: Colors.white,
//           ),
//
//           // правый верхний угол
//           Container(
//             margin: EdgeInsets.only(top: (Get.height-w)/2-3, left: Get.width*0.9-3),
//             height: w, // вертикальная
//             width: 6,
//             color: Colors.white,
//           ),
//         ]
//     ];
//   }
//
//   // final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   // Barcode? result;
//   // QRViewController? controller;
//
//   // In order to get hot reload to work we need to pause the camera if the platform
//   // is android, or resume the camera if the platform is iOS.
//   // @override
//   // void reassemble() {
//   //   super.reassemble();
//   //   if (Platform.isAndroid) {
//   //     controller!.pauseCamera();
//   //   } else if (Platform.isIOS) {
//   //     controller!.resumeCamera();
//   //   }
//   // }
//
//   // bool isOk = false;
//
//   // _scannerView(){
//   //   if (isOk) {
//   //     dprint ("ok. return QRView");
//   //     return Container(
//   //       width: Get.width,
//   //       height: Get.height,
//   //       color: Colors.red,
//   //         child: QRView(
//   //       key: qrKey,
//   //       onQRViewCreated: _onQRViewCreated,
//   //     ));
//   //   }else {
//   //     dprint ("no ok. return container ");
//   //     return Container();
//   //   }
//   // }
//
//   // void _onQRViewCreated(QRViewController controller) {
//   //   this.controller = controller;
//   //   controller.scannedDataStream.listen((scanData) {
//   //     if (scanData.code == null)
//   //       return;
//   //     dprint(scanData.code!);
//   //     _qrCallback(scanData.code!);
//   //     setState(() {
//   //     });
//   //   });
//   // }
//
//   @override
//   void dispose() {
//     // Stop listening to lifecycle changes.
//     WidgetsBinding.instance.removeObserver(this);
//     // Stop listening to the barcode events.
//     unawaited(_subscription?.cancel());
//     _subscription = null;
//
//     // controller?.dispose();
//     super.dispose();
//   }
//
//   // _qrCallback(String code) {
//   //   currentQR = code;
//   // }
//
//   // _perm() async {
//   //   if (Platform.isIOS){
//   //     isOk = true;
//   //     setState(() {
//   //     });
//   //   }else {
//   //     var status = await Permission.camera.status;
//   //     if (status.isDenied)
//   //       status = await Permission.camera.request();
//   //     if (status.isGranted) {
//   //       dprint("permissions ok");
//   //       isOk = true;
//   //       print("redraw");
//   //       setState(() {
//   //       });
//   //     }
//   //   }
//   // }
//
// }
//
