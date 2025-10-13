import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../utils.dart';
import '../widgets/button2.dart';
import 'offline_send.dart';
import 'offline_storage.dart';

/*

1. сначало выбираем сессию в жиалоге
  _sessionData.currentSession = сессия

2. сессия если выбрана, при каждой загрезке
  Spectro_OfflineStart()

3. потом можно вызвать /offlinesave/


 */
class SessionDataItem{
  SessionDataItem({required this.data, this.dateCreate = "", required this.ids,
    required this.dataCreateForSort});

  String dateCreate;
  DateTime dataCreateForSort;
  List<String> data;
  List<String> ids;

  Map toJson() => {
    'data' : data,
    'ids' : ids,
    'dateCreate': dateCreate
  };

  factory SessionDataItem.fromJson(Map<String, dynamic> data){

    List<String> _cache = [];
    if (data['data'] != null)
      for (var element in List.from(data['data'])) {
        _cache.add(element.toString());
      }

    List<String> ids = [];
    if (data['ids'] != null)
      for (var element in List.from(data['ids'])) {
        ids.add(element.toString());
      }

    var dateCreate = data["dateCreate"] != null ? data["dateCreate"].toString() : "";

    DateTime dataCreateForSort = DateTime.parse(dateCreate);

    return SessionDataItem(
        dataCreateForSort: dataCreateForSort,
        dateCreate: dateCreate,
        data: _cache,
        ids: ids
    );
  }

}

var first = true;

class SessionData{
  SessionData({required this.items, this.currentSession = ""});

  String currentSession;
  List<SessionDataItem> items;

  Map toJson() => {
    'items' : items.map((i) => i.toJson()).toList(),
    'currentSession': currentSession
  };

  factory SessionData.fromJson(Map<String, dynamic> data){

    List<SessionDataItem> items = [];
    if (data['items'] != null)
      for (var element in List.from(data['items'])) {
        items.add(SessionDataItem.fromJson(element));
      }
    items.sort((b, a) => a.dataCreateForSort.compareTo(b.dataCreateForSort));

    return SessionData(
      items: items,
      currentSession: data["currentSession"] != null ? data["currentSession"].toString() : "",
    );
  }
}

var _sessionData = SessionData(items: []);

Future<String?> _readSessionFile() async {
  try {
    var directory = await getApplicationDocumentsDirectory();
    var _file = File('${directory.path}/sessions.json');
    if (await _file.exists()) {
      var str = await _file.readAsString();
      var data = json.decode(str);
      _sessionData = SessionData.fromJson(data);
      if (first){
        _sessionData.currentSession = "";
        _writeSessionFile();
        first = false;
      }
    }
  }catch(ex){
    return ex.toString();
  }
  return null;
}

Future<String?> _writeSessionFile() async {
  try {
    var directory = await getApplicationDocumentsDirectory();
    await File('${directory.path}/sessions.json').writeAsString(json.encode(_sessionData.toJson()));

  }catch(ex){
    return ex.toString();
  }
  return null;
}

offlineOnPageLoad(InAppWebViewController controller) async {
  if (_sessionData.currentSession.isEmpty) {
    dprint("Страница загружена. Сессия для offline mode не выбрана ${_sessionData.currentSession}");
    return;
  }
  var ids = "";
  if (_sessionData.currentSession.isNotEmpty){
    for (var item in _sessionData.items){
      if (_sessionData.currentSession == item.dateCreate){
        for (var item2 in item.ids){
          if (item2.isEmpty)
            continue;
          if (ids.isNotEmpty)
            ids += "-";
          ids += item2;
        }
      }
    }
  }
  await controller.callAsyncJavaScript(functionBody: "Spectro_OfflineStart(\"$ids\");");
  dprint("Страница загружена. Spectro_OfflineStart(\"$ids\") currentSession=${_sessionData.currentSession}");
}

