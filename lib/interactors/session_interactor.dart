import 'package:elementary/elementary.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/common_strings.dart';

abstract class ISessionInteractor {
  StateNotifier<String> get role;

  void toggleRole([
    String? newRole,
  ]);

  void setAccessToken(String value);

  void setRefreshToken(String value);

  Future<bool> checkAccessTokenExpired();

  void logout();
}

@lazySingleton
class SessionInteractor extends ISessionInteractor {
  final SharedPreferences sharedPreferences;

  SessionInteractor(
    this.sharedPreferences,
  ) {
    checkAccessTokenExpired();
  }

  @override
  final StateNotifier<String> role = StateNotifier();

  @override
  void toggleRole([
    String? newRole,
  ]) {
    String prevRole = role.value ?? 'TENANT';
    role.accept(newRole ?? (prevRole == 'TENANT' ? "LANDLORD" : "TENANT"));
    if (role.value != 'GUEST') {
      sharedPreferences.setString(SELECTED_ROLE, role.value!);
    }
  }

  @override
  void logout() {
    sharedPreferences.remove(ACCESS_TOKEN);
    sharedPreferences.remove(REFRESH_TOKEN);
  }

  @override
  void setAccessToken(String value) {
    sharedPreferences.setString(ACCESS_TOKEN, value);
    toggleRole('TENANT');
  }

  @override
  void setRefreshToken(String value) {
    sharedPreferences.setString(REFRESH_TOKEN, value);
  }

  @override
  Future<bool> checkAccessTokenExpired() async {
    final String token = sharedPreferences.getString(ACCESS_TOKEN) ?? '';
    final String _refreshToken =
        sharedPreferences.getString(REFRESH_TOKEN) ?? "";
    if (token.isEmpty && _refreshToken.isEmpty) {
      return true;
    }
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      if (JwtDecoder.isExpired(token)) {
        // await refreshToken();
        return true;
      } else {
        setAccessToken(token);
        return false;
      }
    } on Exception catch (e) {
      // await refreshToken();
      return true;
    }
  }
}
