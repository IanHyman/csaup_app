import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'merkin/merkin_main.dart'; // ✅ Import MerkinMain
import 'ATR2025/atr2025_screen.dart'; // ✅ Import ATR2025Screen
import '../ProfileSettings.dart'; // ✅ Import ProfileSettings

class ChallengeSelectionScreen extends StatefulWidget {
  final bool isGuest;

  ChallengeSelectionScreen({required this.isGuest});

  @override
  _ChallengeSelectionScreenState createState() =>
      _ChallengeSelectionScreenState();
}

class _ChallengeSelectionScreenState extends State<ChallengeSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void selectChallenge(String challengeName) async {
    // ✅ If the user is a guest, bypass Firestore and navigate directly
    if (widget.isGuest) {
      navigateToChallenge(challengeName);
      return;
    }

    // ✅ For logged-in users, update Firestore and navigate
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'selectedChallenge': challengeName,
      });

      navigateToChallenge(challengeName);
    }
  }

  void navigateToChallenge(String challengeName) {
    if (challengeName == "Merkin Challenge") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MerkinMain(isGuest: widget.isGuest),
        ),
      );
    } else if (challengeName == "ATR 2025") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ATR2025Screen(isGuest: widget.isGuest),
        ),
      );
    }
  }

  void showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("About These Challenges"),
          content: Text(
              "These challenges are intended for F3 Naperville. If you'd like to request options for your region, please reach out to Ian at ian@hymanstech.com."),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a Challenge"),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: showInfoDialog, // ✅ Open info dialog
          ),
          if (!widget.isGuest) // ✅ Show settings only for logged-in users
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileSettings()),
                );
              },
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose Your Challenge:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => selectChallenge("Merkin Challenge"),
              child: Text("Merkin Challenge"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => selectChallenge("ATR 2025"),
              child: Text("ATR 2025"),
            ),
            SizedBox(height: 30),

            // ✅ New "Sign Up" button for guests
            if (widget.isGuest)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/'); // ✅ Go back to main screen (AuthWrapper)
                },
                child: Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
