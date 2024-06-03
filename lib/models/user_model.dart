import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final DateTime birthDate;

  @HiveField(4)
  final String dormitory;

  @HiveField(5)
  final List<int> favorites;

  User(
    this.email,
    this.name,
    this.password,
    this.birthDate,
    this.dormitory,
    this.favorites,
  );
}
