import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../firebase_options.dart';
import '../palette.dart';

import '../globals.dart' as globals;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(
      () {
        _selectedIndex = index;
      },
    );
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Scaffold(
          backgroundColor: Palette.backgroundColor,
          appBar: AppBar(
            iconTheme:
                const IconThemeData(size: 36, color: Palette.domjanColor),
            backgroundColor: Palette.appBarColor,
            actions: <Widget>[
              Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: Row(
                      children: [
                        Text(
                          globals.prefs.getString('currentDriver') ??
                              "Wybierz Kierowcę",
                          style: const TextStyle(color: Palette.domjanColor),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.person,
                            color: Palette.domjanColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
          drawer: Drawer(
            backgroundColor: Palette.backgroundColor,
            child: ListView(
              children: [
                SizedBox(
                  height: 96,
                  child: DrawerHeader(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Twoje konto DOM-JAN',
                            style: TextStyle(
                                color: Palette.activeTextColor, fontSize: 24),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            FirebaseAuth.instance.currentUser?.email ??
                                'dummy@',
                            style: const TextStyle(
                                color: Palette.linkColor, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.setBool('remember', false);
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login/',
                      (route) => false,
                    );
                  },
                  child: const ListTile(
                    leading: Icon(
                      Icons.exit_to_app,
                      size: 22,
                      color: Palette.activeTextColor,
                    ),
                    title: Text(
                      'Wyloguj się',
                      style: TextStyle(color: Palette.activeTextColor),
                    ),
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Palette.appBarColor,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled),
                  label: 'Harmonogram',
                  backgroundColor: Palette.appBarColor),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month), label: 'Kalendarz')
            ],
            selectedItemColor: Palette.domjanColor,
            unselectedItemColor: Palette.focusColor,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          body: _selectedIndex == 0 ? timeline() : calendar(),
          endDrawer: Drawer(
            backgroundColor: Palette.backgroundColor,
            child: FutureBuilder(
              future: getDriverFields(),
              builder: (context, snapshot) {
                return ListView(
                  children: snapshot.data ??
                      [
                        const Text(
                          "Coś poszło nie tak, \nnie udało się pokazać kierowców.",
                          style: TextStyle(color: Palette.errorColor),
                          textAlign: TextAlign.center,
                        )
                      ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  FutureBuilder<List<Widget>> timeline() {
    return FutureBuilder(
      future: getAssignmentFields(),
      builder: (context, snapshot) {
        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(
            color: Palette.activeTextColor,
            height: 5,
            thickness: 0.5,
          ),
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: snapshot.data?[index]);
          },
        );
      },
    );
  }

  Widget calendar() {
    return FutureBuilder(
      future: getAssignmentFields(),
      builder: (context, snapshot) {
        return TableCalendar(
          headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(color: Palette.domjanColor),
              formatButtonVisible: false),
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
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: const CalendarStyle(
            outsideTextStyle: TextStyle(color: Palette.inactiveTextColor),
            weekendTextStyle: TextStyle(color: Palette.activeTextColor),
            todayTextStyle: TextStyle(color: Palette.domjanColor),
            defaultTextStyle: TextStyle(color: Palette.activeTextColor),
          ),
        );
      },
    );
  }

  Future<List<Widget>> getDriverFields() async {
    List<Widget> driverFields = [];
    var drivers = await getDrivers();

    for (var driver in drivers) {
      driverFields.add(
        GestureDetector(
          onTap: () {
            setState(
              () {
                globals.prefs.setString(
                    'currentDriver', '${driver[1]} ${'${driver[2]}'[0]}.');
              },
            );
          },
          child: ListTile(
            leading: Icon(
              globals.prefs.getString('currentDriver') ==
                      '${driver[1]} ${'${driver[2]}'[0]}.'
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              size: 22,
              color: Palette.activeTextColor,
            ),
            title: Text(
              '${driver[1]} ${'${driver[2]}'[0]}.',
              style: const TextStyle(color: Palette.activeTextColor),
            ),
          ),
        ),
      );
    }

    return driverFields;
  }

  Future getDrivers() async {
    var drivers = await globals.conn.query('select * from drivers');
    return drivers;
  }

  Future<List<Widget>> getAssignmentFields() async {
    List<Widget> assignmentFields = [];
    var assignments = await getAssignments();

    for (var assignment in assignments) {
      assignmentFields.add(
        GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.blue,
            height: 112,
            width: 384,
            child: Stack(
              children: [
                Text(
                  'Test',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 88,
                    width: 384,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return assignmentFields;
  }

  Future getAssignments() async {
    var assignments = await globals.conn.query('select * from drivers');
    return assignments;
  }
}