offlineSave(String url, InAppWebViewController controller){
  if (_sessionData.currentSession.isEmpty) {
    offlineLocalDataStart(url, controller);
    return;
  }

  try{
    var uri = Uri.parse(url);
    var s = uri.pathSegments;
    if (s.isNotEmpty && s[0] != "offlinesave")
      return;

    String id = "";
    if (s.length >= 2) {
      var t = int.tryParse(s[1]);
      if (t != null)
        id = t.toString();
    }

    if (url.endsWith("/"))
      url = url.substring(0, url.length-1);
    var i = url.indexOf("/offlinesave/");
    url = url.substring(i+"/offlinesave/".length);
    dprint(url);
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    var t2 = stringToBase64.decode(url);
    var t3 = t2.split("-|-");
    if (t3.isNotEmpty){
      var t4 = t3[0].split("::");
      if (t4.length == 2){
        id = t4[1];
      }
    }
 //   print(t2);
    for (var item in _sessionData.items)
      if (_sessionData.currentSession == item.dateCreate){
        item.data.add(url);
        if (!item.ids.contains(id))
          item.ids.add(id);
        _writeSessionFile();
       // offlineOnPageLoad(controller);
        break;
      }

  }catch(ex){
    dprint("offlineSave $ex");
  }
}

openDialogOfflineMode(BuildContext context2) async {
  var ret = await _readSessionFile();
  if (ret != null)
    messageError(context2, ret);
  else {
    await Navigator.of(context2).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) {
          return _Popup(x: 20, y: 100, parentContext: context2);
        },
      ),
    );
  }
}

class _Popup extends StatefulWidget {
  const _Popup({Key? key, required this.x, required this.y,
    required this.parentContext}) : super(key: key);

  final double x;
  final double y;
  final BuildContext parentContext;

  @override
  State<_Popup> createState() => _PopupState();
}

class _PopupState extends State<_Popup> {

  _redraw(value){
    Future.delayed(const Duration(milliseconds: 20), () {
      if (mounted)
        setState((){});
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _closeDialog(){
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
            children: [
              Container(
                width: Get.width,
                height: Get.height,
                color: const Color(0x20626262),
              ),

              GestureDetector(
                  behavior: HitTestBehavior.deferToChild,

                  onTap: (){
                    _closeDialog();
                    //Navigator.pop(context);
                  },
                  child: Container(
                    width: Get.width,
                    height: Get.height,
                    color: const Color(0x20f0f0f0),
                  )),

              GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    _closeDialog();
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: widget.x, top: widget.y),
                      height: Get.height-200,
                      width: Get.width - 40,
                      child: SingleChildScrollView(child: Container(
                    child: _buildList()
                  ))))

            ]
        ));
  }

  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  Widget _buildList(){

    List<Widget> list = [];
    if (_sessionData.items.isNotEmpty) {
      list.addAll([
        Container(
          margin: const EdgeInsets.only(top: 15),
          height: 1, color: const Color(0x80808080),),
        Container(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: const Text("Сессии:")),
        Container(
          height: 1, color: const Color(0x80808080),),
      ]);
      for (var item in _sessionData.items)
        list.addAll([
          Column(
            children: [
              const SizedBox(height: 15,),
              if (_sessionData.currentSession == item.dateCreate)
                ...[
                  const Text("Текущая", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w800,
                      fontSize: 20),),
                  const SizedBox(height: 15,)
                ],
              Row(
                children: [
                  const Text("Время создания:"),
                  const SizedBox(width: 10,),
                  Text(formatter.format(DateTime.parse(item.dateCreate)))
                ],
              ),
              const SizedBox(height: 15,),
              Row(
                children: [
                  if (_sessionData.currentSession != item.dateCreate)
                    Expanded(child: button2("Продолжить", () {
                      _sessionData.currentSession = item.dateCreate;
                      _writeSessionFile();
                      _redraw(0);
                    }) )
                  else
                    Expanded(child: button2("Остановить", () {
                      _sessionData.currentSession = "";
                      _writeSessionFile();
                      _redraw(0);
                    }) ),
                  const SizedBox(width: 10,),
                  Expanded(child: button2("Отправить", () async {
                    Navigator.pop(context);
                    var text = "";
                    for (var item in item.data){
                      var t2 = stringToBase64.decode(item);
                      if (text.isNotEmpty)
                        text += "_|_";
                      text += t2;
                    }
                    sendOffline(widget.parentContext, text);
                  }))

                ],
              ),
              const SizedBox(height: 15,),
              //if (item.data.isNotEmpty)
              Row(
                children: [
                  Expanded(child: button2("Просмотр", () async {
                    await Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (_, __, ___) {
                          return _Popup2(x: 20, y: 100, item: item);
                        },
                      ),
                    );
                  })
                  ),

                  const SizedBox(width: 10,),

                  Expanded(child: (item.data.isNotEmpty)
                      ?
                  button2("Удалить", () {
                    if (_sessionData.currentSession == item.dateCreate)
                      _sessionData.currentSession = "";
                    _sessionData.items.remove(item);
                    _writeSessionFile();
                    _redraw(0);
                  }, )
                  // button2("Копировать данные", () {
                  //   var text = "";
                  //   for (var item in item.data){
                  //     if (text.isNotEmpty) text += "\n";
                  //     var t2 = stringToBase64.decode(item);
                  //     text += t2;
                  //   }
                  //   Clipboard.setData(ClipboardData(text: text));
                  //   messageOk(context, "Текст скопирован");
                  // })
                      : const Text("Нет данных", textAlign: TextAlign.center,)
                  ),
                ],
              ),
              const SizedBox(height: 15,),
              Container(
                height: 1, color: const Color(0x80808080),),
            ],
          )

        ]);
      list.add(Container(height: 15,));
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border.all(color: const Color(0xff2B2A29), width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_sessionData.items.isEmpty)
            const SizedBox(height: 50),
          button2("Создать новую сессию", () {
            var d = DateTime.now().toString();
            _sessionData.items.add(SessionDataItem(data: [], ids: [], dateCreate: d, dataCreateForSort: DateTime.now()));
            _sessionData.currentSession = d;
            _sessionData.items.sort((b, a) => a.dataCreateForSort.compareTo(b.dataCreateForSort));
            _writeSessionFile();
            _redraw(0);
          }),

          // const SizedBox(height: 20,),
          ...list,
          if (_sessionData.items.isEmpty)
            const SizedBox(height: 50),
        ],
      ),
    );
  }

}

