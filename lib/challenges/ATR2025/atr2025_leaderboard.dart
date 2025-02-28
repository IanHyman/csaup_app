import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ATR2025LeaderboardScreen extends StatefulWidget {
  final bool isGuest;

  const ATR2025LeaderboardScreen({required this.isGuest, Key? key}) : super(key: key);

  @override
  _ATR2025LeaderboardScreenState createState() => _ATR2025LeaderboardScreenState();
}

class _ATR2025LeaderboardScreenState extends State<ATR2025LeaderboardScreen> {
  bool showLeaderboard = false;
  List<Map<String, dynamic>> lastKnownLeaderboard = [];
  bool _isMounted = false; // ✅ Track if widget is mounted

  @override
  void initState() {
    super.initState();
    _isMounted = true; // ✅ Mark as mounted when initialized
    if (!widget.isGuest) {
      _fetchLeaderboardData(); // ✅ Load data only if the user is logged in
    }
  }

  @override
  void dispose() {
    _isMounted = false; // ✅ Mark as unmounted when disposed
    super.dispose();
  }

  Future<void> _fetchLeaderboardData() async {
    try {
      QuerySnapshot userDocs = await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>> leaderboard = await _getLeaderboardData(userDocs.docs);

      if (_isMounted) {
        setState(() {
          lastKnownLeaderboard = leaderboard; // ✅ Update state only if mounted
        });
      }
    } catch (e) {
      print("Error fetching leaderboard data: $e");
    }
  }

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
              "As a guest, you can view the leaderboard but your progress will not be saved. Log in to participate and see your progress on the leaderboard!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showLeaderboard = true; // ✅ Switch to leaderboard view
                  _fetchLeaderboardData(); // ✅ Load leaderboard when OK is clicked
                });
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Persist leaderboard data even when Firestore updates return empty momentarily
  Widget _buildLeaderboard() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('users').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && lastKnownLeaderboard.isEmpty) {
          return const Center(child: CircularProgressIndicator()); // ✅ Show loading indicator
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          _getLeaderboardData(snapshot.data!.docs).then((leaderboard) {
            if (_isMounted) {
              setState(() {
                lastKnownLeaderboard = leaderboard; // ✅ Store last known leaderboard
              });
            }
          });
        }

        if (lastKnownLeaderboard.isEmpty) {
          return const Center(
            child: Text(
              "No entries yet. Be the first to complete a location!",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          itemCount: lastKnownLeaderboard.length,
          itemBuilder: (context, index) {
            var user = lastKnownLeaderboard[index];
            String name = user['name'] ?? 'Anonymous';
            int completed = user['completed'] ?? 0;

            return ListTile(
              leading: Text(
                "${index + 1}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$completed/12",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getLeaderboardData(
      List<QueryDocumentSnapshot> userDocs) async {
    List<Map<String, dynamic>> leaderboard = [];

    for (var userDoc in userDocs) {
      String userId = userDoc.id;
      String userName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Anonymous';

      try {
        DocumentSnapshot progressDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('completedATR')
            .doc('progress')
            .get();

        if (progressDoc.exists) {
          Map<String, dynamic> progressData = progressDoc.data() as Map<String, dynamic>;
          int completed = progressData['completed'] ?? 0;

          leaderboard.add({
            'name': userName,
            'completed': completed,
          });
        }
      } catch (e) {
        print("Error fetching progress for user $userId: $e");
      }
    }

    leaderboard.sort((a, b) => b['completed'].compareTo(a['completed']));
    return leaderboard;
  }
}
