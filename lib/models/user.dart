class User {
  const User({
    required this.id,
    required this.email,
    required this.userName,
    this.phone,
    this.profileImage,
    this.battingStyle,
    this.bowlingStyle,
    this.playerRole,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String userName;
  final String? phone;
  final String? profileImage;
  final String? battingStyle;
  final String? bowlingStyle;
  final String? playerRole;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      phone: json['phone']?.toString(),
      profileImage: json['profileImage']?.toString(),
      battingStyle: json['battingStyle']?.toString(),
      bowlingStyle: json['bowlingStyle']?.toString(),
      playerRole: json['playerRole']?.toString(),
      bio: json['bio']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'userName': userName,
    'phone': phone,
    'profileImage': profileImage,
    'battingStyle': battingStyle,
    'bowlingStyle': bowlingStyle,
    'playerRole': playerRole,
    'bio': bio,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
