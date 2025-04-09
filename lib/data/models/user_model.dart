class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
    );
  }
}
