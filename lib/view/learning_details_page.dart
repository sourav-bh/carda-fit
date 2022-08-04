import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

class LearningDetailsPage extends StatefulWidget {
  const LearningDetailsPage({Key? key}) : super(key: key);

  @override
  State<LearningDetailsPage> createState() => _LearningDetailsPageState();
}

class _LearningDetailsPageState extends State<LearningDetailsPage> {

  String? _description;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _description = ModalRoute.of(context)?.settings.arguments as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        title: const Text('Details'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(0)),
              child: Image(image: const AssetImage("assets/images/nutri_food_banner.png"),
                width: MediaQuery.of(context).size.width,
              )
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Html(data: _description ?? '',
                    )
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getServerDateToString(String dateTime) {
    return DateFormat('dd MMM yyyy').format(DateFormat("dd-MM-yyyy").parse(dateTime));
  }
}