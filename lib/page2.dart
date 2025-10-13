import 'package:constyle/permission.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'browser.dart';
import 'config.dart';
import 'main.dart';
import 'model/cache.dart';

class Page2Screen extends StatefulWidget {
  const Page2Screen({Key? key, required this.animateTo0,}) : super(key: key);

  final Function() animateTo0;

  @override
  State<Page2Screen> createState() => _Page2ScreenState();
}

class _Page2ScreenState extends State<Page2Screen> {

  _redraw(value){
    if (mounted)
      setState((){});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _page2();
  }

  double _dx = 0;
  double _startDx = 0;

  Widget _page2(){
    return GestureDetector(
        onHorizontalDragStart: (DragStartDetails details){
          _startDx = details.globalPosition.dx;
          // print("onHorizontalDragStart ${details.globalPosition.dx}");
          _dx = 0;
        },
        onHorizontalDragUpdate: (DragUpdateDetails details){
          _dx = details.globalPosition.dx;
        },
        onHorizontalDragEnd: (DragEndDetails details){
          // print("onHorizontalDragEnd ${_dx}");
          if (_dx > _startDx)
            widget.animateTo0();

        },
        child: Container(
            width: Get.width,
            height: Get.height,
            padding: const EdgeInsets.only(left: 20, right: 20),
            color: bgcolor,
            child: Stack(
              children: [
                SingleChildScrollView(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      SizedBox(
                        height: MediaQuery.of(context).padding.top + 60,
                      ),

                      const Text(
                        "Кэширование ускоряет работу приложения. Данныеберутся с сервера и сохраняются на устройстве, что позволяет работать намаксимальной скорости. Если на текущую страницу нет кэша, то данные берутся ссервера, если кэш уже есть, то загрузка происходит с устройства.Если вам кажется, что данные в кэше сохранены сошибками, можно удалить кэш или отключить кэширование, что приведёт к болеемедленной работе приложения.",
                          textAlign: TextAlign.center,
                          style: nativeSettingsText
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/b5.png", width: 20,),
                          const SizedBox(width: 10),
                          const Expanded(child: Text(
                              "Означает, что загрузка данных происходит с сервера",
                              style: nativeSettingsText
                          )),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/b6.png", width: 20,),
                          const SizedBox(width: 10),
                          const Expanded(child: Text(
                              "Означает, что загрузка данных происходит с устройства",
                              style: nativeSettingsText
                          )),
                        ],
                      ),

                      const SizedBox(height: 30),
                      _button2("Удалить кэш", () async {
                        await cacheDeleteAll();
                        // restartApp(context);
                        widget.animateTo0();
                        openBrowser(mainAddress);
                        //messageOk(context, "Кэш удален");
                      }),

                      const SizedBox(height: 20),
                      _button2(debugNoSave ? "Отключить кэширование" : "Включить кэширование", (){
                        debugNoSave = !debugNoSave;
                        setSaveToCache();
                        _redraw(0);
                      }, icon: "assets/b2.png"),

                      // const SizedBox(height: 20),
                      // const Text(
                      //   "Если вы увидели, что данные сохранялись с ошибками и отключениекэша решило эти проблемы, пожалуйста сообщите нам об этом, мы постараемсяисправить ошибки.",
                      //   textAlign: TextAlign.center,
                      //   style: nativeSettingsText
                      // ),
                      //
                      // const SizedBox(height: 20),
                      //
                      // _button2("Сообщить об ошибке", (){
                      // }, icon: "assets/b3.png"),

                      const SizedBox(height: 20),

                      const Text(
                          "Если при работе приложения, возникают ошибки, попробуте его перезагрузить.",
                          textAlign: TextAlign.center,
                          style: nativeSettingsText
                      ),

                      const SizedBox(height: 20),

                      _button2("Перезагрузить", (){
                        restartApp(context);
                      }, icon: "assets/b4.png"),

                      const SizedBox(height: 20),

                      _button2("Разрешения", (){
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const PermissionScreen(),
                        ));
                      }, icon: "assets/b3.png"),

                    ],
                )),

                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: IconButton(
                    onPressed: () {
                      widget.animateTo0();
                    }, icon: const Icon(Icons.arrow_back_outlined),),
                )
              ],
            )
        ));
  }

  _button2(String text, Function() _callback,
      {
        String icon = "assets/b1.png",
        bool enable = true,
        double? width = double.maxFinite,
        EdgeInsetsGeometry? padding,
      }){
    Color color = buttonbg;
    return Stack(
      children: <Widget>[
        Container(
            width: width,
            padding: padding ?? const EdgeInsets.only(top: 8, bottom: 8, left: 5, right: 5),
            decoration: BoxDecoration(
              color: (enable) ? color : Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Image.asset(
                  icon, width: 30,
                ),
                Expanded(child: FittedBox(fit: BoxFit.scaleDown,
                    child: Text(text, style: styleButton,
                      textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,))),
                const SizedBox(width: 40),
              ],
            )
        ),
        if (enable)
          Positioned.fill(
            child: Material(
                color: Colors.transparent,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: InkWell(
                  splashColor: Colors.black.withOpacity(0.2),
                  onTap: (){
                    _callback();
                  }, // needed
                )),
          )
      ],
    );
  }
}
