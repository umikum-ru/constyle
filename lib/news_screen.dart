import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config.dart';
import 'model/load_news.dart';
import 'news_details_screen.dart';
import 'widgets/image.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<NewsScreen> {

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    var ret = await loadNewsData();
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
          Center(child: loaderWidget), //Loader30(color: textColor, size: 25)),

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

    list.add(const SizedBox(height: 20,));

    for (var item in newsData){
      list.add(InkWell(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopNewsDetails(item: item),
            ),
          );
        },
          child: Column(
            children: [
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
                              child: showImage(item.img, width: Get.width, height: 200)
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
                                Expanded(child: Text(item.page, style: const TextStyle(color: Colors.white),)),
                              ],
                            ),
                          )
                      )
                    ],
                  )),
              Container(
                margin: const EdgeInsets.all(15),
                  child: Text(item.short, style: const TextStyle(color: Colors.black),)),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 1,
                color: Colors.black,
              )
            ],
          )
      ));
    }

    list.add(const SizedBox(height: 100,));

    return list;
  }

}



