import "package:riverpod_annotation/riverpod_annotation.dart";

import "../services/auth_services.dart";

@riverpod
class AuthViewModel {
  final AuthServices _authServices = AuthServices();

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
}
