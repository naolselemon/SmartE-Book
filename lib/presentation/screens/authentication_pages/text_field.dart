import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(this.hint, {super.key});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          labelText: hint,
          hintText: hint,
          labelStyle: const TextStyle(
              fontSize: 13,
              fontFamily: 'poppins',
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(236, 227, 255, 1))),
    );
  }
}
