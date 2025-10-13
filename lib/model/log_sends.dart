import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

addLogResponse(String action, String str) async {
  if (!_read){
    _read = true;
    await _readSessionFile();
  }
  _responseData.add(ResponseData(action: action, response: str, date: DateTime.now()));
  _writeSessionFile();
}

var _read = false;

Future<String?> _writeSessionFile() async {

  try {
    var directory = await getApplicationDocumentsDirectory();
    await File('${directory.path}/response.json').writeAsString(json.encode(
        _responseData.map((i) => i.toJson()).toList())
    );

  }catch(ex){
    return ex.toString();
  }
  return null;
}

Future<String?> _readSessionFile() async {
  try {
    var directory = await getApplicationDocumentsDirectory();
    var _file = File('${directory.path}/response.json');
    if (await _file.exists()) {
      var str = await _file.readAsString();
      var data = json.decode(str);
      _responseData = [];
      for (var item in data)
        _responseData.add(ResponseData.fromJson(item));
    }
  }catch(ex){
    return ex.toString();
  }
  return null;
}

List<ResponseData> _responseData = [];

class ResponseData{
  ResponseData({required this.action, required this.response, required this.date});

  final String response;
  final String action;
  final DateTime date;

  Map toJson() => {
    'date' : date.millisecondsSinceEpoch,
    'response': response,
    'action': action
  };

  factory ResponseData.fromJson(Map<String, dynamic> data){
    return ResponseData(
      date: data["date"] != null ? DateTime.fromMillisecondsSinceEpoch(data["date"]) : DateTime(1970, 1, 1),
      response: data["response"] != null ? data["response"].toString() : "",
      action: data["action"] != null ? data["action"].toString() : "",
    );
  }
}

class ResponseLogScreen extends StatefulWidget {
  const ResponseLogScreen({Key? key,}) : super(key: key);

  @override
  State<ResponseLogScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<ResponseLogScreen> {

  _redraw(value){
    if (mounted)
      setState((){});
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    if (!_read){
      _read = true;
      await _readSessionFile();
    }
    _redraw(0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  final formatter = DateFormat('dd.MM.yyyy HH:mm:ss');

  @override
  Widget build(BuildContext context) {

    List<Widget> list = [];
    for (var item in _responseData) {
      list.addAll([
        Text(
          "${formatter.format(item.date)} ${item.action}  ${item.response}",
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 20),
      ]);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
            child: ListView(
          children: list,
        ))

      ]
    ));
  }
}