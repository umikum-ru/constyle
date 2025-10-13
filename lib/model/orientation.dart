import 'package:flutter/services.dart';

import '../config.dart';
import '../utils.dart';

bool makePortrait(){
  // if (!orientation)
  //   return false;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  return true;
}

bool makeLandscape(){
  // if (!orientation)
  //   return false;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  return true;
}

checkOrientation(String str){
  if (str == "MakeAppVertical")
    makePortrait();
  if (str == "MakeAppHorizontal")
    makeLandscape();
}

startOrientation(){
  dprint("startOrientation orientation=$orientation");
  if (orientation)
    makeLandscape();
}