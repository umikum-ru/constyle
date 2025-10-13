import 'package:flutter/material.dart';
import '../config.dart';

// кнопка на всю ширину экрана

button2(String text, Function() _callback,
    {
      bool enable = true,
      double? radius,
      double? width = double.maxFinite,
      EdgeInsetsGeometry? padding,
    }){
  Color color = buttonbg;
  return Stack(
    children: <Widget>[
      Container(
          width: width,
          padding: padding ?? const EdgeInsets.only(top: 15, bottom: 15, left: 5, right: 5),
          decoration: BoxDecoration(
            color: (enable) ? color : Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(radius ?? 20),
          ),
          child: FittedBox(fit: BoxFit.scaleDown,
              child: Text(text, style: styleButton,
                textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,))
      ),
      if (enable)
        Positioned.fill(
          child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(20) ),
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

button2b(String text, Function _callback, {TextStyle? style, bool enable = true, Color? color,}){
  var _color = Colors.black;
  if (color != null)
    _color = color;
  return Stack(
    children: <Widget>[
      Container(
          decoration: BoxDecoration(
            color: (enable) ? _color : Colors.grey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Container(
                  padding: const EdgeInsets.only(top: 7, bottom: 7, left: 13, right: 13),
                  child: FittedBox(fit: BoxFit.scaleDown,
                    child: Text(text, style: style,
                      textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
                  )),

              if (enable)
                Positioned.fill(
                  child: Material(
                      color: Colors.transparent,
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10) ),
                      child: InkWell(
                        splashColor: Colors.black.withOpacity(0.2),
                        onTap: (){
                          _callback();
                        }, // needed
                      )),
                )

            ],
          )
      ),
    ],
  );
}
