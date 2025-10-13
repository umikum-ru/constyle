import 'package:constyle/widgets/button2.dart';
import 'package:flutter/material.dart';
import '../model/cache.dart';
import 'cache_source_screen.dart';

class AllFilesScreen extends StatefulWidget {
  const AllFilesScreen({Key? key}) : super(key: key);

  @override
  _SendCodeScreenState createState() => _SendCodeScreenState();
}

class _SendCodeScreenState extends State<AllFilesScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  List<FileData> all = [];

  @override
  void initState() {
    all = getAllFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: const EdgeInsets.all(5),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 100, top: 30),
              children: _childs()
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child:  Row(
                children: [
                  Expanded(child: button2("Cancel", (){
                    Navigator.pop(context,);
                  }, )),
                ],
              )
            )
          ],
        ))
    );
  }

  List<Widget> _childs(){
    List<Widget> list = [];
    for (var item in all) {
      list.add(InkWell(
        onTap: (){
          _open(item);
        },
        child: Container(
        padding: const EdgeInsets.all(5),
        color: Colors.blue.withAlpha(50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.url),
              const SizedBox(height: 10,),
              Text("Local file: ${item.localFile}"),
            ],
          )
      )));
      list.add(const SizedBox(height: 10,));
    }
    return list;
  }

  _open(FileData item) async{
    var s = await cacheGetPath(item.localFile);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CacheSourceScreen(fileName: s, ),
      ),
    );
  }
}

