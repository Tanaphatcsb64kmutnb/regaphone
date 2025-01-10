import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:regaproject/Home/Home.dart'; // Import HomePage
import 'package:regaproject/Sign-In/SignIn.dart'; // Import SignInPage

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if user is logged in or not
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const HomePage(); // Navigate to HomePage if logged in
        } else {
          return const SignInPage(); // Navigate to SignInPage if not logged in
        }
      },
    );
  }
}
