import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MerkinFirestore {
  static String formatDate(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  static int getMerkinsForDay(DateTime date) {
    return int.parse(DateFormat("D").format(date));
  }

  static Future<Map<String, bool>> loadCompletedDays() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedDays')
          .get();

      Map<String, bool> completed = {};
      for (var doc in snapshot.docs) {
        completed[doc.id] = true;
      }

      return completed;
    } catch (e) {
      print("❌ Error loading completed days: $e");
      return {};
    }
  }

  static Future<int> getTotalMerkins() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return snapshot.exists && snapshot.data() != null
          ? (snapshot['totalMerkins'] ?? 0) as int
          : 0;
    } catch (e) {
      print("❌ Error getting total Merkins: $e");
      return 0;
    }
  }

static Future<void> completeSelectedDay(DateTime date) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  String dateStr = formatDate(date);
  int merkins = getMerkinsForDay(date);

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('completedDays')
        .doc(dateStr)
        .set({
      'date': dateStr,
      'merkins': merkins,
      'completedAt': Timestamp.now(),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'totalMerkins': FieldValue.increment(merkins),
    });

    // 🔥 Auto-post completion to the feed
    await FirebaseFirestore.instance
        .collection('challenges')
        .doc("merkin_challenge_id") // Replace with actual challenge ID
        .collection('feed_posts')
        .add({
      'user_id': user.uid,
      'username': user.displayName ?? "Unknown User",
      'timestamp': FieldValue.serverTimestamp(),
      'message': "${user.displayName ?? "Unknown User"} completed $merkins Merkins!",
      'post_type': 'completion',
    });

  } catch (e) {
    print("❌ Error completing day: $e");
  }
}


  static Future<void> removeCompletionForSelectedDay(DateTime date) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String dateStr = formatDate(date);
    int merkins = getMerkinsForDay(date);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedDays')
          .doc(dateStr)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'totalMerkins': FieldValue.increment(-merkins),
      });

    } catch (e) {
      print("❌ Error removing completion: $e");
    }
  }
}
