import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
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
