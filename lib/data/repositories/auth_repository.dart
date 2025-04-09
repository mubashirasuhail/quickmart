

import 'package:quick_mart/data/models/user_model.dart';

class AuthRepository {
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == "test@example.com" && password == "123456") {
      return UserModel(id: "1", name: "Test User", email: email, phone: "9876543210", location: "India");
    }
    return null;
  }

  Future<UserModel?> signup(String name, String email, String phone, String password, String location) async {
    await Future.delayed(const Duration(seconds: 2));
    return UserModel(id: "2", name: name, email: email, phone: phone, location: location);
  }
}
