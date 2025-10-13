import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

var _phoneFormatter = MaskTextInputFormatter(
    mask: '+7 (@##) ###-##-##',
    filter: {
      "#": RegExp(r'([0-9])') ,
      "@": RegExp(r'([0,1,2,3,4,5,6,8,9])')
    },
    type: MaskAutoCompletionType.lazy
);

edit9(TextEditingController controller, {TextStyle? style, TextStyle? hintStyle, String hint = "",
  TextInputType type = TextInputType.text, Function(String)? onchange, bool isPhone = false,
  Function()? onSuffixIconPress, Function()? onclick, bool showSuffix = true, String text = "Номер телефона"
}){
  bool obscure = false;

  if (isPhone) {
    hint = "+7 (___) ___-__-__";
    type = TextInputType.phone;
  }

  return Container(
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
              // if (value == "+7 (7") {
                // controller.text = "";
                //_phoneFormatter.clear();

                // _phoneFormatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue.empty);
              // }
              if (onchange != null)
                onchange(value);
            },
            onTap: onclick,
            inputFormatters: isPhone ? [_phoneFormatter] : [],
            cursorColor: Colors.black,
            style: style,
            cursorWidth: 1,
            keyboardType: type,
            obscureText: obscure,
            textAlign: TextAlign.left,
            maxLines: 1,
            decoration: InputDecoration(
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 17, color: Color(0xff676767),
                  fontWeight: FontWeight.w500,
                ),
                // contentPadding: EdgeInsets.only(bottom: 10)
            ),
          ),
    );
}
