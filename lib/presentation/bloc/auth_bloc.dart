import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_mart/domain/usecases/login_usecase.dart';
import 'package:quick_mart/domain/usecases/signup_usecase.dart';
import 'package:quick_mart/presentation/bloc/auth_event.dart';
import 'package:quick_mart/presentation/bloc/auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUseCase signupUseCase;
  final LoginUseCase loginUseCase;

  AuthBloc(this.signupUseCase, this.loginUseCase) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      final user = await loginUseCase.execute(event.email, event.password);
      user != null ? emit(AuthSuccess()) : emit(AuthFailure("Invalid credentials"));
    });

    on<SignupEvent>((event, emit) async {
      emit(AuthLoading());
      final user = await signupUseCase.execute(event.name, event.email, event.phone, event.password, event.location);
      user != null ? emit(AuthSuccess()) : emit(AuthFailure("Signup failed"));
    });
  }
}
