import 'package:flutter/material.dart';
import '../widgets/button2.dart';

class Basket3Screen extends StatefulWidget {
  const Basket3Screen({Key? key, }) : super(key: key);

  @override
  State<Basket3Screen> createState() => _Basket3ScreenState();
}

class _Basket3ScreenState extends State<Basket3Screen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
      children: [
        Center(child: Container(
          margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Ваш заказ отправлен",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xff1f1f1f),
                      fontSize: 18,
                      fontWeight: FontWeight.w500),),

            const SizedBox(height: 30,),

            Container(
              margin: const EdgeInsets.all(60),
                child: button2("Хорошо", () async {
              Navigator.pop(context);
            }, )),
          ],
        ))),

        Container(
          margin: const EdgeInsets.only(left: 0, top: 30),
            child: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back_sharp))),

      ]
    ));
  }

}