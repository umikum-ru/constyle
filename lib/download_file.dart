import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:constyle/utils.dart';
import 'package:constyle/widgets/button2.dart';
// import 'package:constyle/widgets/loader30.dart';
import 'package:path_provider/path_provider.dart';

import 'config.dart';

/// В manifest добавить
/// <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
///     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
///
/// <application
///   android:requestLegacyExternalStorage="true"
///
/// <application
///         <provider
///             android:name="androidx.core.content.FileProvider"
///             android:authorities="${applicationId}.provider"
///             android:exported="false"
///             android:grantUriPermissions="true">
///             <meta-data
///                 android:name="android.support.FILE_PROVIDER_PATHS"
///                 android:resource="@xml/provider_paths" />
///         </provider>

class DownloadFileScreen extends StatefulWidget {
  const DownloadFileScreen({Key? key, required this.file}) : super(key: key);

  final String file;

  @override
  _DownloadFileScreenState createState() => _DownloadFileScreenState();
}

class _DownloadFileScreenState extends State<DownloadFileScreen> {

  _redraw(){
    if (mounted)
      setState(() {
      });
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  var _localPath = "";

  Future<String?> _findLocalPath() async {
    String? externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        // externalStorageDirPath = await AndroidPathProvider.downloadsPath;
        final Directory? downloadsDir = await getDownloadsDirectory();
        externalStorageDirPath = downloadsDir?.path;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  Future<Directory> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return savedDir;
  }

  var totalBytes = 0;
  String downloadedFile = "";
  var _savedFile = "";

  _init() async {

    var f = widget.file;

    try {
      Directory dirToSave = await _prepareSaveDir();

      String? filename = getFileName(f);
      if (filename != null) {
        _savedFile = dirToSave.path + "/" + filename;
        downloadedFile = filename;
        if (await File(_savedFile).exists()) {
          var t = await _getFreeFileName(dirToSave.path + "/", filename, 1);
          if (t != null) {
            _savedFile = dirToSave.path + "/" + t;
            downloadedFile = t;
          }
        }
      }

      var response = await Dio().get(widget.file,
        options: Options(
          headers: {
            // 'Content-type': 'application/json',
            // "Authorization": "Bearer ${user.token}"
          },
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (int count, int total) {
          var p = count / (total / 100);
          dprint("progress count=$count total=$total $p");
          totalBytes = count;
          _redraw();
        },
      );

      if (response.statusCode == 200) {
        final body = response.data;
        File file = File(_savedFile);
        await file.writeAsBytes(body);
      }
      _load = true;
      _redraw();
    }catch(ex){
      messageError(context, ex.toString());
    }
  }

  var _load = false;

  Future<String?> _getFreeFileName(String path, String filename, int index) async {
    var bodyName = getFileNameBody(filename);
    var bodyExtension = getFileNameExtension(filename);
    if (bodyName == null ||  bodyExtension == null)
      return null;
    var fn = "${bodyName}_$index.$bodyExtension";
    var t = "$path$fn";
    if (await File(t).exists()){
      return _getFreeFileName(path, filename, index+1);
    }
    return fn;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                child: _load ?
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Файл $downloadedFile сохранен в Загрузки", style: const TextStyle(fontSize: 16), textAlign: TextAlign.center,),
                        // SizedBox(height: 15,),
                        // button2("Открыть", (){
                        //   print("file://" + _savedFile);
                        //   launch("file:" + _savedFile);
                        // })
                      ],
                    )
                  )
                  : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // const Loader30(color: textColor, size: 25),
                    loaderWidget,
                    const SizedBox(height: 30,),
                    const Text("Загружаем", style: TextStyle(fontSize: 16),),
                    const SizedBox(height: 5,),
                    Text("$totalBytes байт", style: const TextStyle(fontSize: 16),),
                  ],
                )
            ),
            Container(
              margin: const EdgeInsets.all(20),
              alignment: Alignment.bottomCenter,
              child: button2("Отмена", (){
                Navigator.pop(context);
              }),
            )

          ],
        )
    );
  }
}

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  // Реализация callback функции для flutter_downloader
  // Эта функция будет вызываться из фонового изолята
  dprint('Download $id: status=$status, progress=$progress');
}
