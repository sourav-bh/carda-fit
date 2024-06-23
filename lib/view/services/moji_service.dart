import 'package:app/model/moji_unlocked.dart';
import 'package:app/service/database_helper.dart';
import 'package:fluttermoji/defaults.dart';

class MojiService {
  static Future saveOrUpdateMoji(
      MojiKeyEnum mojiKey, List<int> mojiUnlockedIds) async {
    var mojiKeyString = mojiKeyEnumToString(mojiKey);
    var exist = await DatabaseHelper.instance.findByMojiKey(mojiKeyString);
    int result;
    if (exist != null) {
      var mojiUnlockIds = List<int>.from(exist.mojiUnlockIds);
      mojiUnlockIds.addAll(mojiUnlockedIds);
      var update = exist.copyWith(mojiUnlockIds: mojiUnlockIds);
      result =
          await DatabaseHelper.instance.updateMojiUnlocked(update, exist.id!);
      return result;
    }
    var add = MojiUnlockModel(
      flutterMojiKey: mojiKeyString,
      mojiUnlockIds: mojiUnlockedIds,
    );
    result = await DatabaseHelper.instance.addMojiUnlocked(add);
    return result;
  }

  static Future iniMojiFreeItem() async {
    var mojiList = await DatabaseHelper.instance.getAllMojiUnlocked();
    if (mojiList.isNotEmpty) return;
    List<Future> futures = [];
    for (var item in MojiKeyEnum.values) {
      var add = MojiUnlockModel(
        flutterMojiKey: mojiKeyEnumToString(item),
        mojiUnlockIds: [0, 1, 2, 3, 4, 5],
      );
      futures.add(DatabaseHelper.instance.addMojiUnlocked(add));
    }
    await Future.wait(futures);
  }

  static Future<Map<MojiKeyEnum, List<int>>> getMojiUnlockedItem() async {
    var mojiList = await DatabaseHelper.instance.getAllMojiUnlocked();
    Map<MojiKeyEnum, List<int>> map = {};
    for (var item in mojiList) {
      var mojiKey = getMojiEnum(item.flutterMojiKey!);
      map[mojiKey] = item.mojiUnlockIds;
    }
    return map;
  }
}