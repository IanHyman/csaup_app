import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class MerkinCalendar extends StatelessWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final Map<String, bool> completedDays;

  MerkinCalendar({
    required this.selectedDay,
    required this.onDaySelected,
    required this.completedDays,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          onDaySelected(DateTime(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day,
          ));
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
                  color: isCompleted ? Colors.green : Colors.transparent, // ✅ Green circle for completed days
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
    );
  }
}
