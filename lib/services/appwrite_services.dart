import "dart:io";

import "package:appwrite/appwrite.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "../models/user.dart";

class AppwriteServices {
  final Client _client;
  late final Account _account;
  late final Databases _databases;
  late final Storage _storage;

  AppwriteServices()
    : _client = Client()
          .setEndpoint(dotenv.env["API_ENDPOINT"]!)
          .setProject(dotenv.env["PROJECT_ID"])
          .setSelfSigned(status: true) {
    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
  }

  Future<User> signUp(String name, String email, String password) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        name: name,
        email: email,
        password: password,
      );
      final documentData = {'userId': user.$id, 'name': name, 'email': email};

      print('Creating document with data: $documentData');

      await _databases.createDocument(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['USER_COLLECTION_ID']!,
        documentId: user.$id,
        data: documentData,
      );

      return User(
        id: user.$id,
        name: user.name,
        email: user.email,
        password: password,
        profileImageUrl: null,
      );
    } catch (e) {
      throw Exception("Failed to sign up: $e");
    }
  }

  Future<User> signIn(String email, String password) async {
    try {
      // Only delete current session to avoid clearing other devices
      await _account.deleteSession(sessionId: 'current').catchError((e) {
        print('No current session to delete: $e');
      });

      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      final user = await _account.get();

      final userDocument = await _databases.getDocument(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['USER_COLLECTION_ID']!,
        documentId: user.$id,
      );
      return User(
        id: user.$id,
        name: user.name,
        email: user.email,
        password: password,
        profileImageUrl: userDocument.data['profileImageUrl'] as String?,
      );
    } catch (e) {
      throw Exception("Failed to sign in: $e");
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final user = await _account.get();
      final document = await _databases.getDocument(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['USER_COLLECTION_ID']!,
        documentId: user.$id,
      );

      return User(
        id: user.$id,
        name: user.name,
        email: user.email,
        profileImageUrl: document.data['profileImageUrl'] as String?,
      );
    } catch (e) {
      print("Failed to get current user: $e");
      return null;
    }
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? newPassword,
    File? profileImage,
  }) async {
    try {
      // Get the current user
      final user = await _account.get();

      // Update user profile
      String? profileImageUrl;
      dynamic file;

      // Check if a new profile image is provided
      if (profileImage != null) {
        final currentDocument = await _databases.getDocument(
          databaseId: dotenv.env["DATABASE_ID"]!,
          collectionId: dotenv.env["USER_COLLECTION_ID"]!,
          documentId: user.$id,
        );

        // get the existing image ID
        final existingImageId =
            currentDocument.data['profileImageId'] as String?;

        // if there is an existing image, delete it
        if (existingImageId != null) {
          await _storage.deleteFile(
            bucketId: dotenv.env["BUCKET_ID"]!,
            fileId: existingImageId,
          );
        }

        // Upload the new image
        file = await _storage.createFile(
          bucketId: dotenv.env["BUCKET_ID"]!,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: profileImage.path),
        );

        // Get the file URL
        profileImageUrl =
            '${dotenv.env["API_ENDPOINT"]}/storage/buckets/${dotenv.env["BUCKET_ID"]}/files/${file.$id}/view?project=${dotenv.env["PROJECT_ID"]}';
      }

      // Create a new document data map
      final documentData = <String, dynamic>{};

      // Add the user ID to the document data
      if (name != null && name.isNotEmpty) {
        documentData['name'] = name;
      }

      // Add the email to the document data
      if (email != null && email.isNotEmpty) {
        documentData['email'] = email;
      }

      // Add the profile image URL to the document data
      if (profileImageUrl != null) {
        documentData['profileImageUrl'] = profileImageUrl;
        documentData['profileImageId'] = file.$id;
      }

      // Update the document in the database
      await _databases.updateDocument(
        databaseId: dotenv.env["DATABASE_ID"]!,
        collectionId: dotenv.env["USER_COLLECTION_ID"]!,
        documentId: user.$id,
        data: documentData,
      );

      // update password if provided
      if (newPassword != null && newPassword.isNotEmpty) {
        await _account.updatePassword(password: newPassword);
      }

      // update email if provided
      if (email != null && email.isNotEmpty) {
        await _account.updateEmail(email: email, password: user.password!);
      }

      // update name if provided
      if (name != null && name.isNotEmpty) {
        await _account.updateName(name: name);
      }

      return User(
        id: user.$id,
        name: name ?? user.name,
        email: email ?? user.email,

        profileImageUrl: profileImageUrl,
      );
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  //check if user is logged in
  Future<bool> isUserSignedIn() async {
    try {
      await _account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  //sign out
  Future<void> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      print("Error signing out: $e");
      throw Exception("Failed to sign out: $e");
    }
  }
}
