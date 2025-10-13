import 'dart:async';
import 'package:constyle/model/signin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config.dart';
import 'model/sound.dart';
import 'widgets/button2.dart';

writeSound(BuildContext context){
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) {
        return const _WriteSoundScreen();
      },
    ),
  );
}

class _WriteSoundScreen extends StatefulWidget {
  const _WriteSoundScreen({Key? key}) : super(key: key);

  @override
  _WriteSoundScreenState createState() => _WriteSoundScreenState();
}

class _WriteSoundScreenState extends State<_WriteSoundScreen> {

  Timer? _timer;
  String time = "";
  int seconds = 0;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    await initMp3State();
    _startRecord();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (playerIsPlaying())
      stopSound();
    stopWhiteSound();
    super.dispose();
  }

  void _startRecord() {
    // _first = false;
    startWriteSound(context);
    seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1),
          (Timer timer) {
            seconds++;
            time = _secondsToText(seconds);
            _redraw();
      },);
    _redraw();
  }

  _secondsToText(int sec){
    int min = sec~/60;
    if (min > 60)
      min = 60;
    var smin = min.toString();
    if (smin.length == 1)
      smin = "0$smin";
    int secs = sec % 60;
    var ssecs = secs.toString();
    if (ssecs.length == 1)
      ssecs = "0$ssecs";
    return "$smin:$ssecs";
  }

  // bool _first = true;

  @override
  Widget build(BuildContext context) {
    var mp3Present = isMp3FilePresent();

    if (_wait)
      return Scaffold(
        backgroundColor: Colors.black.withAlpha(50),
        body: Center(child: loaderWidget) //Loader30(color: textColor, size: 25)),
      );

    return Scaffold(
        backgroundColor: Colors.black.withAlpha(50),
        body: Stack(
          children: [
            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(),
            ),
            Container(
              alignment: Alignment.bottomCenter,
                child: Container(
                    width: Get.width,
                    color: bgcolor,
                    // margin: const EdgeInsets.only(left: 20, right: 20),
                    padding: const EdgeInsets.only(top: 30, bottom: 30),
                  // color: Colors.greenAccent,
              // padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // InkWell(
                  //     onTap: (){
                  //       Navigator.pop(context);
                  //     },
                  //     child: Row(
                  //   children: [
                  //     Expanded(child: Container()),
                  //     Container(
                  //       margin: const EdgeInsets.only(right: 10),
                  //       child: Icon(Icons.cancel, size: 30, color: Colors.black.withAlpha(200),),
                  //     )
                  //   ],
                  // )),
                  // const SizedBox(height: 5,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const SizedBox(width: 20,),
                  Text("Запись звукового сообщения:", style: serverResponseData.styleText,),
                  const SizedBox(width: 10,),
                  if (getSoundWriteState())
                    Text(time, style: serverResponseData.styleText),
                    ],
                  ),
                      const SizedBox(height: 20,),

                      Container(
                        margin: EdgeInsets.only(left: Get.width*0.2, right: Get.width*0.2),
                          child: button2("Отправить", () async {
                        _wait = true;
                        _redraw();
                        stopWhiteSound();
                        Future.delayed(const Duration(milliseconds: 500), () async {
                          await sendSound(context, (){
                            // _wait = false;
                            // _redraw();
                            Navigator.pop(context);
                          });
                        });
                      }, )),


                        // Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //
                        //     if (!playerIsPlaying())
                        //       InkWell(
                        //         onTapDown: (TapDownDetails details){
                        //           _startRecord();
                        //         },
                        //         onTapUp: (TapUpDetails details) async {
                        //           stopWhiteSound();
                        //           if (_timer != null)
                        //             _timer!.cancel();
                        //           _wait = true;
                        //           _redraw();
                        //           Future.delayed(const Duration(milliseconds: 2000), () async {
                        //             await sendSound(context, (){
                        //               Navigator.pop(context);
                        //             });
                        //             _wait = false;
                        //             _redraw();
                        //           });
                        //
                        //         },
                        //         child: const Icon(Icons.fiber_manual_record, color: Colors.red, size: 60,),
                        //       ),
                        //
                        //     // if (mp3Present && !playerIsPlaying())
                        //     //   const SizedBox(width: 20,),
                        //     /// остановка воспроизведения звука
                        //     if (playerIsPlaying() && mp3Present)
                        //       ...[
                        //         InkWell(
                        //           onTap: () async {
                        //             await stopSound();
                        //             _redraw();
                        //           },
                        //           child: const Icon(Icons.stop_circle, color: Colors.black, size: 50,),
                        //         ),
                        //       ],
                        //
                        //     /// воспроизвести звук
                        //     // if (!playerIsPlaying() && mp3Present)
                        //     //   InkWell(
                        //     //     onTap: () async {
                        //     //       await playSound(context, (String state){
                        //     //         _redraw();
                        //     //       });
                        //     //       _redraw();
                        //     //     },
                        //     //     child: const Icon(Icons.play_circle_fill_outlined, color: Colors.black, size: 50,),
                        //     //   ),
                        //   ],
                        // ),

                      // if (playerIsPlaying() && mp3Present)
                      //   const SizedBox(
                      //     height: 60, width: 1,),

                      // if (getSoundWriteState())
                      //   const SizedBox(height: 25,),
                      // if (_first && !playerIsPlaying())
                      //   Text("Нажмите кнопку для записи", style: serverResponseData.style12W800MainColor,),
                      // if (_first)
                      //   const SizedBox(height: 5,),

                      // остановка записи
                      // if (getSoundWriteState())
                      //   InkWell(onTap: (){
                      //     stopWhiteSound();
                      //     if (_timer != null)
                      //       _timer!.cancel();
                      //     _redraw();
                      //   }, child: const Icon(Icons.stop_circle, color: Colors.black, size: 60,),),

                      // const SizedBox(height: 10,),
                      // if (getSoundWriteState())
                      //   Text(time, style: serverResponseData.styleText),

                      if (mp3Present && !getSoundWriteState() && !playerIsPlaying())
                        const SizedBox(height: 20,),
                      // if (mp3Present && !getSoundWriteState() && !playerIsPlaying())
                      //   button2b("Отправить", () async {
                      //     _wait = true;
                      //     _redraw();
                      //     await sendSound(context, (){
                      //       Navigator.pop(context);
                      //     });
                      //     _wait = false;
                      //     _redraw();
                      //   }, color: serverResponseData.buttonbg, style: serverResponseData.style14W600White),
                      //

                ],
                )
                ))
          ],
        )
    );
  }

  bool _wait = false;

  _redraw(){
    if (mounted)
      setState(() {
      });
  }
}
