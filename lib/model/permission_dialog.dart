import 'package:flutter/material.dart';
import '../config.dart';
import '../main.dart';
import '../widgets/button2.dart';

class PermissionDialog extends StatefulWidget {
  const PermissionDialog({Key? key, this.flag = 1, }) : super(key: key);

  final int flag;

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: Stack(
      children: [
        Center(
          child: Container(
            color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.flag == 1 ? permissionGps
                : widget.flag == 2 ? permissionFiles
                : widget.flag == 3 ? permissionPhoneBook
                : permissionMicrophone,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: button2("Хорошо", (){
                    Navigator.pop(context, true);
                  }, )),
                  const SizedBox(width: 10),
                  Expanded(child: button2("Потом", (){
                    prefs.setString("permission_${widget.flag}", "later");
                    Navigator.pop(context, false);
                  }, )),
                ],
              )
            ],
          )
          ),
        )
      ]
    ));
  }
}