import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'config.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key, required this.callback}) : super(key: key);

  final Function() callback;

  @override
  _GameScreenState2 createState() => _GameScreenState2();
}

class _GameScreenState2 extends State<PrivacyScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri("$mainAddress/privacyinfo/"))
          ),
          Container(
            margin: const EdgeInsets.only(top: 30, left: 15),
          width: 45,
          height: 45,
           decoration: const BoxDecoration(
             color: Colors.white,
             shape: BoxShape.circle,
           ),
            child: IconButton(
              onPressed: () {
                widget.callback();
              }, icon: const Icon(Icons.arrow_back_outlined)),
          ),
        ],
      )
    );
  }
}

