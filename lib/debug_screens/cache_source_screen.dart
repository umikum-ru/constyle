import 'dart:io';

import 'package:constyle/widgets/button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/cache.dart';
import '../utils.dart';

class CacheSourceScreen extends StatefulWidget {
  const CacheSourceScreen({Key? key,
    required this.fileName}) : super(key: key);

  final String fileName;

  @override
  _SendCodeScreenState createState() => _SendCodeScreenState();
}

class _SendCodeScreenState extends State<CacheSourceScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  var _text = "";
  bool image = false;

  _init() async {
    if (widget.fileName.endsWith(".jpg") || widget.fileName.endsWith(".png"))
      image = true;
    else {
      try {
        _text = await loadCacheSource(context, widget.fileName) ?? "";
        setState(() {
        });
      } catch (ex) {
        image = true;
        setState(() {
        });
      }
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: const EdgeInsets.all(5),
        child: Stack(
          children: [
            ListView(
              children: [
                const Text("Url:"),
                Text(findInCacheByLocalAddress(widget.fileName)),
                const Text("File Name:"),
                Text(widget.fileName),
                const Text("---source---"),
                if (!image)
                  Text(_text)
                else
                  Container(
                    width: windowWidth,
                    height: windowWidth,
                    color: Colors.green.withAlpha(20),
                    child: Image.file(File(widget.fileName))
                  )
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child:  Row(
                children: [
                  Expanded(child: button2("Cancel", (){
                    Navigator.pop(context,);
                  }, )),
                  if (!image)
                    Expanded(child: button2("Copy", (){
                      Clipboard.setData(ClipboardData(text: _text));
                      messageOk(context, "Текст скопирован");
                    }, )),
                ],
              )
            )
          ],
        ))
    );
  }
}

