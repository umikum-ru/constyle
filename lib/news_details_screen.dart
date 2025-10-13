import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

import 'model/load_news.dart';
import 'widgets/image.dart';

class ShopNewsDetails extends StatefulWidget {
  const ShopNewsDetails({Key? key, required this.item}) : super(key: key);

  final NewsData item;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<ShopNewsDetails> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          color: Colors.white,
          height: Get.height,
            child: ListView(
              children: [
                const SizedBox(height: 20,),
                Container(
                    height: 200,
                    width: Get.width,
                    margin: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                                height: 200,
                                width: Get.width,
                                child: showImage(widget.item.img, width: Get.width, height: 200)
                            )
                        ),
                        Container(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 30,
                              width: Get.width,
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(150),
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(widget.item.page, style: const TextStyle(color: Colors.white),)),
                                ],
                              ),
                            )
                        )
                      ],
                    )),
                Container(
                    margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                    child: Text(widget.item.short, style: const TextStyle(color: Colors.black),)),

                // const SizedBox(height: 10,),

                Container(
                    margin: const EdgeInsets.all(10),
                    child: HtmlWidget(widget.item.descr)),

                const SizedBox(height: 100,)
              ]
            )
        )

      ],
    ));
  }
}




