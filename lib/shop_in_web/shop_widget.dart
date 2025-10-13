import 'package:constyle/browser.dart';
import 'package:constyle/config.dart';
import 'package:constyle/shop_in_web/shop_load.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

import '../widgets/image.dart';

class NativeShopScreens extends StatefulWidget {
  const NativeShopScreens({Key? key,}) : super(key: key);

  @override
  State<NativeShopScreens> createState() => _NativeShopScreensState();
}

class _NativeShopScreensState extends State<NativeShopScreens> {

  _redraw(value){
    if (mounted)
      setState((){});
  }

  @override
  void initState() {
    redrawNativeShopScreens = _redraw;
    super.initState();
  }

  @override
  void dispose() {
    // redrawNativeShopScreens = (_){};
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   var nativeData = getNativeData();
    if (nativeData.isEmpty)
      return Container();

    List<Widget> list = [];

    for (var item in nativeData)
      list.add(_item(item));

   // nativeData[3].design[0].height = 80;
   // nativeData[3].design[0].blockheight = 80;
    // list.add(_item(nativeData[3]));

    return Stack(
      children: [
        ...list
      ]
    );
  }

  Widget _item(NativeData item){

    if (item.design.isEmpty)
      return Container();

    NativeDataDesign design = item.design[0];

    return Container(
      margin: EdgeInsets.only(top: design.top, bottom: design.bottom),
      width: Get.width,
      height: design.height != 0 ? design.height : null,
      color: design.background,
      child: _getData(item, design),
    );
  }

  Widget _getData(NativeData item, NativeDataDesign design){
    List<Widget> list = [
      if (design.columns <= 1)
        SizedBox(height: 20, width: Get.width,)
    ];
    for (var item2 in item.blocks) {
      if (design.columns > 1)
        list.add(_itemBlockRow(item2, design));
      else
        list.add(_itemBlock(item2, design));
    }

    // if (design.columns > 1)
    //   return Row(
    //     children: list,
    //   );

    return SingleChildScrollView(
        child: Wrap(
      children: list,
    ));
  }

  _open(NativeDataBlocks item,){
    clearData();
    if (item.url.isNotEmpty)
      openBrowser(mainAddress+"/"+item.url);
    _redraw(0);
  }

  Widget _itemBlockRow(NativeDataBlocks item, NativeDataDesign design){


    var w = (Get.width-(10*design.columns+10) )/ design.columns;

    var img = ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: SizedBox(
          // color: Colors.green,
            // height: design.blockheight,
            width: w,
            child: item.img.endsWith(".svg") ?
            SvgPicture.network(
              item.img,
            )
                : showImage(item.img, //width: Get.width*0.4,
                // height: design.blockheight,
                fit: BoxFit.cover)
        )
    );

    var nameParams = [
      Text(item.name,
        maxLines: 2, overflow: TextOverflow.ellipsis,
        style: TextStyle(color: design.namecolor,
            fontSize: 15, fontWeight: FontWeight.w500),),
      if (item.main.isNotEmpty && item.main != "0")
        Text("${item.main} ₽", style: TextStyle(color: design.maincolor,
            fontSize: 18,
            fontWeight: FontWeight.w800),),
      HtmlWidget(
        item.params,
        textStyle: TextStyle(color: design.paramscolor,
            fontSize: 14, fontWeight: FontWeight.w400),
      )
    ];


    return InkWell(
        onTap: (){
          _open(item);
        },
        child: Container(
            height: design.blockheight,
            width: w,
            margin: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              // color: Colors.red,
                border: design.border ? Border.all(color: Colors.black.withOpacity(0.2)) : null,
                borderRadius: BorderRadius.circular(design.round ? 20 : 0),
                boxShadow: design.shadow ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(3, 3),
                  ),
                ] : null
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: img),
                ...nameParams
              ],
            ))
    );
  }

  Widget _itemBlock(NativeDataBlocks item, NativeDataDesign design){

    var img = ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
        child: SizedBox(
            height: design.blockheight,
            width: Get.width*0.4,
            child: item.img.endsWith(".svg") ?
            SvgPicture.network(
              item.img,
            )
                : showImage(item.img, width: Get.width*0.4,
                height: design.blockheight, fit: BoxFit.cover)
        )
    );

    var nameParams = [
      Text(item.name,
        maxLines: 2, overflow: TextOverflow.ellipsis,
        style: TextStyle(color: design.namecolor,
            fontSize: 15, fontWeight: FontWeight.w500),),
      if (item.main.isNotEmpty && item.main != "0")
        Text("${item.main} ₽", style: TextStyle(color: design.maincolor,
            fontSize: 18,
            fontWeight: FontWeight.w800),),
      HtmlWidget(
        item.params,
        textStyle: TextStyle(color: design.paramscolor,
            fontSize: 14, fontWeight: FontWeight.w400),
      )
    ];

    var w = Get.width;

    return InkWell(
        onTap: (){
          _open(item);
        },
        child: Container(
            height: design.blockheight,
            width: w,
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: BoxDecoration(
             border: design.border ? Border.all(color: Colors.black.withOpacity(0.2)) : null,
              borderRadius: BorderRadius.circular(design.round ? 20 : 0),
              boxShadow: design.shadow ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(3, 3),
                ),
              ] : null
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                img,
                if (item.name.isNotEmpty || item.main.isNotEmpty || item.params.isNotEmpty)
                  Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: nameParams
                        ),
                      )
                  )
              ],
            ))
    );
  }
}
