import "package:riverpod_annotation/riverpod_annotation.dart";

import "../controllers/user_services.dart";

@riverpod
class AuthViewModel {
  final UserServices _userServices = UserServices();

  Future<void> signUp(String name, String email, String password) async {
    try {
      await _userServices.signUp(name, email, password);
    } catch (e) {
      throw Exception("Failed to sign up: $e");
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _userServices.signIn(email, password);
    } catch (e) {
      throw Exception("Failed to sign in: $e");
    }
  }

  //check if user is logged in
  Future<bool> isUserSignedIn() {
    return _userServices.isUserSignedIn();
  }
}
