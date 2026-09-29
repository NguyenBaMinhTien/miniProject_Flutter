import 'user_model.dart';

@Deprecated('Use UserModel')
class User extends UserModel {
  const User({
    required this.id,
    required this.username,
    required this.balance,
  }) : super(id: id, username: username, fullName: '', cash: balance);

  @override
  final String id;
  @override
  final String username;
  final double balance;
}
