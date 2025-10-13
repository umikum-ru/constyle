import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:constyle/utils.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceDetails() async {
  String? identifier;
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      final String? androidId = await const AndroidId().getId();
      // var build = await deviceInfoPlugin.androidInfo;
      if (androidId != null)
        identifier = androidId;  // UUID for Android
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      identifier = data.identifierForVendor;  // UUID for iOS -- UUID for iOS will change on application reinstall.
    }
  } catch (ex){
    dprint('Failed to get platform version');
  }

  return identifier ?? "";
}