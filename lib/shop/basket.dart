import 'package:constyle/shop/shop_screen.dart';
import 'package:constyle/widgets/edit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/load_shop.dart';
import '../utils.dart';
import '../widgets/button2.dart';
import '../widgets/edit9.dart';
import '../widgets/image.dart';
import 'basket2.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({Key? key,}) : super(key: key);

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {

  _redraw(value){
    if (mounted)
      setState((){});
  }

  @override
  void initState() {
    super.initState();
  }

  var nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    _phoneNumberController.dispose();
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
        ListView(
          children: [
            const SizedBox(height: 20,),
            const Text("Корзина",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff1f1f1f),
                fontSize: 18,
                fontWeight: FontWeight.w500),),
            const SizedBox(height: 10,),
            ..._list(),

          ],
        ),

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
              print("tap");
              showNativeWindowsTabText.value = "Заказать";
            }, icon: const Icon(Icons.arrow_back_sharp)))
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
      margin: const EdgeInsets.all(15),
        child: Column(
      children: [
        Text("ИТОГО - товаров: $allCount, на сумму: $allCost ₽",
          style: const TextStyle(color: Color(0xff1f1f1f),
              fontSize: 18,
              fontWeight: FontWeight.w400),),

        const SizedBox(height: 20,),
        Container(height: 1, width: Get.width, color: Colors.grey,),
        const SizedBox(height: 20,),

        const Text("Оформление заказа",
          style: TextStyle(color: Color(0xff1f1f1f),
              fontSize: 24,
              fontWeight: FontWeight.w400),),

        const SizedBox(height: 20,),

        Row(
          children: [
            const Text("Ваше имя:",
              style: TextStyle(color: Color(0xff1f1f1f),
                  fontSize: 14,
                  fontWeight: FontWeight.w400),),
            const SizedBox(width: 20,),
            Expanded(child: editText(nameController, onchange: _redraw))
          ],
        ),

        const SizedBox(height: 10,),

        Row(
          children: [
            const Text("Телефон:",
              style: TextStyle(color: Color(0xff1f1f1f),
                  fontSize: 14,
                  fontWeight: FontWeight.w400),),
            const SizedBox(width: 20,),
            Expanded(child: edit9(_phoneNumberController, isPhone: true, onSuffixIconPress: (){
              _phoneNumberController.text = "";
              _redraw(0);
            }, onclick: (){
              _redraw(0);
            }, showSuffix: _phoneNumberController.text.isNotEmpty,
                onchange: (_){
                  _redraw(0);
                }
            ),)
          ],
        ),

        const SizedBox(height: 30,),

        button2("Далее", () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Basket2Screen(name: nameController.text,
                phone: clearPhoneNumber(_phoneNumberController.text),),
            ),
          );
          _redraw(0);
        }, enable: clearPhoneNumber(_phoneNumberController.text).isNotEmpty
            && nameController.text.isNotEmpty && found),

        if (!found)
          ...[
            const SizedBox(height: 8,),
            const Center(
              child: Text("Корзина пустая",
                style: TextStyle(color: Color(0xfff00000),
                    fontSize: 13,
                    fontWeight: FontWeight.w400),),
            ),
          ]

      ],
    )));

    return list;
  }


  Widget _item(ShopData item) {
    return Container(
            height: 130,
            width: Get.width,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10),),
                    child: SizedBox(
                        height: 200,
                        width: Get.width * 0.2,
                        child: showImage(item.img, width: Get.width * 0.4,
                            height: 200,
                            fit: BoxFit.cover)
                    )
                ),
                Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),

                      child: Column(
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

                              _plusMinus(toInt(item.controller.text), (int v){
                                if (v == 0)
                                  item.controller.text = "";
                                else
                                  item.controller.text = v.toString();
                                _redraw(0);
                              }),

                              // Text(item.controller.text,
                              //   style: const TextStyle(color: Color(0xff1f1f1f),
                              //       fontSize: 18,
                              //       fontWeight: FontWeight.w800),),
                              const Text(" = ",
                                style: TextStyle(color: Color(0xff707070),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400),),
                              Expanded(child: Text((toInt(item.controller.text)*toInt(item.price)).toString() + " ₽",
                                style: const TextStyle(color: Color(0xff1f1f1f),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800),)),
                            ],
                          )



                          // Row(
                          //   children: [
                          //     const Text("Кол", style: TextStyle(color: Color(
                          //         0xff707070),
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.w400),),
                          //     const SizedBox(width: 10,),
                          //     // Expanded(child: edit(item.controller, onchange: _redraw))
                          //   ],
                          // ),


                        ],
                      ),
                    )
                )
              ],
            )
    );
  }


  _plusMinus(int _num, Function(int) setNum){
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xfff0f0f0),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                    padding: const EdgeInsets.only(left: 10, right: 15, top: 5, bottom: 5),
                    child: const Icon(Icons.remove, color: Color(0xff1E2934),)
                ),
                Positioned.fill(
                  child: Material(
                      color: Colors.transparent,
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        customBorder:  RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                        splashColor: Colors.black.withOpacity(0.1),
                        onTap: (){
                          if (_num > 0){
                            setNum(_num-1);
                            _redraw(0);
                          }

                          // callback();
                        }, // needed
                      )),
                )
              ],
            ),

            Text(_num.toString(), style: const TextStyle(color: Color(0xff1f1f1f),
                fontSize: 18,
                fontWeight: FontWeight.w800),),

            Stack(
              children: [
                Container(
                    padding: const EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5),
                    child: const Icon(Icons.add, color: Color(0xff1E2934),)
                ),
                Positioned.fill(
                  child: Material(
                      color: Colors.transparent,
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        customBorder:  RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                        splashColor: Colors.black.withOpacity(0.1),
                        onTap: (){
                          setNum(_num+1);
                          _redraw(0);
                        }, // needed
                      )),
                )
              ],
            )
          ],
        ));

  }
}