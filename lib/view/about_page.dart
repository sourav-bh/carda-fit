import 'package:app/util/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {

  String _version = '1.0.0';

  Future<void> _getSystemDevice() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  void initState() {
    _getSystemDevice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: false,
          title: const Text('About Us'),
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Image.asset('assets/images/transparent_logo.png', height: 100)),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'App Version',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.darkBlue
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                _version,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.darkGrey
                ),
              ),
            ],
          ),
        )
    );
  }
}