class _Popup2 extends StatefulWidget {
  const _Popup2({Key? key, required this.x, required this.y, required this.item}) : super(key: key);

  final double x;
  final double y;
  final SessionDataItem item;

  @override
  State<_Popup2> createState() => _PopupState2();
}

class _PopupState2 extends State<_Popup2> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _closeDialog(){
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
            children: [
              Container(
                width: Get.width,
                height: Get.height,
                color: const Color(0x20626262),
              ),

              GestureDetector(
                  behavior: HitTestBehavior.deferToChild,

                  onTap: (){
                    _closeDialog();
                    //Navigator.pop(context);
                  },
                  child: Container(
                    width: Get.width,
                    height: Get.height,
                    color: const Color(0x20f0f0f0),
                  )),

              GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    _closeDialog();
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: widget.x, top: widget.y),
                      height: Get.height-200,
                      width: Get.width - 40,
                      child: SingleChildScrollView(child: Container(
                          child: _buildList()
                      ))))

            ]
        ));
  }

  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  Widget _buildList(){

    List<Widget> list = [];
    for (var item in widget.item.data){
      var t2 = stringToBase64.decode(item);
      list.addAll([
        Column(
          children: [
            const SizedBox(height: 15,),
            // Text(item),
            // const SizedBox(height: 5,),
            Text(t2),
            const SizedBox(height: 15,),
            Container(
              height: 1, color: const Color(0x80808080),),
          ],
        )

      ]);
      // list.add(Container(height: 15,));
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border.all(color: const Color(0xff2B2A29), width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: const Text("Просмотр")),
          Container(
              height: 1, color: const Color(0x80808080),),

          ...list,

          const SizedBox(height: 20,),
          button2("Копировать", () {
            Navigator.pop(context);
            var text = "";
            for (var item in widget.item.data){
              if (text.isNotEmpty) text += "\n";
              var t2 = stringToBase64.decode(item);
              text += t2;
            }
            Clipboard.setData(ClipboardData(text: text));
            messageOk(context, "Текст скопирован");
          }),

        ],
      ),
    );
  }

}

