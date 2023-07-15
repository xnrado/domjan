import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import '../palette.dart';

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDrivers(),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        print(snapshot.data);
        return Scaffold(
          backgroundColor: Palette.backgroundColor,
          appBar: AppBar(
            iconTheme:
                const IconThemeData(size: 36, color: Palette.domjanColor),
            backgroundColor: Palette.appBarColor,
            actions: <Widget>[
              Row(
                children: [
                  Text(
                    "Kierowca J.",
                    style: TextStyle(color: Palette.domjanColor),
                  ),
                  Builder(
                    builder: (context) {
                      return IconButton(
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                        icon: Icon(
                          Icons.person,
                          color: Palette.domjanColor,
                        ),
                      );
                    },
                  )
                ],
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
                    print("Klikane");
                  },
                  child: ListTile(
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
          endDrawer: Drawer(
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
                    print("Klikane");
                  },
                  child: ListTile(
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
          body: Container(),
        );
      },
    );
  }
}

Future<Map> getDrivers() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('currentDriver', 'Wybierz Kierowcę');
  Map drivers = {};
  drivers['currentDriver'] = prefs.getString('currentDriver');
  return drivers;
}
