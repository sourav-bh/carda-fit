import 'dart:io';

import 'package:app/model/learning.dart';
import 'package:app/model/user_learning_contents.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
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
  late WebViewController _webViewController;
  LearningContent? _learningContent;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadIntent();
  }

  _loadIntent() {
    _learningContent = ModalRoute.of(context)?.settings.arguments as LearningContent;

    _loadWebviewController(_learningContent?.contentUri ?? "");
  }

  _likeDislikeAction(bool isLiked) async {
    UserLearningContent userLc = UserLearningContent();
    userLc.userId = AppCache.instance.userId;
    userLc.contentId = _learningContent?.id;
    userLc.isFavourite = isLiked;

    int id = await DatabaseHelper.instance.addUserLearningContent(userLc);
    print(id);
  }

  _loadWebviewController(String contentUrl) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColor.lightPink)
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
            _loading = false;
            });
            print('Page finished loading: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(contentUrl));
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
              _likeDislikeAction(true);
            },
            icon: const Icon(Icons.thumb_up_rounded, color: Colors.white,)
          ),
          IconButton(
            onPressed: () {
              //dislike action
              _likeDislikeAction(false);
            },
            icon: const Icon(Icons.thumb_down_rounded, color: Colors.white,)
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          (_loading)
          ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
          : SizedBox.shrink(),
        ],
      ),
    );
  }
}