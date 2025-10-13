import 'package:constyle/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import 'config.dart';

var showProgressBar = false.obs;
var progressBarValue = 1.obs;
var progressBarColor = const Color(0xff000000).obs;

class ProgressBar extends StatefulWidget {
  const ProgressBar({Key? key, required this.settings,}) : super(key: key);

  final Function() settings;

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {

  _redraw(value){
    if (mounted)
      setState((){});
  }

  late Worker worker1;
  late Worker worker2;
  late Worker worker3;

  @override
  void initState() {
    worker1 = ever(showProgressBar, _redraw);
    worker2 = ever(progressBarValue, _redraw);
    worker3 = ever(progressBarColor, _redraw);

    super.initState();
  }

  @override
  void dispose() {
    worker1.dispose();
    worker2.dispose();
    worker3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (!loadIndicatorEnable)
      return Container();

    if (!showProgressBar.value)
      return Container();

    var w = Get.width - 203; /// ширина 100%
    var t = progressBarValue/100;
    var w2 = w*t;

    return Container(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 70),
        child: Row(
          children: [

            Expanded(child: Container(
                height: 30,
                decoration: BoxDecoration(
                    color: bgcolor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),]
                ),
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(source == "server" ? "assets/b5.png" : "assets/b6.png", width: 20,),
                  const SizedBox(width: 5),
                  Image.asset("assets/b7.png", width: 5,),
                  const SizedBox(width: 5),

                  UnconstrainedBox(
                      child: Stack(
                        children: [
                          Container(
                            height: 10,
                            width: w,
                            decoration: BoxDecoration(
                              color: const Color(0xffe6e7ec),
                              border: Border.all(color: const Color(0xffb1b3b2)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: w-w2),
                            height: 10,
                            width: w2,
                            decoration: BoxDecoration(
                              color: progressBarColor.value,
                              //border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )

                        ],
                      )),
                ],

            ))),
            const SizedBox(width: 10),
            GestureDetector(
                onTap: (){
                  widget.settings();
                },
                child: Container(
                height: 30,
                width: 100,
                decoration: BoxDecoration(
                    color: bgcolor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),]
                ),
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                children: [
                  Image.asset("assets/a.png", width: 16,),
                  const SizedBox(width: 2),
                  const Text("Настройки", style: settingsButtonText)
                ],
              ),
            ))

          ],
        )
    );
  }
}

progressBarWork(InAppWebViewController controller) async {
  progressBarValue.value = 100;
  /// И по признаку успешной загрузки, давай и кать только "spectro_data" и "spectro_appmenu",
  /// остальное не важно. И по результату - если не найдены эти элементы, то пусть индикатор с
  /// кнопкой вообще не исчезают после загрузки, а то если белый экран, то и нажать будет не на что.
  /// Если загрузка успешная, то не надо красить в какой то отдельный цвет, просто залить о
  /// конца индикатор тем цветом, который был у полоски статуса загрузки. А вот если не найдены
  /// "spectro_data" и "spectro_appmenu", то уже красить полоску в цвет ошибки и оставлять
  /// индикатор с кнопкой на экране


  var t = await controller.getHtml();
  if (t == null) {
    progressBarColor.value = progressBarColorError;
    return false;
  }

  if (!t.contains("spectro_data") && !t.contains("spectro_appmenu")) {
    progressBarColor.value = progressBarColorError;
    return false;
  }
  progressBarColor.value = progressBarColorOk;

  Future.delayed(Duration(seconds: timeForGreenCircleForDeleteCache), () {
    showProgressBar.value = false;
  });
}

