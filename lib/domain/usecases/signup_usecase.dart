

import 'package:quick_mart/data/models/user_model.dart';
import 'package:quick_mart/data/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository authRepository;

  SignupUseCase(this.authRepository);

  Future<UserModel?> execute(String name, String email, String phone, String password, String location) {
    return authRepository.signup(name, email, phone, password, location);
  }
}
