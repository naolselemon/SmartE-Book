import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Fetch user data after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).fetchUser();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final localizations = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Image Source'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: const Text('Gallery'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: const Text('Camera'),
              ),
            ],
          ),
    );
    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _saveChanges(ProfileState profileState) async {
    final localizations = AppLocalizations.of(context)!;
    if (profileState.isLoading) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.nameCannotBeEmpty)),
      ); // 'Name cannot be empty'
      return;
    }
    if (email.isNotEmpty &&
        !RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.invalidEmail)));
      return;
    }
    if (password.isNotEmpty || confirmPassword.isNotEmpty) {
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.passwordsDoNotMatch)),
        ); // 'Passwords do not match'
        return;
      }
      if (password.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.passwordTooShort,
            ), // 'Password must be at least 8 characters'
          ),
        );
        return;
      }
    }

    // Update only changed fields
    await ref
        .read(profileProvider.notifier)
        .updateUser(
          name: name != profileState.user!.name ? name : null,
          email: email != profileState.user!.email ? email : null,
          profileImage: _selectedImage,
          password: password.isNotEmpty ? password : null,
        );

    final updatedState = ref.read(profileProvider);
    if (updatedState.error == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.profileUpdated)));
      setState(() {
        _selectedImage = null;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.errorPrefix + updatedState.error!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final localizations = AppLocalizations.of(context)!;

    // Update controllers with user data when available
    if (profileState.user != null) {
      _nameController.text = profileState.user!.name;
      _emailController.text = profileState.user!.email;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.profile,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            profileState.isLoading && profileState.user == null
                ? const Center(child: CircularProgressIndicator())
                : profileState.error != null
                ? Center(
                  child: Text(localizations.errorPrefix + profileState.error!),
                )
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.updateProfile,
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Profile Picture
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                      : profileState.user?.profileImageUrl !=
                                          null
                                      ? NetworkImage(
                                        profileState.user!.profileImageUrl!,
                                      )
                                      : const AssetImage(
                                        'assets/images/profile_picture.jpg',
                                      ),
                              backgroundColor: Colors.grey[200],
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.deepPurple,
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: localizations.name,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Email
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: localizations.email,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      // New Password
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: localizations.newPassword,
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: localizations.confirmPassword,
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              profileState.isLoading
                                  ? null
                                  : () => _saveChanges(profileState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child:
                              profileState.isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(localizations.saveChanges),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
