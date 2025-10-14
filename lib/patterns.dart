/*
ver 23.02.2023 3

margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
ширина экрана
MediaQuery.of(context).size.width

padding: const EdgeInsets.all(10),
padding: const EdgeInsets.only(left: 15, right: 15),
padding: const EdgeInsets.only(top: 5, bottom: 15),
padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),

decoration: BoxDecoration(
    color: widget.balloonColor,
    border: Border.all(color: Colors.blueAccent),
    borderRadius: BorderRadius.circular(10),
),

все
    borderRadius: BorderRadius.circular(15.0),
верх
    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
низ
    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
слева
    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
справа
    borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),

тень
boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.3),
      spreadRadius: 3,
      blurRadius: 5,
      offset: Offset(3, 3),
    ),
  ],

круг
Container(
     width: 25,
     height: 25,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
),

Navigator.pop(context);

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewsInfoScreen(),
));

основные

bool _waits = false;
_wait(bool value){
  _waits = value;
  _redraw(value);
}

_redraw(value){
  if (mounted)
    setState((){});
}

@override
void dispose() {
  controllerEmail.dispose();
  super.dispose();
}

@override
void initState() {
  _init();
  super.initState();
}

_init() async {
  _wait(true);
  var ret = await getProfile();
  _redraw(0);
  if (ret != null)
    messageError(ret);
  _wait(false);
}


-------------------------------------------
основной файл
part 'status_icon_menu_button.dart';
class ....

дополнительный файл
part of 'lesson_info_dialog.dart';

extension Buttons on DialogLessonInfoState{
}

--------------------------------------------
main.dart
--------------------------------------------
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'screens/main_screen.dart';
import 'utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Калькулятор',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: createMaterialColor(Colors.grey),
      ),
      home: const MainScreen(),
    );
  }
}
--------------------------------------------

--------------------------------------------
StatefulWidget
--------------------------------------------
import 'package:flutter/material.dart';

class DialogEditTask extends StatefulWidget {
  const DialogEditTask({Key? key}) : super(key: key);

  @override
  State<DialogEditTask> createState() => _DialogEditTaskState();
}

class _DialogEditTaskState extends State<DialogEditTask> {

    Widget waitWidget() => const Center(child: CircularProgressIndicator(color: Colors.black,),);

  bool _waits = false;
  _wait(bool value){
    _waits = value;
    _redraw(value);
  }

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
    return Scaffold(
      backgroundColor: const Color(0xffE5E5E5),
        body: Stack(
          children: [

          if (_waits)
              waitWidget()
          ]
      ));
  }
}
-----------------------------------------------------------------------


линия - line
Container(
    height: 1,
    color: const Color(0xffE5E5EA),
  ),
Container(
      margin: EdgeInsets.only(left: 16, right: 16),
      height: 1,
      color: const Color(0xffE5E5EA),
    ),


----------------------------
Кнопка back на Android (назад)
Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
            return false; // отмена
        return true; // назад
      },
      child: Scaffold(

---------------------------------------
математика

Убрать знак у числа
double dy = (_end.dy - _start.dy).abs();



-------------------------
List<Widget> _tasks(){
    List<Widget> list = [];
    for (var item in taskList)
      list.add();
    return list;
  }

-------------------------

var currentRoute = "profile".obs;
late Worker worker1;

  @override
  void initState() {
    worker1 = ever(currentRoute, _redraw);
    super.initState();
  }

@override
  void dispose() {
    worker1.dispose();
    super.dispose();
  }

-----------------------------------


       await Future<void>.delayed(Duration(seconds: 1));

            WidgetsBinding.instance.addPostFrameCallback((_) {

            });

            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
              });
            });


           Timer? _timer;

            _timer = Timer.periodic(Duration(seconds: 1),
                  (Timer timer) {
              },);


            @override
              void dispose() {
                _timer.cancel();
                super.dispose();
              }
или

            Timer? _timer;
            void startTimer() {
              _timer = Timer.periodic(const Duration(minutes: 3),
                    (Timer timer) {

                  }
              );
            }


--------------------------

final _focus = FocusNode();
_focus.dispose();
FocusScope.of(context).requestFocus(_focus);

Edit(
    focusNode: _focus1,


----------------------------------------

import 'package:intl/intl.dart';

final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');


*/


// linter:
//   rules:
//     camel_case_types: true
//     curly_braces_in_flow_control_structures: false
//
// analyzer:
//   exclude:
//     - flutter_webview_pro/**
//     - test/**