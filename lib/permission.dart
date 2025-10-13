import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'config.dart';
import 'model/permission_dialog.dart';

var _gps = true;
var _storage = true;
var _contacts = true;
var _microphone = true;

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({Key? key, }) : super(key: key);

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {

  _redraw(value){
    if (mounted)
      setState((){});
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  bool _waits = false;
  _wait(bool value){
      _waits = value;
      _redraw(value);
  }

  _init() async {
    _wait(true);
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      _gps = false;
    if (await Permission.storage.isDenied)
      _storage = false;
    if (await Permission.contacts.isDenied)
      _contacts = false;
    if (await Permission.microphone.isDenied)
      _microphone = false;
    _wait(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_waits)
      Scaffold(
        body: Center(
          child: loaderWidget,
        ),
      );


    return Scaffold(body: Container(
            width: Get.width,
            height: Get.height,
            padding: const EdgeInsets.only(left: 20, right: 20),
            color: bgcolor,
            child: Stack(
              children: [
                SingleChildScrollView(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      SizedBox(
                        height: MediaQuery.of(context).padding.top + 60,
                      ),

                      ..._item("Дооступ к геолокации: ", _gps, () async {
                        await gpsPermissionDialog();
                        _redraw(0);
                      }),

                      ..._item("Дооступ к фотографиям и картинкам: ", _storage, () async {
                        await storagePermissionDialog();
                        _redraw(0);
                      }),

                      ..._item("Дооступ к адресной книги: ", _contacts, () async {
                        await contactsPermissionDialog();
                        _redraw(0);
                      }),

                      ..._item("Дооступ к микрофону: ", _microphone, () async {
                        await microphonePermissionDialog();
                        _redraw(0);
                      }),


                    ],
                )),

                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    }, icon: const Icon(Icons.arrow_back_outlined),),
                ),


              ],
            )
        ));
  }

  List<Widget> _item(String text, bool enable, Function() callback){
    List<Widget> list = [];

    list.addAll([
      Row(
        children: [
          Expanded(child: Text(
              text,
              style: nativeSettingsText
          )),
          if (enable)
            Text("разрешен",
                style: nativeSettingsText.copyWith(color: Colors.green)
            )
          else
            Text("запрещен",
                style: nativeSettingsText.copyWith(color: Colors.red)
            )

        ],
      ),

      const SizedBox(height: 20),

      if (!enable)
        ...[
          _button2("Разрешить", (){
            callback();
          }, ),
          const SizedBox(height: 20),
        ],
    ]);

    return list;
  }

  _button2(String text, Function() _callback,
      {
        double? width = double.maxFinite,
        EdgeInsetsGeometry? padding,
      }){
    Color color = buttonbg;
    return Stack(
      children: <Widget>[
        Container(
            width: width,
            padding: padding ?? const EdgeInsets.only(top: 8, bottom: 8, left: 5, right: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(text, style: styleButton,
                      textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,)
            ),
          Positioned.fill(
            child: Material(
                color: Colors.transparent,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: InkWell(
                  splashColor: Colors.black.withOpacity(0.2),
                  onTap: (){
                    _callback();
                  }, // needed
                )),
          )
      ],
    );
  }

}

microphonePermissionDialog() async {
  var t = await Navigator.of(Get.context!).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) {
        return const PermissionDialog(flag: 4,);
      },
    ),
  );
  if (!t)
    return;
  PermissionStatus status = await Permission.microphone.request();
  if (status == PermissionStatus.granted)
    _microphone = true;
}

gpsPermissionDialog() async {
  /// диалог gps need
  var t = await Navigator.of(Get.context!).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) {
        return const PermissionDialog(flag: 1);
      },
    ),
  );
  if (!t)
    return;
  var permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    dprint('Location permissions are denied');
    return;
  }
  _gps = true;
}

storagePermissionDialog() async {
  /// диалог permission need
  bool t = await Navigator.of(Get.context!).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) {
        return const PermissionDialog(flag: 2,);
      },
    ),
  );
  if (t){
    await Permission.storage.request();
    await Permission.camera.request();
    final status = await Permission.storage.status;
    if (status == PermissionStatus.granted)
      _storage = true;
  }
}

contactsPermissionDialog() async {
  var t = await Navigator.of(Get.context!).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) {
        return const PermissionDialog(flag: 3,);
      },
    ),
  );
  if (!t)
    return;
  var contacts2 = await FlutterContacts.requestPermission(readonly: true);
  if (contacts2)
    _contacts = true;
}
