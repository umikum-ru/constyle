import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

edit(TextEditingController controller, {String hint = "",
  TextInputType type = TextInputType.number, Function(String)? onchange, bool obscure = false}){
  return
    Container(
      height: 40,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xffD7D7D7),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (String value) async {
          if (onchange != null)
            onchange(value);
        },
        cursorColor: Colors.black,
        style: const TextStyle(fontSize: 17, color: Color(0xff000000),
            fontWeight: FontWeight.w500,
            ),
        cursorWidth: 1,
        keyboardType: type,
        obscureText: obscure,
        textAlign: TextAlign.left,
        maxLines: 1,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 17, color: Color(0xff676767),
              fontWeight: FontWeight.w500,
              ),
          //contentPadding: const EdgeInsets.only(bottom: 10)
        ),
      ),
    );
}

editText(TextEditingController controller, {String hint = "",
  TextInputType type = TextInputType.text, Function(String)? onchange, bool obscure = false}){
  return
    Container(
      height: 40,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xffD7D7D7),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: (String value) async {
          if (onchange != null)
            onchange(value);
        },
        cursorColor: Colors.black,
        style: const TextStyle(fontSize: 17, color: Color(0xff000000),
          fontWeight: FontWeight.w500,
        ),
        cursorWidth: 1,
        keyboardType: type,
        obscureText: obscure,
        textAlign: TextAlign.left,
        maxLines: 1,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 17, color: Color(0xff676767),
            fontWeight: FontWeight.w500,
          ),
          //contentPadding: const EdgeInsets.only(bottom: 10)
        ),
      ),
    );
}
