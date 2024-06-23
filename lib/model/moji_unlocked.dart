class MojiUnlockModel {
  final int? id;
  final String? flutterMojiKey;
  final List<int> mojiUnlockIds;

  const MojiUnlockModel({
    this.id,
    this.flutterMojiKey,
    this.mojiUnlockIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flutterMojiKey': flutterMojiKey,
      'unlockIds': mojiUnlockIds,
    };
  }

  Map<String, dynamic> toDBMap() {
    return {
      'id': id,
      'flutterMojiKey': flutterMojiKey,
      'unlockIds': mojiUnlockIds.join(','),
    };
  }

  factory MojiUnlockModel.fromMap(Map<String, dynamic> map) {
    var mojiUnlockIdsString = map['unlockIds'] as String;
    var mojiUnlockIds = mojiUnlockIdsString.split(',');
    var mojiUnlockIdsList = mojiUnlockIds.map((e) => int.parse(e)).toList();
    return MojiUnlockModel(
      id: map['id'] as int,
      flutterMojiKey: map['flutterMojiKey'] as String,
      mojiUnlockIds: mojiUnlockIdsList,
    );
  }

  MojiUnlockModel copyWith({
    int? id,
    String? flutterMojiKey,
    List<int>? mojiUnlockIds,
  }) {
    return MojiUnlockModel(
      id: id ?? this.id,
      flutterMojiKey: flutterMojiKey ?? this.flutterMojiKey,
      mojiUnlockIds: mojiUnlockIds ?? this.mojiUnlockIds,
    );
  }
}