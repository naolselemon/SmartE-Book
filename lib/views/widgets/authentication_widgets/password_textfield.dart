import 'package:flutter/material.dart';

class PasswordTextfield extends StatelessWidget {
  const PasswordTextfield({
    super.key,
    required this.controller,
    required this.hint,
  });

  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      decoration: InputDecoration(
        labelText: hint,
        hintText: hint,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontFamily: 'poppins',
          fontWeight: FontWeight.w500,
          color: Color.fromRGBO(236, 227, 255, 1),
        ),
      ),
    );
  }
}
