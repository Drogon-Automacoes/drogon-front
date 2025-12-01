import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_service.dart';
import '../data/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Estados Possíveis
abstract class LoginState {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final UserModel user;
  LoginSuccess(this.user);
}
class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}


class LoginCubit extends Cubit<LoginState> {
  final AuthService authService;

  LoginCubit(this.authService) : super(LoginInitial());

  Future<void> logar(String email, String password) async {
    emit(LoginLoading());
    try {
      await authService.login(email, password);
      final user = await authService.getUserMe();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', user.tipo);
      if (user.nomeCondominio != null) {
        await prefs.setString('condominio_nome', user.nomeCondominio!);
      } else {
        await prefs.remove('condominio_nome');
      }
      emit(LoginSuccess(user));
    } catch (e) {
      final msg = e.toString().replaceAll("Exception: ", "");
      emit(LoginError(msg));
    }
  }

}