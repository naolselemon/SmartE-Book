import 'package:flutter/material.dart';
import 'package:smart_ebook/presentation/screens/authentication_pages/app_bar.dart';
import 'package:smart_ebook/presentation/screens/authentication_pages/text_field.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

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
            const CustomTextField("Username"),
            const CustomTextField("Password"),
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
                  onPressed: () {},
                  child: const Text(
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: Image.asset(
                              'assets/images/facebook.png',
                              height: 40,
                              width: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: Image.asset(
                              'assets/images/apple.png',
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
