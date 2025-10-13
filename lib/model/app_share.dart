import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../utils.dart';

appShare(String uri, BuildContext context){
  try{
    var str = uri.toString();

    var t = "/appshare/?image=data:image/png;base64,";
    var index = str.indexOf(t);
    if (index != -1){
      index += t.length;
      str = str.substring(index);
      return _openType(str, "image/png");
    }

    t = "/appshare/?image=data:image/jpeg;base64,";
    index = str.indexOf(t);
    if (index != -1){
      index += t.length;
      str = str.substring(index);
      return _openType(str, "image/jpeg");
    }

    t = "/appshare/?image=data:image/gif;base64,";
    index = str.indexOf(t);
    if (index != -1){
      index += t.length;
      str = str.substring(index);
      return _openType(str, "image/gif");
    }

  }catch(ex){
    messageError(context, ex.toString());
  }
}

_openType(String str, String mime){

  dprint("share image");

  Uint8List bytes = base64Decode(str);
  XFile file = XFile.fromData(bytes, mimeType: mime);
  Share.shareXFiles([file]);
}
