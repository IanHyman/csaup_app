import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Leaderboard extends StatefulWidget {
  final bool isGuest;

  const Leaderboard({required this.isGuest, Key? key}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  bool showLeaderboard = false;
  List<DocumentSnapshot> lastKnownUsers = []; // ✅ Stores last known leaderboard data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ATR 2025 Leaderboard"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.isGuest && !showLeaderboard
          ? _buildGuestMessage()
          : _buildLeaderboard(),
    );
  }

  // ✅ Guest message with "OK" button
  Widget _buildGuestMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "As a guest, you can view the leaderboard but your progress will not be tracked.\n\nLog in to participate and track your progress!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showLeaderboard = true; // ✅ Switch to leaderboard view
                });
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Persist leaderboard data even when Firestore updates momentarily return empty
  Widget _buildLeaderboard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('totalMerkins', descending: true) // ✅ Sorts by most merkins
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // ✅ Show loading indicator
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          lastKnownUsers = snapshot.data!.docs; // ✅ Update the last known good leaderboard data
        }

        if (lastKnownUsers.isEmpty) {
          return const Center(child: Text("No participants yet!")); // ✅ Show only if no data ever existed
        }

        return ListView.builder(
          itemCount: lastKnownUsers.length,
          itemBuilder: (context, index) {
            final user = lastKnownUsers[index];
            final name = user['name'] ?? 'Unknown User';
            final totalMerkins = user['totalMerkins'] ?? 0;

            return ListTile(
              leading: CircleAvatar(
                child: Text((index + 1).toString()), // ✅ Shows rank
              ),
              title: Text(name),
              subtitle: Text("Total Merkins: $totalMerkins"),
            );
          },
        );
      },
    );
  }
}
