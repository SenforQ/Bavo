class UserInfo {
  final String name;
  final String gender;
  final String signature;
  final String avatarPath;
  final String backgroundPath;

  UserInfo({
    required this.name,
    required this.gender,
    required this.signature,
    required this.avatarPath,
    required this.backgroundPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'signature': signature,
      'avatarPath': avatarPath,
      'backgroundPath': backgroundPath,
    };
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'] ?? 'Bavo',
      gender: json['gender'] ?? '',
      signature: json['signature'] ?? 'No signature',
      avatarPath: json['avatarPath'] ?? 'assets/user_defalut_icon.webp',
      backgroundPath: json['backgroundPath'] ?? 'assets/mine_top_bg.webp',
    );
  }

  UserInfo copyWith({
    String? name,
    String? gender,
    String? signature,
    String? avatarPath,
    String? backgroundPath,
  }) {
    return UserInfo(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      signature: signature ?? this.signature,
      avatarPath: avatarPath ?? this.avatarPath,
      backgroundPath: backgroundPath ?? this.backgroundPath,
    );
  }
}
