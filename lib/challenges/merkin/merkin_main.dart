import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../challenge_selection.dart';
import 'leaderboard.dart';
import 'merkin_firestore.dart';
import 'merkin_calendar.dart';
import 'merkin_buttons.dart';

class MerkinMain extends StatefulWidget {
  final bool isGuest;
  MerkinMain({required this.isGuest});

  @override
  _MerkinMainState createState() => _MerkinMainState();
}

class _MerkinMainState extends State<MerkinMain> {
  DateTime selectedDay = DateTime.now();
  bool isCompleted = false;
  int totalMerkinsCompleted = 0;
  int merkinsForSelectedDay = 0;
  Map<String, bool> completedDays = {};

  @override
  void initState() {
    super.initState();
    loadMerkinData();
  }

  Future<void> loadMerkinData() async {
    final completedData = await MerkinFirestore.loadCompletedDays();
    final totalMerkins = await MerkinFirestore.getTotalMerkins();
    final merkinsToday = MerkinFirestore.getMerkinsForDay(selectedDay);

    if (!mounted) return;

    setState(() {
      completedDays = completedData;
      totalMerkinsCompleted = totalMerkins;
      merkinsForSelectedDay = merkinsToday;
      isCompleted = completedDays.containsKey(MerkinFirestore.formatDate(selectedDay));
    });
  }

  void handleDaySelected(DateTime newDay) {
    setState(() {
      selectedDay = newDay;
      merkinsForSelectedDay = MerkinFirestore.getMerkinsForDay(newDay);
      isCompleted = completedDays.containsKey(MerkinFirestore.formatDate(newDay));
    });
  }

  void handleComplete() async {
    await MerkinFirestore.completeSelectedDay(selectedDay);
    if (!mounted) return;
    setState(() {
      isCompleted = true;
      totalMerkinsCompleted += merkinsForSelectedDay;
      completedDays[MerkinFirestore.formatDate(selectedDay)] = true;
    });
  }

  void handleRemoveCompletion() async {
    await MerkinFirestore.removeCompletionForSelectedDay(selectedDay);
    if (!mounted) return;
    setState(() {
      isCompleted = false;
      totalMerkinsCompleted -= merkinsForSelectedDay;
      completedDays.remove(MerkinFirestore.formatDate(selectedDay));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merkin Challenge'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChallengeSelectionScreen(isGuest: widget.isGuest),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              isCompleted ? "Total Merkins Completed" : "Today's Merkins",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              isCompleted
                  ? "$totalMerkinsCompleted Merkins"
                  : "$merkinsForSelectedDay Merkins",
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 20),

            // 🗓 Calendar Section
            MerkinCalendar(
              selectedDay: selectedDay,
              onDaySelected: handleDaySelected,
              completedDays: completedDays,
            ),

            SizedBox(height: 20),

            // ✅ Action Buttons Section (Including Feed Button)
            MerkinButtons(
              isCompleted: isCompleted,
              onComplete: handleComplete,
              onViewLeaderboard: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Leaderboard(isGuest: widget.isGuest),
                  ),
                );
              },
              onRemoveCompletion: handleRemoveCompletion,
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
