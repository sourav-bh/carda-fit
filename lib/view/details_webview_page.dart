import 'dart:io';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        title: const Text('Details'),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: 'https://www.healthline.com/health/fitness/office-exercises#exercises-while-standing',
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