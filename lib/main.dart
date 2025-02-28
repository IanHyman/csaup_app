import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/auth.dart'; // ✅ Corrected import path for auth.dart
import 'challenges/challenge_selection.dart';
import 'challenges/ATR2025/atr2025_screen.dart'; // ✅ Import ATR 2025 screen
import 'ProfileSettings.dart'; // ✅ Import ProfileSettings page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      routes: {
        '/settings': (context) => ProfileSettings(), // ✅ Named route for settings
        '/atr2025': (context) => ATR2025Screen(isGuest: false), // ✅ ATR 2025 screen route
        '/auth': (context) => AuthScreen(), // ✅ Added route for login/signup
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // ✅ Logged-in user goes to Challenge Selection Screen
          return ChallengeSelectionScreen(isGuest: false);
        } else {
          // ✅ Guest users can log in or create an account
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome to CSAUP Challenges!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // ✅ "Sign Up / Log In" button for guests
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AuthScreen()),
                      );
                    },
                    child: const Text("Sign Up / Log In"),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
