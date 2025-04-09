abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);
}

class SignupEvent extends AuthEvent {
  final String name, email, phone, password, location;

  SignupEvent(this.name, this.email, this.phone, this.password, this.location);
}
