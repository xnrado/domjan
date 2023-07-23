import 'package:domjan/views/event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../palette.dart';

import '../../globals.dart' as globals;

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    DateTime _focusedDay = DateTime.now();
    DateTime? _selectedDay;

    return StatefulBuilder(
      builder: (context, setState) {
        return TableCalendar(
          calendarBuilders: CalendarBuilders(
            singleMarkerBuilder: (context, day, event) {
              Color cor = Colors.red;
              return Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: cor),
                width: 7.0,
                height: 7.0,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
              );
            },
          ),
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'pl_PL',
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2023, 12, 30),
          focusedDay: _focusedDay,
          eventLoader: (day) {
            return [];
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(
                () {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                },
              );
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          headerStyle: const HeaderStyle(
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
            titleCentered: true,
            titleTextStyle: TextStyle(color: Palette.domjanColor, fontSize: 20),
            formatButtonVisible: false,
          ),
          calendarStyle: const CalendarStyle(
            outsideTextStyle: TextStyle(color: Palette.inactiveTextColor),
            weekendTextStyle: TextStyle(color: Palette.activeTextColor),
            todayTextStyle: TextStyle(color: Palette.domjanColor),
            selectedTextStyle: TextStyle(color: Palette.activeTextColor),
            defaultTextStyle: TextStyle(color: Palette.activeTextColor),
            todayDecoration: BoxDecoration(
                color: Palette.appBarColor, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(
                color: Palette.selectColor, shape: BoxShape.circle),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Palette.textSelection),
              weekendStyle: TextStyle(color: Palette.textSelection)),
        );
      },
    );
  }
}
