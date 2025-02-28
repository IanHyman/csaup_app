import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../challenges/challenge_selection.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false; // ✅ Added to show loading indicator

  Future<void> authenticate() async {
    setState(() => isLoading = true); // ✅ Show loading when authenticating
    try {
      if (isLogin) {
        // ✅ Attempt login
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        // ✅ Register user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // ✅ Store user data in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'selectedChallenge': "None", // Default challenge selection
        });
      }

      // ✅ Navigate to Challenge Selection after successful login/signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChallengeSelectionScreen(isGuest: false),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred. Please try again.";
      if (e.code == 'user-not-found') {
        message = "No account found for this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed. Please try again.")),
      );
    } finally {
      setState(() => isLoading = false); // ✅ Hide loading after authentication
    }
  }

  void continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeSelectionScreen(isGuest: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!isLogin)
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Profile Name'),
              ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),

            isLoading
                ? CircularProgressIndicator() // ✅ Show loading while processing login/signup
                : ElevatedButton(
                    onPressed: authenticate,
                    child: Text(isLogin ? 'Login' : 'Sign Up'),
                  ),

            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(
                isLogin ? 'Create an account' : 'Already have an account? Login',
              ),
            ),
            SizedBox(height: 20),

            const Text("OR"),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: continueAsGuest,
              child: const Text("Continue as Guest"),
            ),
          ],
        ),
      ),
    );
  }
}
