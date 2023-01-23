import 'dart:async';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskAlertPage extends StatefulWidget {
  const TaskAlertPage({Key? key}) : super(key: key);

  @override
  _TaskAlertPageState createState() => _TaskAlertPageState();
}

class _TaskAlertPageState extends State<TaskAlertPage> {

  Timer? _timer;
  double _progress = 0;
  String image = "https://i.picsum.photos/id/239/1739/1391.jpg?hmac=-Zh20gMdOuV7tHr4wGEUqACAxdvb7gkDlKKS9MIE1TU";

  @override
  void initState() {
    super.initState();

    _loadWebsiteMetaData();
  }

  void _loadWebsiteMetaData() async {
    Metadata? _metadata = await AnyLinkPreview.getMetadata(
      link: "https://www.yoga-stilvoll.de/blog/uttanasana-stehende-vorwaertsbeuge/",
      cache: const Duration(days: 7),
    );
    print(_metadata?.title);
    print(_metadata?.image);
    setState(() {
      image = _metadata?.image ?? "https://i.picsum.photos/id/239/1739/1391.jpg?hmac=-Zh20gMdOuV7tHr4wGEUqACAxdvb7gkDlKKS9MIE1TU";
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer){
      setState(() {
        if (_progress >= 1) {
          _cancelTimer();
        } else {
          _progress += 0.01;
        }
      });
    });
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: false,
          title: const Text('Über uns'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircularProgressIndicator(
              strokeWidth: 4,
              backgroundColor: Colors.cyanAccent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              value: _progress,
            ),
            const SizedBox(width: 16),
            TextButton(
                child: const Text('Start timer'),
                onPressed: (){
                  if(_timer == null){
                    _progress = 0;
                    _startTimer();
                  }
                }
            ),
            Image.network(image, height: 200),
            AnyLinkPreview(
              link: "https://www.yoga-stilvoll.de/blog/uttanasana-stehende-vorwaertsbeuge/",
              displayDirection: UIDirection.uiDirectionHorizontal,
              showMultimedia: true,
              bodyMaxLines: 5,
              bodyTextOverflow: TextOverflow.ellipsis,
              titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15,),
              bodyStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              errorBody: 'Show my custom error body',
              errorTitle: 'Show my custom error title',
              errorWidget: Container(
                color: Colors.grey[300],
                child: const Text('Oops!'),
              ),
              errorImage: "https://google.com/",
              cache: const Duration(days: 7),
              backgroundColor: Colors.grey[300],
              borderRadius: 12,
              removeElevation: false,
              boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.grey)],
              onTap: () {

              }, // This disables tap event
            )
          ],
        )
    );
  }
}
