import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../challenge_selection.dart';
import 'leaderboard.dart';

class MerkinMain extends StatefulWidget {
  final bool isGuest;

  MerkinMain({required this.isGuest});

  @override
  _MerkinMainState createState() => _MerkinMainState();
}

class _MerkinMainState extends State<MerkinMain> {
  int totalMerkinsCompleted = 0;
  int merkinsForSelectedDay = 0;
  bool isCompleted = false;
  bool showCalendar = false;
  Map<String, bool> completedDays = {};
  DateTime selectedDay = DateTime.now();
  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    today = DateTime(today.year, today.month, today.day);
    selectedDay = today;

    if (!widget.isGuest) {
      loadCompletedDays();
    }
    updateMerkinCount(selectedDay);
  }

  void updateMerkinCount(DateTime date) {
    String dateKey = DateFormat("yyyy-MM-dd").format(date);
    int dayOfYear = int.parse(DateFormat("D").format(date));

    setState(() {
      merkinsForSelectedDay = dayOfYear;
      isCompleted = completedDays.containsKey(dateKey);
    });
  }

  Future<void> loadCompletedDays() async {
    if (widget.isGuest) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedDays')
          .get();

      Map<String, bool> completed = {};
      int total = 0;

      for (var doc in snapshot.docs) {
        try {
          String dateKey = doc.id;
          completed[dateKey] = true;
          total += (doc['merkins'] as int) ?? 0;
        } catch (e) {
          print("⚠️ Skipping invalid date format: ${doc.id}");
        }
      }

      setState(() {
        completedDays = completed;
        totalMerkinsCompleted = total;
        isCompleted = completedDays.containsKey(DateFormat("yyyy-MM-dd").format(selectedDay));
        showCalendar = true;
      });
    } catch (e) {
      print("❌ Error loading completed days: $e");
    }
  }

  Future<void> completeSelectedDay() async {
    if (widget.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Progress won't be saved for guest users.")),
      );
      setState(() {
        isCompleted = true;
        completedDays[DateFormat("yyyy-MM-dd").format(selectedDay)] = true;
        totalMerkinsCompleted += merkinsForSelectedDay;
      });
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || isCompleted) return;

    String selectedDateStr = DateFormat("yyyy-MM-dd").format(selectedDay);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedDays')
          .doc(selectedDateStr)
          .set({
        'date': selectedDateStr,
        'merkins': merkinsForSelectedDay,
        'completedAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'totalMerkins': FieldValue.increment(merkinsForSelectedDay),
      });

      setState(() {
        isCompleted = true;
        completedDays[selectedDateStr] = true;
        totalMerkinsCompleted += merkinsForSelectedDay;
      });
    } catch (e) {
      print("❌ Error completing selected day: $e");
    }
  }

  Future<void> removeCompletionForSelectedDay() async {
    if (widget.isGuest || !isCompleted) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String selectedDateStr = DateFormat("yyyy-MM-dd").format(selectedDay);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedDays')
          .doc(selectedDateStr)
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'totalMerkins': FieldValue.increment(-merkinsForSelectedDay),
      });

      setState(() {
        isCompleted = false;
        completedDays.remove(selectedDateStr);
        totalMerkinsCompleted -= merkinsForSelectedDay;
      });
    } catch (e) {
      print("❌ Error removing completion: $e");
    }
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
            Text(
              isCompleted ? "Total Merkins Completed" : "Today's Merkins",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              isCompleted
                  ? "$totalMerkinsCompleted Merkins"
                  : "$merkinsForSelectedDay Merkins",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 30),

            Center(
              child: Column(
                children: [
                  if (!isCompleted)
                    ElevatedButton(
                      onPressed: completeSelectedDay,
                      child: Text("Complete"),
                    ),
                  if (isCompleted)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Leaderboard(isGuest: widget.isGuest),
                          ),
                        );
                      },
                      child: Text("View Leaderboard"),
                    ),
                  if (isCompleted)
                    ElevatedButton(
                      onPressed: removeCompletionForSelectedDay,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Remove Completion"),
                    ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            if (showCalendar)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TableCalendar(
                  focusedDay: selectedDay,
                  firstDay: DateTime(DateTime.now().year, 1, 1),
                  lastDay: DateTime(DateTime.now().year, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  rowHeight: 50,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      this.selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                      updateMerkinCount(this.selectedDay);
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      String dateKey = DateFormat("yyyy-MM-dd").format(day);
                      bool isCompleted = completedDays.containsKey(dateKey);
                      return Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? Colors.green : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(
                                color: isCompleted ? Colors.white : Colors.black,
                                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
