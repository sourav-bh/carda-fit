import 'package:fluttermoji/fluttermoji_assets/fluttermojimodel.dart';

/// Default list of icons that are rendered in the bottom row, indicating
/// the attributes available to modify.
///
/// These icons come bundled with the library and the paths below
/// are indicative of that.
const List<String> defaultAttributeIcons = [
  "attributeicons/hair.svg",
  "attributeicons/haircolor.svg",
  "attributeicons/beard.svg",
  "attributeicons/beardcolor.svg",
  "attributeicons/outfit.svg",
  "attributeicons/outfitcolor.svg",
  "attributeicons/eyes.svg",
  "attributeicons/eyebrow.svg",
  "attributeicons/mouth.svg",
  "attributeicons/skin.svg",
  "attributeicons/accessories.svg",
];

/// Default list of titles that are rendered at the top of the widget, indicating
/// which attribute the user is customizing.
const List<String> defaultAttributeTitles = [
  "Frisur",
  "Haarfarbe",
  "Gesichtshaar",
  "Gesichtshaarfarbe",
  "Kleidung",
  "Kleidungsfarbe",
  "Augen",
  "Augenbrauen",
  "Mund",
  "Haut",
  "Zubehör"
];

/// List of keys used internally by this library to dereference
/// attributes and their values in the business logic.
///
/// This aspect is not modifiable by you at any stage of the app.
const List<String> attributeKeys = [
  "topType",
  "hairColor",
  "facialHairType",
  "facialHairColor",
  "clotheType",
  "clotheColor",
  "eyeType",
  "eyebrowType",
  "mouthType",
  "skinColor",
  "accessoriesType",
];

/// [List<int>] is all moji index unlock
/// if unlock new moji please clone model and add index of new unlock value
Map<MojiKeyEnum, List<int>> attributeUnlockedItemMap = {
  MojiKeyEnum.topType: <int>[0, 1, 2, 3, 4, 5],
  MojiKeyEnum.hairColor: <int>[0, 1, 2, 3, 4, 5],
  MojiKeyEnum.facialHairType: <int>[0, 1, 2, 3, 4, 5],
  MojiKeyEnum.facialHairColor: <int>[0, 1, 2, 3, 4, 5],
  MojiKeyEnum.clotheColor: <int>[0, 1, 2, 3, 4, 5],
  MojiKeyEnum.eyeType: <int>[0, 1, 2, 3, 4, 5],
  MojiKeyEnum.eyebrowType: <int>[0, 1, 2, 3, 4, 5],
  MojiKeyEnum.mouthType: <int>[0, 1, 2, 3, 4, 5],
  MojiKeyEnum.skinColor: <int>[0, 1, 2, 3, 4, 5],
  MojiKeyEnum.accessoriesType: <int>[0, 1, 2, 3, 4, 5],
};

enum MojiKeyEnum {
  topType,
  hairColor,
  facialHairType,
  facialHairColor,
  clotheType,
  clotheColor,
  eyeType,
  eyebrowType,
  mouthType,
  skinColor,
  accessoriesType
}

String mojiKeyEnumToString(MojiKeyEnum value) {
  switch (value) {
    case MojiKeyEnum.topType:
      return "topType";
    case MojiKeyEnum.hairColor:
      return "hairColor";
    case MojiKeyEnum.facialHairType:
      return "facialHairType";
    case MojiKeyEnum.facialHairColor:
      return "facialHairColor";
    case MojiKeyEnum.clotheType:
      return "clotheType";
    case MojiKeyEnum.clotheColor:
      return "clotheColor";
    case MojiKeyEnum.eyeType:
      return "eyeType";
    case MojiKeyEnum.eyebrowType:
      return "eyebrowType";
    case MojiKeyEnum.mouthType:
      return "mouthType";
    case MojiKeyEnum.skinColor:
      return "skinColor";
    case MojiKeyEnum.accessoriesType:
      return "accessoriesType";
    default:
      return '';
  }
}

MojiKeyEnum getMojiEnum(String key) {
  switch (key) {
    case "topType":
      return MojiKeyEnum.topType;
    case "hairColor":
      return MojiKeyEnum.hairColor;
    case "facialHairType":
      return MojiKeyEnum.facialHairType;
    case "facialHairColor":
      return MojiKeyEnum.facialHairColor;
    case "clotheType":
      return MojiKeyEnum.clotheType;
    case "clotheColor":
      return MojiKeyEnum.clotheColor;
    case "eyeType":
      return MojiKeyEnum.eyeType;
    case "eyebrowType":
      return MojiKeyEnum.eyebrowType;
    case "mouthType":
      return MojiKeyEnum.mouthType;
    case "skinColor":
      return MojiKeyEnum.skinColor;
    case "accessoriesType":
      return MojiKeyEnum.accessoriesType;
  }
  return MojiKeyEnum.topType;
}

Map<MojiKeyEnum, List<int>> updateUnlockedItemMap(
    Map<MojiKeyEnum, List<int>> mojiMap, MojiKeyEnum key, List<int> unlockAt) {
  var oldList = List<int>.from(mojiMap[key] ?? []);
  mojiMap[key] = [...oldList, ...unlockAt];
  return mojiMap;
}
