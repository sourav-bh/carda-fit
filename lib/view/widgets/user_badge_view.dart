import 'package:app/model/user_info.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserBadgeView extends StatelessWidget {
  final UserLevel userLevel;

  const UserBadgeView({Key? key,
    required this.userLevel,})
      : super(key: key);

  _getImageName() {
    switch(userLevel.levelType) {
      case UserLevelType.starter:
        return 'assets/images/badge-medal-starter.svg';
      case UserLevelType.advanced:
        return 'assets/images/badge-medal-advanced.svg';
      case UserLevelType.pro:
        return 'assets/images/badge-medal-pro.svg';
      default:
        return 'assets/images/badge-medal-starter.svg';
    }
  }

  _getLabelText() {
    switch(userLevel.levelType) {
      case UserLevelType.starter:
        return 'Fitness Starter';
      case UserLevelType.advanced:
        return 'Fitness Lover';
      case UserLevelType.pro:
        return 'Fitness Pro';
      default:
        return 'Fitness Starter';
    }
  }

  _getBadgeColor() {
    switch(userLevel.level) {
      case 0:
        return AppColor.bronze;
      case 1:
        return AppColor.silver;
      case 2:
        return AppColor.gold;
      default:
        return AppColor.bronze;
    }
  }

  _getLevelTextColor() {
    switch(userLevel.levelType) {
      case UserLevelType.starter:
        return Colors.white;
      case UserLevelType.advanced:
        return Colors.white;
      case UserLevelType.pro:
        return _getBadgeColor();
      default:
        return Colors.white;
    }
  }

  double _getTopMarginForLevelText() {
    switch(userLevel.levelType) {
      case UserLevelType.starter:
        return 28;
      case UserLevelType.advanced:
        return 28;
      case UserLevelType.pro:
        return 22;
      default:
        return 28;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: CommonUtil.getRectangleBoxDecoration(Colors.transparent, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              SvgPicture.asset(
                _getImageName(),
                colorFilter: ColorFilter.mode(_getBadgeColor(), BlendMode.srcIn),
                width: 100,
                height: 75,
              ),
              Positioned(
                top: _getTopMarginForLevelText(),
                left: userLevel.level == 0 ? 34 : 32,
                child: Text('${userLevel.level + 1}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold,
                      color: _getLevelTextColor(),
                      fontSize: userLevel.levelType == UserLevelType.pro ? 24 : 28
                  ),
                ),
              ),
            ],
          ),
          Text(_getLabelText(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

}