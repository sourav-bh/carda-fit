import 'package:app/util/app_style.dart';
import 'package:flutter/material.dart';
import 'package:gradient_slide_to_act/gradient_slide_to_act.dart';

//**Diese Klasse erstellt ein benutzerdefiniertes Benachrichtigungsdialogfeld mit einem Hintergrundbild,
//  einer motivierenden Zitatzeile, einer Fitnessaufgabe und einem Schieberegler zur Bestätigung der Benachrichtigung. */
class NotificationAlertDialog extends StatelessWidget {
  final String? _image;
  final String? _motivatingQuote;
  final String? _fitnessTask;

  const NotificationAlertDialog(this._image, this._motivatingQuote, this._fitnessTask);

  @override
  Widget build(BuildContext context) {
    // final GlobalKey<SlideActionState> _key = GlobalKey();

    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(left: 20, top: 65, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black,
                    offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_motivatingQuote ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, color: AppColor.darkBlue), textAlign: TextAlign.center,),
              const SizedBox(height: 30,),
              Text(_fitnessTask ?? '', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 20), textAlign: TextAlign.center,),
              const SizedBox(height: 15,),
              Align(
                alignment: Alignment.bottomRight,
                child: GradientSlideToAct(
                  // width: 400,
                  text: "Schieben zum\nBestätigen",
                  dragableIconBackgroundColor: Colors.greenAccent,
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18),
                  backgroundColor: Colors.white,
                  onSubmit: (){
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.of(context).pop();
                    });
                  },
                  gradient:  const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColor.primary,
                        AppColor.primaryLight,
                      ]
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 45,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(45)),
                child: Image.asset(_image ?? '')
            ),
          ),
        ),
      ],
    );
  }
}