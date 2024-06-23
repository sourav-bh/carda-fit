import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/view/widgets/avatar_image_picker.dart';
import 'package:flutter/material.dart';

class AvatarPickerDialog extends StatelessWidget {
  final StringCallback selectionCallback;

  const AvatarPickerDialog({Key? key, required this.selectionCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Avatar wählen',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
      content: SizedBox(
        width: 300,
        height: 325,
        child: AvatarImagePickerView(
          onItemSelected: (String? avatar) {
            debugPrint("avatar selected: $avatar");
            selectionCallback.call(avatar);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(AppColor.primary),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 10)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      side: BorderSide(color: AppColor.primary)
                  )
              )
          ),
          child: const Text('Weiter'),
        ),
      ],
    );
  }
}