import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:constyle/utils.dart';
// import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../download_file.dart';

// Future<String?> _getFreeFileName(String path, String filename, int index) async {
//   var bodyName = getFileNameBody(filename);
//   var bodyExtension = getFileNameExtension(filename);
//   if (bodyName == null ||  bodyExtension == null)
//     return null;
//   var fn = "${bodyName}_$index.$bodyExtension";
//   var t = "$path$fn";
//   if (await File(t).exists()){
//     return _getFreeFileName(path, filename, index+1);
//   }
//   return fn;
// }

String _savedFile = "";

startDownload(String _urlFile, BuildContext context) async{

  if (await _checkPermission()){
    // Directory dirToSave = await _prepareSaveDir();
    // если такой файл уже существует в download папке. Надо придумать другое имя

    // var _prefs = await SharedPreferences.getInstance();

    // String? filename = getFileName(_urlFile);
    // String? newFileName = filename;
    // if (filename != null){
    //   _savedFile = dirToSave.path + "/" + filename;
    //   // _prefs.setString('downloadedFile', _savedFile);
    //   if (await File(_savedFile).exists())
    //     newFileName = await _getFreeFileName(dirToSave.path + "/", filename, 1);
    // }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadFileScreen(file: _urlFile),
      ),
    );

    // await FlutterDownloader.enqueue(
    //   headers: {
    //     'Content-Type' : "application/pdf",
    //     'Accept' : '*/*',
    //   },
    //   //
    //   url: _urlFile,
    //   fileName: newFileName,
    //   savedDir: _localPath,
    //   showNotification: true, // show download progress in status bberesar (for Android)
    //   openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    //   saveInPublicStorage: true,
    // );
  }
}

Future<bool> _checkPermission() async {
  if (Platform.isIOS) return true;
  //
  // (await _requestPermission(Permission.storage)) &&
  //     (await _requestPermission(Permission.accessMediaLocation)) &&
  //     (await _requestPermission(Permission.manageExternalStorage))

  final status = await Permission.storage.status;
  if (status != PermissionStatus.granted) {
    final result = await Permission.storage.request();
    if (result == PermissionStatus.granted) {
      return true;
    }
  } else
    return true;
  return false;
}

// var _localPath = "";

// Future<Directory> _prepareSaveDir() async {
//   _localPath = (await _findLocalPath())!;
//   final savedDir = Directory(_localPath);
//   bool hasExisted = await savedDir.exists();
//   if (!hasExisted) {
//     savedDir.create();
//   }
//   return savedDir;
// }

// Future<String?> _findLocalPath() async {
//   String? externalStorageDirPath;
//   if (Platform.isAndroid) {
//     try {
//       externalStorageDirPath = await AndroidPathProvider.downloadsPath;
//     } catch (e) {
//       final directory = await getExternalStorageDirectory();
//       externalStorageDirPath = directory?.path;
//     }
//   } else if (Platform.isIOS) {
//     externalStorageDirPath =
//         (await getApplicationDocumentsDirectory()).absolute.path;
//   }
//   return externalStorageDirPath;
// }

void downloadCallback(String id, int status, int progress) {
  WidgetsFlutterBinding.ensureInitialized();
  dprint('Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  // final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
  // send.send([id, status, progress]);
  // if (progress == 100) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([progress]);

    // try {
    //   dprint("--->   FlutterDownloader.initialize");
    //   await FlutterDownloader.initialize(
    //       debug: true // optional: set false to disable printing logs to console
    //   );
    // }catch(ex){
    //   dprint("--->   FlutterDownloader.initialize exception $ex");
    // }
    // try {
      // dprint("--->   FlutterDownloader.open");
      // var _prefs = await SharedPreferences.getInstance();
      // var _savedFile = _prefs.getString('downloadedFile') ?? "";
      // if (_savedFile.isNotEmpty) {
      //   var f = File(_savedFile+".html");
      //   if (await f.exists()){
      //     f.rename(_savedFile);
      //     launch(_savedFile.toString());
      //   }
      // }
      // FlutterDownloader.open(taskId: id);
    // }catch(ex){
    //   dprint("--->   FlutterDownloader.open exception $ex");
    // }

  // }
}

registerDownloader() async {

  dprint("registerDownloader");
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );

  FlutterDownloader.registerCallback(downloadCallback);

  ReceivePort _port = ReceivePort();

  IsolateNameServer.registerPortWithName(
      _port.sendPort, 'downloader_send_port');

  _port.listen((dynamic data) {
    int progress = data[0];
    if (progress == 100){
      if (_savedFile.isNotEmpty) {
          var f = File(_savedFile+".html");
          if (f.existsSync()){
            f.renameSync(_savedFile);
            launchUrl(Uri.parse(_savedFile.toString()), mode: LaunchMode.externalApplication);
          }
        }
    }
    // DownloadTaskStatus status = data[1];

    //updateProgress(data[2]);
  });

}


/*

добавить в proguard-rules.pro

-keep class io.flutter.**  { *; }

## Android
-keep class androidx.lifecycle.** { *; }
-keep class com.google.android.** { *; }

## Other
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

 */