import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ebook/view_models/auth_view_model.dart';
// import 'package:smart_ebook/views/providers/user_provider.dart';

import 'package:smart_ebook/views/screens/authentication_pages/app_bar.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/dashboard_page.dart';
import 'package:smart_ebook/views/widgets/authentication_widgets/password_textfield.dart';
import 'package:smart_ebook/views/widgets/authentication_widgets/text_field.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _isLoading = false;

  String? _errorMessage = "";

  bool _hasNavigated = false;

  final _authViewModel = AuthViewModel();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
  }

  void _validateAndSignIn() async {
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    // Input validation
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      //check if the user is already signed in
      if (await _authViewModel.isUserSignedIn()) {
        if (!mounted) {
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => const DashboardScreen()),
        );
        return;
      }

      // Sign in the user
      await _authViewModel.signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (!_hasNavigated) {
        _hasNavigated = true;

        if (!mounted) {
          return;
        }
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Center(child: Text('Sign-in successful!'))),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => const DashboardScreen()),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text(_errorMessage ?? "An error occured")),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(35, 8, 90, 1),
      appBar: const CustomAppBar(),
      body: Container(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Text(
                "Sign In",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            CustomTextField(hint: "Email", controller: _emailController),
            PasswordTextfield(
              hint: "Password",
              controller: _passwordController,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 25,
                bottom: 45,
                right: 16,
                left: 16,
              ),
              child: SizedBox(
                width: 328,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(157, 131, 210, 1),
                  ),
                  onPressed: _validateAndSignIn,
                  child:
                      _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'poppins',
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
