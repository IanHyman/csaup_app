import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/widgets/feed_message_tile.dart';
import '../../shared/widgets/message_input.dart';

class FeedScreen extends StatelessWidget {
  final String challengeId;
  final String userId;
  final String username;

  FeedScreen({required this.challengeId, required this.userId, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Challenge Feed")),
      body: Column(
        children: [
          Expanded(child: FeedMessages(challengeId: challengeId)), // ✅ Feed List
          
          // 🔹 Adjusted Message Input Field to be off the bottom slightly
          Padding(
            padding: EdgeInsets.only(bottom: 20), // Moves input field slightly up
            child: MessageInput(
              challengeId: challengeId,
              userId: userId,
              username: username,
            ),
          ),
        ],
      ),
    );
  }
}

class FeedMessages extends StatelessWidget {
  final String challengeId;

  FeedMessages({required this.challengeId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .collection('feed_posts')
          .orderBy('timestamp', descending: false) // 🔹 Normal order (newest at the bottom)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        var posts = snapshot.data!.docs;

        return ListView.builder(
          reverse: false, // 🔹 Show messages from top to bottom like Slack
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            return FeedMessageTile(
              username: post['username'],
              message: post['message'],
              postType: post['post_type'],
            );
          },
        );
      },
    );
  }
}
