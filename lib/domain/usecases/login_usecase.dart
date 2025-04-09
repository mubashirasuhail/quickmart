

import 'package:quick_mart/data/models/user_model.dart';
import 'package:quick_mart/data/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;
  
  LoginUseCase(this.authRepository);

  Future<UserModel?> execute(String email, String password) {
    return authRepository.login(email, password);
  }
}
