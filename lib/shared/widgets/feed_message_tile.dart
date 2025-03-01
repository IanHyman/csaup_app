import 'package:flutter/material.dart';

class FeedMessageTile extends StatelessWidget {
  final String username;
  final String message;
  final String postType;

  FeedMessageTile({required this.username, required this.message, required this.postType});

  @override
  Widget build(BuildContext context) {
    bool isCompletion = postType == 'completion';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12), // 🔹 Spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 🔹 Align messages to the left
        children: [
          Text(
            username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blueAccent, // 🔹 Slack-style username color
            ),
          ),
          SizedBox(height: 2), // 🔹 Small space between name & message
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Divider(thickness: 0.5, color: Colors.grey[300]), // 🔹 Subtle divider
        ],
      ),
    );
  }
}
