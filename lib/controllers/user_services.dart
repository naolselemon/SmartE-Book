import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';

class UserServices {
  final Client _client;
  late final Account _account;
  late final Databases _databases;
  late final Storage _storage;

  UserServices()
    : _client =
          Client()
            ..setEndpoint(dotenv.env['API_ENDPOINT']!)
            ..setProject(dotenv.env['PROJECT_ID']!)
            ..setSelfSigned(status: true) {
    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
  }

  Client get client => _client;

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
        collectionId: dotenv.env['USERS_COLLECTION_ID']!,
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
      print('Sign-up error: $e');
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<User> signIn(String email, String password) async {
    try {
      // Create new session
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      print('Created session: ${session.$id}');

      // Verify session by fetching user
      final user = await _account.get();
      print('Signed in user: ${user.$id}');

      // Fetch user document
      final userDocument = await _databases.getDocument(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['USERS_COLLECTION_ID']!,
        documentId: user.$id,
      );
      return User(
        id: user.$id,
        name: userDocument.data['name'] as String? ?? user.name,
        email: user.email,
        password: password,
        profileImageUrl: userDocument.data['profileImageUrl'] as String?,
      );
    } catch (e) {
      print('Sign-in error: $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final user = await _account.get();
      print('Fetched current user: ${user.$id}');
      final document = await _databases.getDocument(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['USERS_COLLECTION_ID']!,
        documentId: user.$id,
      );

      return User(
        id: user.$id,
        name: document.data['name'] as String? ?? user.name,
        email: user.email,
        profileImageUrl: document.data['profileImageUrl'] as String?,
      );
    } catch (e) {
      print('Failed to get current user: $e');
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
      final user = await _account.get();

      String? profileImageUrl;
      String? profileImageId;

      if (profileImage != null) {
        final currentDocument = await _databases.getDocument(
          databaseId: dotenv.env['DATABASE_ID']!,
          collectionId: dotenv.env['USERS_COLLECTION_ID']!,
          documentId: user.$id,
        );

        final existingImageId =
            currentDocument.data['profileImageId'] as String?;

        if (existingImageId != null) {
          await _storage.deleteFile(
            bucketId: dotenv.env['BUCKET_ID']!,
            fileId: existingImageId,
          );
        }

        final file = await _storage.createFile(
          bucketId: dotenv.env['BUCKET_ID']!,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: profileImage.path),
        );

        profileImageUrl =
            '${dotenv.env['API_ENDPOINT']}/storage/buckets/${dotenv.env['BUCKET_ID']}/files/${file.$id}/view?project=${dotenv.env['PROJECT_ID']}';
        profileImageId = file.$id;
      }

      final documentData = <String, dynamic>{};
      if (name != null && name.isNotEmpty) {
        documentData['name'] = name;
      }
      if (email != null && email.isNotEmpty) {
        documentData['email'] = email;
      }
      if (profileImageUrl != null) {
        documentData['profileImageUrl'] = profileImageUrl;
        documentData['profileImageId'] = profileImageId;
      }

      await _databases.updateDocument(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['USERS_COLLECTION_ID']!,
        documentId: user.$id,
        data: documentData,
      );

      if (newPassword != null && newPassword.isNotEmpty) {
        await _account.updatePassword(password: newPassword);
      }
      if (email != null && email.isNotEmpty) {
        await _account.updateEmail(email: email, password: user.password!);
      }
      if (name != null && name.isNotEmpty) {
        await _account.updateName(name: name);
      }

      return User(
        id: user.$id,
        name: name ?? user.name,
        email: email ?? user.email,
        profileImageUrl:
            profileImageUrl ?? documentData['profileImageUrl'] as String?,
      );
    } catch (e) {
      print('Update profile error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<bool> isUserSignedIn() async {
    try {
      await _account.get();
      return true;
    } catch (e) {
      print('isUserSignedIn error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      print('Signed out successfully');
    } catch (e) {
      print('Sign-out error: $e');
      throw Exception('Failed to sign out: $e');
    }
  }
}
