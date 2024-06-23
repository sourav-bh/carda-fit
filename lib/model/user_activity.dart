class UserActivity {
  final int? id;
  final int? lastTrophyId;
  final int? loginCount;
  final int? lastLogin;
  final int? userId;

  UserActivity({
     this.id,
    this.lastTrophyId,
    this.loginCount,
    this.lastLogin,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastTrophyId': lastTrophyId,
      'loginCount': loginCount,
      'lastLogin': lastLogin,
      'userId': userId,
    };
  }

  Map<String, dynamic> toDBMap() {
    return {
      'lastTrophyId': lastTrophyId,
      'loginCount': loginCount,
      'lastLogin': lastLogin,
      'userId': userId,
    };
  }

  factory UserActivity.fromMap(Map<String, dynamic> map) {
    return UserActivity(
      id: map['id'] as int?,
      lastTrophyId: map['lastTrophyId'] as int?,
      loginCount: map['loginCount'] as int?,
      lastLogin: map['lastLogin'] as int?,
      userId: map['userId'] as int?,
    );
  }

  UserActivity copyWith({
    int? id,
    int? lastTrophyId,
    int? loginCount,
    int? lastLogin,
    int? userId,
  }) {
    return UserActivity(
      id: id ?? this.id,
      lastTrophyId: lastTrophyId ?? this.lastTrophyId,
      loginCount: loginCount ?? this.loginCount,
      lastLogin: lastLogin ?? this.lastLogin,
      userId: userId ?? this.userId,
    );
  }
}