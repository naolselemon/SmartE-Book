import "package:riverpod_annotation/riverpod_annotation.dart";

import "../services/appwrite_services.dart";

@riverpod
class AuthViewModel {
  final AppwriteServices _authServices = AppwriteServices();

  Future<void> signUp(String name, String email, String password) async {
    try {
      await _authServices.signUp(name, email, password);
    } catch (e) {
      throw Exception("Failed to sign up: $e");
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authServices.signIn(email, password);
    } catch (e) {
      throw Exception("Failed to sign in: $e");
    }
  }

  //check if user is logged in
  Future<bool> isUserSignedIn() {
    return _authServices.isUserSignedIn();
  }
}
