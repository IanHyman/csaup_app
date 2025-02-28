import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../challenge_selection.dart';
import 'atr2025_leaderboard.dart';

class ATR2025Screen extends StatefulWidget {
  final bool isGuest;

  ATR2025Screen({required this.isGuest, Key? key}) : super(key: key);

  @override
  _ATR2025ScreenState createState() => _ATR2025ScreenState();
}

class _ATR2025ScreenState extends State<ATR2025Screen> {
  final Map<String, bool> locations = {
    "Citadel": false,
    "The Complex": false,
    "Dark Tower": false,
    "The Globe": false,
    "The Ice House": false,
    "Iron Lion": false,
    "Launchpad": false,
    "The Levee": false,
    "Noonan’s Ridge": false,
    "The Outpost": false,
    "Two Wolves": false,
    "Black Diamond (required!)": false,
  };

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      _loadSavedProgress();
    }
  }

  Future<void> _loadSavedProgress() async {
    if (widget.isGuest) return; // Skip loading progress for guests

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot progressDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('completedATR')
            .doc('progress')
            .get();

        if (progressDoc.exists) {
          Map<String, dynamic>? progressData =
              progressDoc.data() as Map<String, dynamic>?;
          if (progressData != null) {
            setState(() {
              for (var location in locations.keys) {
                locations[location] = progressData[location] ?? false;
              }
            });
          }
        }
      } catch (e) {
        print("Error loading progress: $e");
      }
    }
  }

  Future<void> _saveProgress() async {
    if (widget.isGuest) {
      // Guests cannot save progress
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Progress won't be saved for guest users.")),
      );
      return;
    }

    User? user = _auth.currentUser;
    if (user != null) {
      int completed = locations.values.where((value) => value).length;

      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('completedATR')
            .doc('progress')
            .set({
          ...locations,
          'completed': completed,
        });
        print("Progress saved successfully.");
      } catch (e) {
        print("Error saving progress: $e");
      }
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ATR 2025 Challenge Info"),
          content: const Text(
              "The ATR 2025 Challenge requires you to visit and complete workouts at 12 unique locations:\n\n"
              "1. Citadel\n"
              "2. The Complex\n"
              "3. Dark Tower\n"
              "4. The Globe\n"
              "5. The Ice House\n"
              "6. Iron Lion\n"
              "7. Launchpad\n"
              "8. The Levee\n"
              "9. Noonan’s Ridge\n"
              "10. The Outpost\n"
              "11. Two Wolves\n"
              "12. Black Diamond (required!)\n\n"
              "Check off each location as you complete it to track your progress and climb the leaderboard!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
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
        title: const Text("ATR 2025 Challenge"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChallengeSelectionScreen(isGuest: widget.isGuest),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Check off each location as you complete it!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ATR2025LeaderboardScreen(isGuest: widget.isGuest),
                ),
              );
            },
            child: const Text("View Leaderboard"),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: locations.keys.length,
              itemBuilder: (context, index) {
                String location = locations.keys.elementAt(index);
                return CheckboxListTile(
                  title: Text(location),
                  value: locations[location],
                  onChanged: widget.isGuest
                      ? (value) {
                          // Guests can toggle, but progress won't be saved
                          setState(() {
                            locations[location] = value!;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Progress won't be saved for guest users.")),
                          );
                        }
                      : (value) {
                          setState(() {
                            locations[location] = value!;
                          });
                          _saveProgress();
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
