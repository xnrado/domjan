import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../globals.dart' as globals;

class Event {
  final String title;
  Color? color;
  Event(
      {required this.title, this.color = const Color.fromARGB(255, 245, 8, 8)});

  @override
  String toString() => title;
}

final kEvents = <DateTime, List<Event>>{}..addAll({
    DateTime.utc(2023, 7, 26): [
      Event(title: 'test1', color: Colors.amber),
    ],
  });

final _kEventSource = {
  for (var item in List.generate(50, (index) => index))
    DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
        item % 4 + 1,
        (index) => Event(
            title: 'Event $item | ${index + 1}',
            color: [Colors.amber, Colors.blue, Colors.red][Random()
                .nextInt([Colors.amber, Colors.blue, Colors.red].length)]))
}..addAll({
    kToday: [
      Event(title: 'Today\'s Event 1', color: Colors.red),
      Event(title: 'Today\'s Event 2'),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
