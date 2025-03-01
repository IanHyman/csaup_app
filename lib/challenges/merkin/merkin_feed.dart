import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MerkinFeed extends StatefulWidget {
  final String challengeId;
  final String userId;
  final String username;

  MerkinFeed({required this.challengeId, required this.userId, required this.username});

  @override
  _MerkinFeedState createState() => _MerkinFeedState();
}

class _MerkinFeedState extends State<MerkinFeed> {
  final TextEditingController _messageController = TextEditingController();
  String? username;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    setState(() {
      username = userDoc.exists ? userDoc['name'] ?? "Unknown User" : "Unknown User";
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('challenges')
        .doc(widget.challengeId)
        .collection('feed_posts')
        .add({
      'user_id': widget.userId,
      'username': username ?? widget.username,
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Challenge Feed")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('challenges')
                  .doc(widget.challengeId)
                  .collection('feed_posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var posts = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    return ListTile(
                      title: Text(post['username'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(post['message']),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
