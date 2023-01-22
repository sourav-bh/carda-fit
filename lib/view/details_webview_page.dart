import 'dart:io';

import 'package:app/util/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DetailsWebPage extends StatefulWidget {
  const DetailsWebPage({Key? key}) : super(key: key);

  @override
  _DetailsWebState createState() => _DetailsWebState();
}

class _DetailsWebState extends State<DetailsWebPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightPink,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: AppColor.orange,
        centerTitle: false,
        title: const Text('Details'),
        actions: [
          IconButton(
            onPressed: () {
              //like action
            },
            icon: const Icon(Icons.thumb_up_rounded, color: Colors.white,)
          ),
          IconButton(
            onPressed: () {
              //dislike action
            },
            icon: const Icon(Icons.thumb_down_rounded, color: Colors.white,)
          ),
        ],
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: 'https://www.gesundheit.de/fitness/fitness-uebungen/buerogymnastik/galerie-buerogymnastik',
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: true,
            onPageStarted: (String url) {
              print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              setState(() {
                _loading = false;
              });
              print('Page finished loading: $url');
            },
          ),
          (_loading)?Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ):SizedBox.shrink(),
        ],
      ),
    );
  }
}