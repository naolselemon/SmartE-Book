import 'package:flutter/material.dart';

import 'package:smart_ebook/view_models/auth_view_model.dart';
import 'package:smart_ebook/views/screens/authentication_pages/app_bar.dart';
import 'package:smart_ebook/views/screens/authentication_pages/signin.dart';
import 'package:smart_ebook/views/widgets/authentication_widgets/password_textfield.dart';
import 'package:smart_ebook/views/widgets/authentication_widgets/text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _viewModel = AuthViewModel();

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasNavigated = false;

  Future<void> _validateAndSignUp() async {
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    // Input validation
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }
    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    if (_confirmPasswordController.text != _passwordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _viewModel.signUp(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );

      if (!mounted) {
        return;
      }

      if (!_hasNavigated) {
        _hasNavigated = true;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign-up successful!')));

        _clearForm();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      print("Error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
    }
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _confirmPasswordController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                "Create New Account",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            CustomTextField(hint: "Full Name", controller: _nameController),
            CustomTextField(hint: "Email", controller: _emailController),
            PasswordTextfield(
              controller: _passwordController,
              hint: "Password",
            ),
            PasswordTextfield(
              controller: _confirmPasswordController,
              hint: "Confirm Password",
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
                  onPressed: _validateAndSignUp,
                  child:
                      _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                            "Sign Up",
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
            Padding(
              padding: const EdgeInsets.only(right: 108, left: 108),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.,
                children: [
                  const Text(
                    "or Sign up with",
                    style: TextStyle(
                      letterSpacing: 0.15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'poppins',
                      color: Color.fromRGBO(236, 227, 255, 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: Image.asset(
                              'assets/images/google.png',
                              height: 40,
                              width: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
