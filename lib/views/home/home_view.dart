import 'package:domjan/views/home/buses.dart';
import 'package:domjan/views/home/drivers.dart';
import 'package:domjan/views/login/code_view.dart';
import 'package:domjan/views/login/login_view.dart';
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
  int _selectedHomeIndex = 0;
  late ValueNotifier<int> _selectedDrawerIndex;

  @override
  void initState() {
    super.initState();
    _selectedDrawerIndex = ValueNotifier(0);
  }

  void _onHomeItemTapped(int index) {
    setState(
      () {
        _selectedHomeIndex = index;
      },
    );
  }

  void _onDrawerItemTapped(int index) {
    _selectedDrawerIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: globals.conn?.execute(
          'SELECT * FROM drivers WHERE driver_mail = "${FirebaseAuth.instance.currentUser?.email}"'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            color: Palette.backgroundColor,
            child: const Center(
              child: Text(
                'Nie udało się\nzainicjować aplikacji.\n\nSpróbuj zresetować aplikację\na jeśli to nie pomoże,\nto skontaktuj się z adminem.',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Palette.domjanColor,
                    fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (snapshot.data?.numOfRows == 0) {
          return const CodeView();
        } else if (snapshot.hasData) {
          bool isAdmin = false;
          for (final driver in snapshot.data!.rows) {
            isAdmin = driver.typedColByName<bool>('admin')!;
          }
          globals.prefs!.setBool('admin', isAdmin);

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Scaffold(
                backgroundColor: Palette.backgroundColor,
                appBar: AppBar(
                  scrolledUnderElevation: 0,
                  iconTheme:
                      const IconThemeData(size: 36, color: Palette.domjanColor),
                  backgroundColor: Palette.appBarColor,
                  actions: <Widget>[
                    Builder(
                      builder: (context) {
                        // The current selected driver/bus on the appbar
                        String? currentDrawerSelection =
                            globals.prefs?.getString('currentDrawerSelection');
                        // Check if nothing selected yet
                        currentDrawerSelection ??= 'Wybierz Kierowcę.';
                        Icon icon;
                        // Check if it's a bus or a driver by looking at the last char
                        if (currentDrawerSelection[
                                currentDrawerSelection.length - 1] ==
                            '.') {
                          icon = const Icon(
                            Icons.person,
                            color: Palette.domjanColor,
                          );
                        } else {
                          icon = const Icon(
                            Icons.directions_bus,
                            color: Palette.domjanColor,
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          child: Row(
                            children: [
                              Text(
                                currentDrawerSelection,
                                style:
                                    const TextStyle(color: Palette.domjanColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: icon,
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
                                      color: Palette.activeTextColor,
                                      fontSize: 24),
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
                          _onHomeItemTapped(2);
                          Navigator.pop(context);
                        },
                        child: const ListTile(
                          leading: Icon(
                            Icons.person,
                            size: 22,
                            color: Palette.activeTextColor,
                          ),
                          title: Text(
                            'Kierowcy',
                            style: TextStyle(color: Palette.activeTextColor),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _onHomeItemTapped(3);
                          Navigator.pop(context);
                        },
                        child: const ListTile(
                          leading: Icon(
                            Icons.directions_bus,
                            size: 22,
                            color: Palette.activeTextColor,
                          ),
                          title: Text(
                            'Pojazdy',
                            style: TextStyle(color: Palette.activeTextColor),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _onHomeItemTapped(4);
                          Navigator.pop(context);
                        },
                        child: const ListTile(
                          leading: Icon(
                            Icons.phone,
                            size: 22,
                            color: Palette.activeTextColor,
                          ),
                          title: Text(
                            'Kontakty',
                            style: TextStyle(color: Palette.activeTextColor),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Widget cancelButton = TextButton(
                            child: const Text("Anuluj",
                                style:
                                    TextStyle(color: Palette.activeTextColor)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          );
                          Widget continueButton = TextButton(
                            child: const Text(
                              "Wyloguj",
                              style: TextStyle(color: Palette.errorColor),
                            ),
                            onPressed: () {
                              globals.prefs?.setBool('remember', false);
                              FirebaseAuth.instance.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const LoginView();
                                  },
                                ),
                                (route) => false,
                              );
                            },
                          );

                          showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                backgroundColor: Palette.backgroundColor,
                                contentTextStyle: const TextStyle(
                                    color: Palette.activeTextColor,
                                    fontSize: 24),
                                content: Container(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: const Text(
                                    'Czy na pewno\nchcesz się wylogować?',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                actions: [cancelButton, continueButton],
                              );
                            }),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(
                            Icons.exit_to_app,
                            size: 22,
                            color: Palette.selectColor,
                          ),
                          title: Text(
                            'Wyloguj się',
                            style: TextStyle(color: Palette.selectColor),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                bottomNavigationBar: Theme(
                  data: ThemeData(splashFactory: NoSplash.splashFactory),
                  child: BottomNavigationBar(
                    backgroundColor: Palette.appBarColor,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_filled),
                        label: 'Harmonogram',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.calendar_month),
                        label: 'Kalendarz',
                      ),
                    ],
                    selectedItemColor: _selectedHomeIndex > 1
                        ? Palette.focusColor
                        : Palette.domjanColor,
                    unselectedItemColor: Palette.focusColor,
                    currentIndex:
                        _selectedHomeIndex > 1 ? 0 : _selectedHomeIndex,
                    onTap: _onHomeItemTapped,
                  ),
                ),
                body: () {
                  switch (_selectedHomeIndex) {
                    case 0:
                      {
                        return timeline();
                      }
                    case 1:
                      {
                        return const Calendar();
                      }
                    case 2:
                      {
                        return const Drivers();
                      }
                    case 3:
                      {
                        return const Buses();
                      }
                    case 4:
                      {
                        return timeline();
                      }
                  }
                }(),
                endDrawer: StatefulBuilder(
                  builder: (context, setState) {
                    return Drawer(
                      backgroundColor: Palette.backgroundColor,
                      child: ValueListenableBuilder(
                          valueListenable: _selectedDrawerIndex,
                          builder: (context, value, child) {
                            return FutureBuilder(
                              future: getDrawerFields(value),
                              builder: (context, snapshot) {
                                return ListView(
                                  children: snapshot.data ??
                                      [
                                        const Text(
                                          "Coś poszło nie tak, \nnie udało się pokazać kierowców.",
                                          style: TextStyle(
                                              color: Palette.activeTextColor),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                );
                              },
                            );
                          }),
                    );
                  },
                ),
              );
            },
          );
        } else {
          return const Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                color: Palette.domjanColor,
                strokeWidth: 10,
              ),
            ),
          );
        }
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

  Future<List<Widget>> getDrawerFields(int index) async {
    List<Widget> drawerFields = [];

    drawerFields.add(
      SizedBox(
        height: 88,
        child: Theme(
          data: ThemeData(
            splashFactory: NoSplash.splashFactory,
            shadowColor: Colors.transparent,
            canvasColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  size: 24,
                ),
                label: 'Kierowcy',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.directions_bus,
                  size: 24,
                ),
                label: 'Pojazdy',
              ),
            ],
            selectedItemColor: Palette.domjanColor,
            unselectedItemColor: Palette.focusColor,
            currentIndex: index,
            onTap: _onDrawerItemTapped,
          ),
        ),
      ),
    );

    drawerFields.add(
      Container(
        color: Colors.white,
        height: 0.8,
      ),
    );

    // Get Drivers
    if (index == 0) {
      var drivers = await globals.conn?.execute(
          'SELECT driver_name, driver_surname, driver_id FROM drivers;');
      if (drivers?.numOfRows == 0) {
        return [
          const Text(
            "Coś poszło nie tak, \nnie udało się pokazać kierowców.",
            style: TextStyle(color: Palette.activeTextColor),
            textAlign: TextAlign.center,
          ),
        ];
      }
      for (final driver in drivers!.rows) {
        drawerFields.add(
          GestureDetector(
            onTap: () {
              setState(
                () {
                  globals.prefs?.setString('currentDrawerSelection',
                      '${driver.colAt(0)} ${'${driver.colAt(1)}'[0]}.');
                  globals.prefs?.setInt(
                      'currentDrawerSelectionID', int.parse(driver.colAt(2)!));
                  globals.prefs
                      ?.setString('currentDrawerSelectionType', 'driver');
                },
              );
            },
            child: ListTile(
              leading: Icon(
                globals.prefs?.getString('currentDrawerSelection') ==
                        '${driver.colAt(0)} ${'${driver.colAt(1)}'[0]}.'
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 22,
                color: Palette.activeTextColor,
              ),
              title: Text(
                '${driver.colAt(0)} ${'${driver.colAt(1)}'[0]}.',
                style: const TextStyle(color: Palette.activeTextColor),
              ),
            ),
          ),
        );
      }
      // Get Vehicles
    } else {
      var vehicles = await globals.conn?.execute(
          'SELECT bus_name, bus_region, bus_plate, bus_id FROM buses');
      if (vehicles?.numOfRows == 0) {
        return [
          const Text(
            "Coś poszło nie tak, \nnie udało się pokazać pojazdów.",
            style: TextStyle(color: Palette.activeTextColor),
            textAlign: TextAlign.center,
          ),
        ];
      }
      for (final vehicle in vehicles!.rows) {
        drawerFields.add(
          GestureDetector(
            onTap: () {
              setState(
                () {
                  globals.prefs?.setString(
                      'currentDrawerSelection', '${vehicle.colAt(0)}');
                  globals.prefs?.setInt(
                      'currentDrawerSelectionID', int.parse(vehicle.colAt(3)!));
                  globals.prefs?.setString('currentDrawerSelectionType', 'bus');
                },
              );
            },
            child: ListTile(
              leading: Icon(
                globals.prefs?.getString('currentDrawerSelection') ==
                        '${vehicle.colAt(0)}'
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 22,
                color: Palette.activeTextColor,
              ),
              title: Text(
                '${vehicle.colAt(0)} [${vehicle.colAt(1)} ${'${vehicle.colAt(2)}'}]',
                style: const TextStyle(color: Palette.activeTextColor),
              ),
            ),
          ),
        );
      }
    }
    return drawerFields;
  }

  Future<List<Widget>> getAssignmentFields() async {
    List<Widget> assignmentFields = [];
    var assignments = await globals.conn?.execute('select * from drivers');
    // ignore: prefer_is_empty
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
