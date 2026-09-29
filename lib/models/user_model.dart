class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.cash,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String? ?? '',
      cash: (json['cash'] as num).toDouble(),
    );
  }

  final String id;
  final String username;
  final String fullName;
  final double cash;

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'cash': cash,
      };

  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    double? cash,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      cash: cash ?? this.cash,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          id == other.id &&
          username == other.username &&
          fullName == other.fullName &&
          cash == other.cash;

  @override
  int get hashCode => Object.hash(id, username, fullName, cash);
}
