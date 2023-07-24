import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../palette.dart';

import '../../globals.dart' as globals;

import './calendar.dart';

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
                          globals.prefs?.getString('currentDriver') ??
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
                  onTap: () {
                    globals.prefs?.setBool('remember', false);
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
                backgroundColor: Palette.appBarColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Kalendarz',
              ),
            ],
            selectedItemColor: Palette.domjanColor,
            unselectedItemColor: Palette.focusColor,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          body: _selectedIndex == 0 ? timeline() : Calendar(),
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
                          style: TextStyle(color: Palette.activeTextColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget timeline() {
    return FutureBuilder(
      future: getAssignmentFields(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Nie udało się załadować informacji.',
          );
        } else if (snapshot.hasData) {
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
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<List<Widget>> getDriverFields() async {
    List<Widget> driverFields = [];
    var drivers = await globals.conn?.execute('select * from drivers');
    print('dostałem');
    print(drivers);
    print(drivers!.numOfRows);
    if (drivers.numOfRows == 0) {
      print('Nie działa');
      return [
        const Text(
          "Coś poszło nie tak, \nnie udało się pokazać kierowców.",
          style: TextStyle(color: Palette.activeTextColor),
          textAlign: TextAlign.center,
        ),
      ];
    }
    print('dalej');
    driverFields.add(
      SizedBox(
        height: 96,
        child: DrawerHeader(
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Twoje konto DOM-JAN',
                  style:
                      TextStyle(color: Palette.activeTextColor, fontSize: 24),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  FirebaseAuth.instance.currentUser?.email ?? 'dummy@',
                  style:
                      const TextStyle(color: Palette.linkColor, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    for (final driver in drivers.rows) {
      print("raz");
      print(driver.assoc());
      driverFields.add(
        GestureDetector(
          onTap: () {
            setState(
              () {
                globals.prefs?.setString('currentDriver',
                    '${driver.colAt(1)} ${'${driver.colAt(2)}'[0]}.');
              },
            );
          },
          child: ListTile(
            leading: Icon(
              globals.prefs?.getString('currentDriver') ==
                      '${driver.colAt(1)} ${'${driver.colAt(2)}'[0]}.'
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              size: 22,
              color: Palette.activeTextColor,
            ),
            title: Text(
              '${driver.colAt(1)} ${'${driver.colAt(2)}'[0]}.',
              style: const TextStyle(color: Palette.activeTextColor),
            ),
          ),
        ),
      );
    }

    return driverFields;
  }

  Future<List<Widget>> getAssignmentFields() async {
    List<Widget> assignmentFields = [];
    var assignments = await globals.conn?.execute('select * from drivers');
    if (assignments?.rows.length == 0) {
      assignmentFields.add(
        const Text(
          "Coś poszło nie tak, \nnie udało się pokazać kierowców.",
          style: TextStyle(color: Palette.activeTextColor),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      for (var assignment in assignments!.rows) {
        assignmentFields.add(
          GestureDetector(
            onTap: () {},
            child: Container(
              color: Colors.blue,
              height: 112,
              width: 384,
              child: Stack(
                children: [
                  const Text(
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
    }
    return assignmentFields;
  }
}
