import "package:appwrite/appwrite.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "../models/user.dart";

class AuthServices {
  final Client _client;
  late final Account _account;
  late final Databases _databases;

  AuthServices()
    : _client = Client()
          .setEndpoint(dotenv.env["API_ENDPOINT"]!)
          .setProject(dotenv.env["PROJECT_ID"])
          .setSelfSigned(status: true) {
    _account = Account(_client);
    _databases = Databases(_client);
  }

  Future<User> signUp(String name, String email, String password) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        name: name,
        email: email,
        password: password,
      );

      await _databases.createDocument(
        databaseId: dotenv.env["DATABASE_ID"]!,
        collectionId: dotenv.env["USER_COLLECTION_ID"]!,
        documentId: user.$id,
        data: {name: name, email: email, password: password},
      );

      return User(id: user.$id, name: name, email: email, password: password);
    } catch (e) {
      throw Exception("Failed to sign up: $e");
    }
  }
}
