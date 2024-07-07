import 'package:app/api/api_manager.dart';
import 'package:app/model/user_info.dart';
import 'package:app/service/database_helper.dart';
import 'package:app/util/app_constant.dart';
import 'package:app/util/app_style.dart';
import 'package:app/util/common_util.dart';
import 'package:app/util/shared_preference.dart';
import 'package:app/view/services/moji_service.dart';

//import 'package:app/view/widgets/avatar_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttermoji/defaults.dart';
import 'package:fluttermoji/fluttermoji.dart';

class AvatarPickerDialog extends StatelessWidget {
  final StringCallback selectionCallback;

  const AvatarPickerDialog({Key? key, required this.selectionCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<MojiKeyEnum, List<int>>>(
        future: MojiService.getMojiUnlockedItem(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              return AlertDialog(
                title: Text('Avatar wählen',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black87, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                insetPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                content: Column(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: FluttermojiCircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 550,
                      height: 300,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 10),
                        child: FluttermojiCustomizer(
                          scaffoldWidth: 500,
                          autosave: false,
                          attributeUnlocked: snapshot.data,
                          unlockMojiFunc: () async {
                            return await _confirmUseScorePurchaseItem(context);
                          },
                          unlockMojiCallback: (mojiKey, id) {
                            _updateMojiUnlocked(mojiKey, id);
                          },
                          lockWidget: const Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Icon(Icons.lock,
                                  size: 20, color: Colors.black38),
                            ),
                          ),
                          theme: FluttermojiThemeData(
                              boxDecoration: const BoxDecoration(
                                  boxShadow: [BoxShadow()])),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(AppColor.darkGrey),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(horizontal: 10)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    side:
                                        BorderSide(color: AppColor.darkGrey)))),
                    child: const Text('Abbrechen'),
                  ),
                  FluttermojiSaveWidget(
                    onTap: (avatar, flutterMojiMap) async {
                      await EasyLoading.show();
                      selectionCallback.call(flutterMojiMap);
                      await EasyLoading.dismiss();
                      Future.sync(() => Navigator.of(context).pop());
                    },
                    child: TextButton(
                      onPressed: null,
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              AppColor.primary),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  const EdgeInsets.symmetric(horizontal: 10)),
                          shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  side: BorderSide(color: AppColor.primary)))),
                      child: const Text('Weiter'),
                    ),
                  ),
                ],
              );
          }
        });
  }

  Future _updateMojiUnlocked(MojiKeyEnum mojiKey, int id) async {
    MojiService.saveOrUpdateMoji(mojiKey, [id]);
  }

  Future<bool> _confirmUseScorePurchaseItem(BuildContext ctx) async {
    var result = await showDialog<bool>(
      context: ctx,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(.7),
          body: Center(
            child: Container(
              decoration:
                  CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
              padding: const EdgeInsets.all(36),
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Artikel mit 20 Punkte einlösen?",
                    style: TextStyle(fontSize: 18, color: AppColor.darkBlue),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextButton(
                        onTap: () {
                          Navigator.of(_).pop(true);
                        },
                        child: const Text("OK"),
                      ),
                      const SizedBox(width: 50),
                      CustomTextButton(
                        onTap: () {
                          Navigator.of(_).pop(false);
                        },
                        child: const Text("Abbrechen"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result == true) {
      const int DEFAULT_MOJI_PRICE = 20;
      try {
        await EasyLoading.show();
        bool result = await _subtractScore();
        await EasyLoading.dismiss();
        if (!result) _showPurchaseFailed(ctx);
        return result;
      } catch (e) {
        await EasyLoading.dismiss();
        return false;
      }
    }
    return result ?? false;
  }

  Future<bool> _subtractScore() async {
    const int DEFAULT_MOJI_PRICE = 20;
    UserInfo? userInfo =
        await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
    if (userInfo == null || userInfo.score == null) return false;
    if (userInfo.score! - DEFAULT_MOJI_PRICE < 0) return false;
    var result = await ApiManager()
        .updateUserScore(AppCache.instance.userServerId, -DEFAULT_MOJI_PRICE);
    if (result) {
      userInfo =
          await DatabaseHelper.instance.getUserInfo(AppCache.instance.userDbId);
      if (userInfo != null) {
        if (userInfo.score != null) {
          userInfo.score = userInfo.score! - DEFAULT_MOJI_PRICE;
          await DatabaseHelper.instance.updateUser(userInfo, userInfo.dbId!);
        }
      }
    }
    return result;
  }

  _showPurchaseFailed(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (_) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(.7),
            body: Center(
              child: Container(
                decoration:
                    CommonUtil.getRectangleBoxDecoration(Colors.white54, 10),
                padding: const EdgeInsets.all(36),
                margin: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Leider hast du nicht die erforderlichen Punkte, um diesen Artikel freizuschalten, aber du kannst schnell einige Punkte bekommen, indem du deine täglichen Aufgaben erledigst.",
                      style: TextStyle(fontSize: 18, color: AppColor.darkBlue),
                    ),
                    const SizedBox(height: 20),
                    CustomTextButton(
                      onTap: () {
                        Navigator.of(_).pop();
                      },
                      child: const Text("Abbrechen"),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class CustomTextButton extends StatelessWidget {
  final Widget child;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Function()? onTap;

  const CustomTextButton({
    super.key,
    required this.child,
    this.foregroundColor = Colors.white,
    this.backgroundColor = AppColor.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(foregroundColor!),
          backgroundColor: MaterialStateProperty.all<Color>(backgroundColor!),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(horizontal: 10)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  side: BorderSide(color: AppColor.primary)))),
      child: child,
    );
  }
}