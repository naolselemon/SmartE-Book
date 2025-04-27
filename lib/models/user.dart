class User {
  final String id;
  final String name;
  final String email;
  late String password;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password = "",
  });
}
