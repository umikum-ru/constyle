import 'package:constyle/utils.dart';
import 'package:constyle/widgets/button2.dart';
import 'package:constyle/widgets/edit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config.dart';
import '../model/load_shop.dart';
import '../shop/shop_item.dart';
import '../widgets/image.dart';

var showNativeWindowsTabText = "Заказать".obs;

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<ShopPage> {

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    var ret = await loadShopData();
    if (ret != null)
      messageError(context, ret);
    _wait = false;
    _redraw(0);
  }

  _redraw(value){
    if (mounted)
      setState(() {
      });
  }

  bool _wait = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_wait)
          Center(child: loaderWidget),
          // Center(child: Loader30(color: textColor, size: 25)),

        Container(
          color: Colors.white,
          height: Get.height,
            child: ListView(
              children: _getList(),
            )
        )

      ],
    );
  }

  List<Widget> _getList(){
    List<Widget> list = [];

    list.add(const SizedBox(height: 10,));
    list.add(Row(
      children: [
        Expanded(child: Container()),
        Expanded(child: button2("Корзина", () async {
          showNativeWindowsTabText.value = "basket";
          // await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const BasketScreen(),
          //   ),
          // );
          // _redraw(0);
        }, )),
        const SizedBox(width: 10,)
      ],
    ));
    list.add(const SizedBox(height: 10,));

    for (var item in catalog){
      list.add(_item(item));
    }

    list.add(const SizedBox(height: 100,));

    return list;
  }

  Widget _item(ShopData item){
    return InkWell(
        onTap: (){
          itemShopItemPage = item;
          showNativeWindowsTabText.value = "shop_item";
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ShopItemPage(item: item),
          //   ),
          // );
        },
        child: Container(
            height: 200,
            width: Get.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(3, 3),
                ),
              ],

            ),
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                    child: SizedBox(
                        height: 200,
                        width: Get.width*0.4,
                        child: showImage(item.img, width: Get.width*0.4, height: 200, fit: BoxFit.cover)
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
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xffcc982c),
                              fontSize: 15, fontWeight: FontWeight.w500),),
                          if (item.price.isNotEmpty && item.price != "0")
                            Text("${item.price} ₽", style: const TextStyle(color: Color(0xff1f1f1f),
                                fontSize: 18,
                                fontWeight: FontWeight.w800),),
                          Row(
                            children: [
                              const Text("Кол", style: TextStyle(color: Color(0xff707070),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),),
                              const SizedBox(width: 10,),
                              Expanded(child: edit(item.controller, onchange: _redraw))
                            ],
                          ),
                          button2("Заказать", () async {
                            if (toInt(item.controller.text) != 0)
                              showNativeWindowsTabText.value = "basket";
                            // await Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const BasketScreen(),
                            //   ),
                            // );
                            _redraw(0);
                          }, enable: item.controller.text.isNotEmpty)

                        ],
                      ),
                    )
                )
              ],
            ))
    );
  }
}



