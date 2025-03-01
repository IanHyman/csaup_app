import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'leaderboard.dart';
import 'merkin_feed.dart';

class MerkinButtons extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback onRemoveCompletion;
  final VoidCallback onViewLeaderboard;

  MerkinButtons({
    required this.isCompleted,
    required this.onComplete,
    required this.onViewLeaderboard,
    required this.onRemoveCompletion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isCompleted)
          ElevatedButton(
            onPressed: onComplete,
            child: Text("Complete"),
          ),
        if (isCompleted)
          ElevatedButton(
            onPressed: onViewLeaderboard,
            child: Text("View Leaderboard"),
          ),
          SizedBox(height: 10), // Add spacing between buttons
        if (isCompleted)
          ElevatedButton(
            onPressed: onRemoveCompletion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // 🔥 Red color for "Remove Completion"
            ),
            child: Text("Remove Completion"),
          ),
        SizedBox(height: 10),
        MerkinFeedButton(), // 🔥 Default Material styling
      ],
    );
  }
}

// 🔥 Updated "View Challenge Feed" Button (Now Uses Default Styling)
class MerkinFeedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MerkinFeed(
              challengeId: "merkin_challenge_id",
              userId: FirebaseAuth.instance.currentUser?.uid ?? "guest",
              username: "Fetching...",
            ),
          ),
        );
      },
      child: Text("Mumblechatter"),
    );
  }
}
