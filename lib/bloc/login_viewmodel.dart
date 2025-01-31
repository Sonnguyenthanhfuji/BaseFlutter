import 'package:base_flutter/bloc/base_viewmodel.dart';
import 'package:base_flutter/model/login_response.dart';
import 'package:base_flutter/repository/user_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';
import 'package:rxdart/rxdart.dart';
import '../repository/local_storage_repository.dart';

@Injectable()
class LoginViewModel extends BaseViewModel {
  // input
  void onChangedLogin(String value) => _loginInputController.add(value);
  void onChangedPass(String value) => _passInputController.add(value);
  final _loginInputController = BehaviorSubject<String>();
  final _passInputController = BehaviorSubject<String>();

  // output
  final loginOutputController = BehaviorSubject<String>();
  final passOutputController = BehaviorSubject<String>();
  final successController = BehaviorSubject<LoginResponse>();

  // di
  final UserRepository user;
  final LocalStorageRepository local;
  LoginViewModel({required this.user, required this.local});

  validate() {
    if (_loginInputController.valueOrNull == null || _loginInputController.value.isEmpty) {
      loginOutputController.addError("Email is empty");
      return;
    }
    if (!_loginInputController.value.contains("@")) {
      loginOutputController.addError("Email is invalid");
      return;
    }
    loginOutputController.add("ok");
    if (_passInputController.valueOrNull == null || _passInputController.value.isEmpty) {
      passOutputController.addError("Password is empty");
      return;
    }
    passOutputController.add("ok");
    _login(_loginInputController.value, _passInputController.value);
  }

  _login(String email, String pass) async {
    isLoadingController.add(true);
    final result = await user.login(email, pass);
    result.when((success) {
      logInfo(success);
      local.setAccessToken(success.token ?? "");
      local.setRefreshToken(success.refreshToken ?? "");
      successController.add(success);
    }, (error) {
      logError(error);
      successController.addError(error);
    });
    isLoadingController.add(false);
  }

  void dispose() {
    _loginInputController.close();
    _passInputController.close();
    loginOutputController.close();
    passOutputController.close();
    successController.close();
  }
}
