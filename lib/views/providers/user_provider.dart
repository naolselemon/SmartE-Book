import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ebook/models/user.dart';
import 'package:smart_ebook/controllers/user_services.dart';
import 'package:smart_ebook/views/providers/books_provider.dart';

// This provider is used to manage the state of the user in the app
// It provides methods to sign up, sign in, and sign out users
final userProvider = Provider<UserServices>((ref) => UserServices());

// profile state management data structure
// This class holds the state of the profile, including user data, loading state, and error messages
// It is used to manage the state of the profile page in the app
class ProfileState {
  final User? user;
  final bool isLoading;
  final String? error;

  ProfileState({this.user, this.isLoading = false, this.error});

  ProfileState copyWith({User? user, bool? isLoading, String? error}) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// This provider is used to manage the state of the profile
class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref ref;
  final UserServices _userServices;

  ProfileNotifier(this.ref, this._userServices) : super(ProfileState());

  // Fetch user data from the server
  Future<void> fetchUser() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _userServices.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Update user data on the server
  Future<void> updateUser({
    String? name,
    String? email,
    String? password,
    File? profileImage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _userServices.updateProfile(
        name: name,
        email: email,
        newPassword: password,
        profileImage: profileImage,
      );
      state = state.copyWith(user: user, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _userServices.signOut();
      ref.invalidate(booksWithRatingProvider);
      ref.invalidate(favoriteBooksWithRatingProvider);
      ref.invalidate(newBooksProvider);
      ref.invalidate(freeBooksProvider);
      state = state.copyWith(user: null, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> isUserSignedIn() async {
    return await _userServices.isUserSignedIn();
  }
}

// Making the provider available to the app
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  final userServices = ref.watch(userProvider);
  return ProfileNotifier(ref, userServices);
});
