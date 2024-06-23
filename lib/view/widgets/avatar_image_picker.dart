import 'package:app/util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import 'avatar_widget.dart';

class AvatarImagePickerView extends StatefulWidget {
  final ValueChanged<String?>? onItemSelected;

  const AvatarImagePickerView({Key? key, this.onItemSelected}) : super(key: key);

  @override
  State<AvatarImagePickerView> createState() => _AvatarImagePickerState();
}

class _AvatarImagePickerState extends State<AvatarImagePickerView> {
  final List<String> _avatarData = [];
  var selectedAvatar = "";

  @override
  void initState() {
    for (int i=0; i<60; i++) {
      _avatarData.add(CommonUtil.getRandomString(6));
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      primary: false,
      childAspectRatio: 1,
      shrinkWrap: true,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 4,
      children: List.generate(_avatarData.length, (index) {
        return GestureDetector(
            onTap: () {
              setState(() {
                selectedAvatar = _avatarData[index];
              });
              print('Click ${_avatarData[index]}');
              widget.onItemSelected?.call(_avatarData[index]);
            },
            child: SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RandomAvatar(_avatarData[index], height: 50, width: 50),
                  Visibility(
                    visible: selectedAvatar == _avatarData[index],
                    child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.6)),
                        child: const Icon(Icons.check, size: 30.0, color: Colors.white,)
                    ),
                  )
                ],
              ),
            ),
        );
      }),
    );
  }
}