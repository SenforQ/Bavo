class VoiceSubmitData {
  final String name;
  final String idNumber;
  final String gender;
  final int age;
  final String hobby;
  final String? photoPath;
  final String voiceType;

  VoiceSubmitData({
    required this.name,
    required this.idNumber,
    required this.gender,
    required this.age,
    required this.hobby,
    this.photoPath,
    required this.voiceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'idNumber': idNumber,
      'gender': gender,
      'age': age,
      'hobby': hobby,
      'photoPath': photoPath,
      'voiceType': voiceType,
    };
  }

  factory VoiceSubmitData.fromJson(Map<String, dynamic> json) {
    return VoiceSubmitData(
      name: json['name'] ?? '',
      idNumber: json['idNumber'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      hobby: json['hobby'] ?? '',
      photoPath: json['photoPath'],
      voiceType: json['voiceType'] ?? '',
    );
  }
}
