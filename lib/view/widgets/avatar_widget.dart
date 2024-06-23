import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:random_avatar/random_avatar.dart';

class AvatarWidget extends StatelessWidget {
  final String? image;
  final double? size;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    required this.image,
    this.size,
    this.backgroundColor = Colors.transparent,
  });

  bool isSvgImage() {
    if ([null, ''].contains(image)) {
      return false;
    }
    if (!image!.startsWith('<svg')) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!isSvgImage()) {
      return RandomAvatar(image ?? "n/a", height: size, width: size);
    }
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(9999)),
      child: Container(
        width: size,
        height: size,
        color: backgroundColor,
        child: SvgPicture.string(
          image!,
          height: size,
          width: size,
          placeholderBuilder: (context) => const Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
      ),
    );
  }
}