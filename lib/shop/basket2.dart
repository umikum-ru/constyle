import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config.dart';
import '../model/load_shop.dart';
import '../utils.dart';
import '../widgets/button2.dart';
import 'package:intl/intl.dart';
import 'basket3.dart';

class Basket2Screen extends StatefulWidget {
  const Basket2Screen({Key? key, required this.name, required this.phone,}) : super(key: key);

  final String name;
  final String phone;

  @override
  State<Basket2Screen> createState() => _Basket2ScreenState();
}

class _Basket2ScreenState extends State<Basket2Screen> {

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

    // var found = false;
    // for (var item in catalog)
    //   if (item.controller.text.isNotEmpty)
    //     found = true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
      children: [
        SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50,),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Подтвердите данные",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff1f1f1f),
                      fontSize: 18,
                      fontWeight: FontWeight.w500),)
              ],
            ),
            const SizedBox(height: 10,),
            ..._list(),

          ],
        )),

        // if (!found)
        //   const Center(
        //     child: Text("Корзина пустая",
        //       style: TextStyle(color: Color(0xff707070),
        //           fontSize: 18,
        //           fontWeight: FontWeight.w400),),
        //   ),

        Container(
          margin: const EdgeInsets.only(left: 0, top: 30),
            child: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back_sharp))),

        if (_waits)
          Container(
            width: Get.width,
            height: Get.height,
            color: Colors.white,
            child: Center(child: loaderWidget) //Loader30(color: textColor, size: 25)),
          )

      ]
    ));
  }

  List<Widget> _list(){
    List<Widget> list = [];
    var allCount = 0;
    var allCost = 0;
    for (var item in catalog){
      if (item.controller.text.isNotEmpty) {
        list.add(_item(item));
        allCount++;
        allCost += (toInt(item.controller.text)*toInt(item.price));
      }
    }

    var found = false;
    for (var item in catalog)
      if (item.controller.text.isNotEmpty)
        found = true;

    list.add(Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ИТОГО - товаров: $allCount, на сумму: $allCost ₽",
          style: const TextStyle(color: Color(0xff1f1f1f),
              fontSize: 18,
              fontWeight: FontWeight.w400),),

        const SizedBox(height: 20,),

        Text("Ваше имя: ${widget.name}",
          style: const TextStyle(color: Color(0xff1f1f1f),
              fontSize: 14,
              fontWeight: FontWeight.w400),),

        const SizedBox(height: 10,),

        Text("Телефон: ${widget.phone}",
          style: const TextStyle(color: Color(0xff1f1f1f),
              fontSize: 14,
              fontWeight: FontWeight.w400),),

        const SizedBox(height: 30,),

        button2("Желаемая дата${_datePressed ? "\n${DateFormat('yyyy.MM.dd').format(_now!)}" : ""}", () async {
          _date();
        }, ),

        const SizedBox(height: 10,),

        button2("Желаемое время${_timePressed ? "\n${_nowTime!.format(context)}" : ""}", () async {
          _time();
        }, ),

        const SizedBox(height: 20,),

        button2("Далее", () async {
          _wait(true);
          Future.delayed(const Duration(milliseconds: 1000), () async {
            for (var item in catalog)
              item.controller.text = "";
            Navigator.pop(context);
            Navigator.pop(context);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Basket3Screen(),
              ),
            );
            _redraw(0);
          });
        }, enable: _datePressed && _timePressed && found)

      ],
    )));

    return list;
  }

  var _datePressed = false;
  var _timePressed = false;
  DateTime? _now = DateTime.now();
  TimeOfDay? _nowTime = TimeOfDay.now();

  _date() async {
    var t = await showDatePicker(
        context: context,
        initialDate: _now ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: const Color(0xff002447),
              // accentColor: const Color(0xff002447),
              colorScheme: const ColorScheme.light(primary: Color(0xff002447)),
              buttonTheme: const ButtonThemeData(
                  textTheme: ButtonTextTheme.primary
              ),
            ),
            child: child!,
          );
    });
    if (t != null) {
      _datePressed = true;
      _now = t;
    }else
      _datePressed = false;
    _redraw(0);
  }

  _time() async {
    var t = await showTimePicker(
        context: context,
        initialTime: _nowTime ?? TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            );});
    if (t != null) {
      _timePressed = true;
      _nowTime = t;
    }else
      _timePressed = false;
    _redraw(0);
  }

  Widget _item(ShopData item) {
    return Container(
            margin: const EdgeInsets.only(top: 10, bottom: 15, left: 15, right: 15),
            child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.page,
                style: const TextStyle(color: Color(0xffcc982c),
                    fontSize: 15, fontWeight: FontWeight.w500),),
              // if (item.price.isNotEmpty && item.price != "0")
              Row(
                children: [
                  Text("${item.price} ₽",
                    style: const TextStyle(color: Color(0xff1f1f1f),
                        fontSize: 18,
                        fontWeight: FontWeight.w800),),
                  const Text(" x ",
                    style: TextStyle(color: Color(0xff707070),
                        fontSize: 14,
                        fontWeight: FontWeight.w400),),
                  Text(item.controller.text,
                    style: const TextStyle(color: Color(0xff1f1f1f),
                        fontSize: 18,
                        fontWeight: FontWeight.w800),),
                  const Text(" = ",
                    style: TextStyle(color: Color(0xff707070),
                        fontSize: 14,
                        fontWeight: FontWeight.w400),),
                  Text((toInt(item.controller.text)*toInt(item.price)).toString() + " ₽",
                    style: const TextStyle(color: Color(0xff1f1f1f),
                        fontSize: 18,
                        fontWeight: FontWeight.w800),),
                ],
              )
            ],
          )
    );
  }
}