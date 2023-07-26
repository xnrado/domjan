import 'package:domjan/views/event.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../palette.dart';

import '../../globals.dart' as globals;

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late ValueNotifier<List<Event>> _selectedEvents =
      ValueNotifier(_getEventsForDay(_focusedDay));
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    print('State Initialized');
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    print("123");
    return kEvents[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            TableCalendar(
              calendarBuilders: CalendarBuilders(
                singleMarkerBuilder: (context, day, event) {
                  Event e = event as Event;
                  Color? cor = e.color;
                  return Container(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: cor),
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
                  _selectedEvents.value = _getEventsForDay(selectedDay);
                }
              },
              eventLoader: _getEventsForDay,
              onPageChanged: (focusedDay) {
                focusedDay = focusedDay;
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
                titleTextStyle:
                    TextStyle(color: Palette.domjanColor, fontSize: 20),
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
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: value[index].color,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          onTap: () => print('${value[index]}'),
                          title: Text('${value[index]}'),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}
