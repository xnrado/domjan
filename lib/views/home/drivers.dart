import 'package:domjan/views/classes.dart';
import 'package:flutter/material.dart';

import '../../palette.dart';
import '../../globals.dart' as globals;

class Drivers extends StatefulWidget {
  const Drivers({super.key});

  @override
  State<Drivers> createState() => _DriversState();
}

class _DriversState extends State<Drivers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: FutureBuilder(
        future: getDrivers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Nie udało się załadować informacji\no kierowcach.',
                style: TextStyle(color: Palette.domjanColor, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData) {
            final Map<int, Driver> drivers = snapshot.data as Map<int, Driver>;
            final List<Driver> driversValues = drivers.values.toList();
            final double width = MediaQuery.of(context).size.width - 20;
            final double idWidth = (width / 10) * 1;
            final double nameWidth = (width / 10) * 5 - 2;
            final double busesWidth = (width / 10) * 4;

            return DefaultTextStyle(
              style: const TextStyle(color: Palette.activeTextColor),
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1,
                maxScale: 3,
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Palette.loginBox,
                        border: Border(
                          bottom: BorderSide(
                              color: Palette.activeTextColor, width: 1.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: idWidth,
                            child: const Text('ID'),
                          ),
                          const VerticalDivider(
                            color: Palette.inactiveTextColor,
                            width: 1,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: nameWidth,
                            child: const Text('Kierowca'),
                          ),
                          const VerticalDivider(
                            color: Palette.inactiveTextColor,
                            width: 1,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: busesWidth,
                            child: const Text('Pojazdy'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const Divider(
                          color: Palette.activeTextColor,
                          height: 5,
                          thickness: 0.5,
                        ),
                        itemCount: driversValues.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  transitionDuration:
                                      const Duration(milliseconds: 200),
                                  reverseTransitionDuration:
                                      const Duration(milliseconds: 200),
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      DriverView(driver: drivers[index + 1]!),
                                  transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) =>
                                      SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: IntrinsicHeight(
                              child: Container(
                                color: index % 2 == 1
                                    ? Palette.loginBox
                                    : Palette.backgroundColor,
                                constraints:
                                    const BoxConstraints(minHeight: 40),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      width: idWidth,
                                      child: Text(driversValues[index]
                                          .driverId
                                          .toString()),
                                    ),
                                    const VerticalDivider(
                                      color: Palette.inactiveTextColor,
                                      width: 1,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      width: nameWidth,
                                      child: Text(
                                          '${driversValues[index].driverName} ${driversValues[index].driverSurname[0]}.'),
                                    ),
                                    const VerticalDivider(
                                      color: Palette.inactiveTextColor,
                                      width: 1,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      width: busesWidth,
                                      child: () {
                                        String text = '';
                                        for (final bus in driversValues[index]
                                            .driverBuses!) {
                                          text = '$text$bus\n';
                                        }
                                        return Text(text.substring(
                                            0,
                                            text.length - 1 < 0
                                                ? 0
                                                : text.length - 1));
                                      }(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
      ),
    );
  }
}

class DriverView extends StatefulWidget {
  final Driver driver;

  DriverView({super.key, required this.driver});

  @override
  State<DriverView> createState() => _DriverViewState();
}

class _DriverViewState extends State<DriverView> {
  @override
  Widget build(BuildContext context) {
    Driver driver = widget.driver;
    final double width = MediaQuery.of(context).size.width - 20;

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(size: 36, color: Palette.domjanColor),
        backgroundColor: Palette.appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
          future: globals.conn!.execute(
              'SELECT * FROM buses WHERE bus_owner = ${driver.driverId}'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Nie udało się załadować informacji\no kierowcy.',
                  style: TextStyle(color: Palette.domjanColor, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (snapshot.hasData) {
              return InteractiveViewer(
                panEnabled: true,
                minScale: 1,
                maxScale: 3,
                child: DefaultTextStyle(
                  style: const TextStyle(color: Palette.activeTextColor),
                  child: Column(
                    children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Palette.backgroundColor,
                              border: Border(
                                bottom: BorderSide(
                                    color: Palette.activeTextColor, width: 1.0),
                              ),
                            ),
                            constraints: const BoxConstraints(minHeight: 50),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Kierowca',
                                  style: TextStyle(fontSize: 20),
                                )
                              ],
                            ),
                          )
                        ] +
                        staticFields(width, driver) +
                        [
                          Container(
                            decoration: const BoxDecoration(
                              color: Palette.loginBox,
                              border: Border(
                                top: BorderSide(
                                    color: Palette.activeTextColor, width: 2.0),
                                bottom: BorderSide(
                                    color: Palette.activeTextColor, width: 1.0),
                              ),
                            ),
                            constraints: const BoxConstraints(minHeight: 50),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Pojazdy pod opieką',
                                  style: TextStyle(fontSize: 20),
                                )
                              ],
                            ),
                          )
                        ] +
                        [],
                  ),
                ),
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
          }),
      // ListView.separated(itemBuilder: itemBuilder, separatorBuilder: (context, index) => const Divider(
      //                     color: Palette.activeTextColor,
      //                     height: 5,
      //                     thickness: 0.5,
      //                   ), itemCount: )
    );
  }

  List<Container> staticFields(double width, Driver driver) {
    List<Container> fields = [];
    List<List<String>> names = [];
    if (globals.prefs!.getBool('admin')!) {
      names = [
        ['ID', driver.driverId.toString()],
        ['Imie i nazwisko', '${driver.driverName} ${driver.driverSurname}'],
        ['Kod kierowcy', '${driver.driverCode}'],
        ['E-mail kierowcy', '${driver.driverMail}']
      ];
    } else {
      names = [
        ['ID', driver.driverId.toString()],
        ['Imie i nazwisko', '${driver.driverName} ${driver.driverSurname}']
      ];
    }
    for (final (index, entry) in names.indexed) {
      fields.add(
        Container(
          decoration: BoxDecoration(
            color: index % 2 == 0 ? Palette.loginBox : Palette.backgroundColor,
            border: const Border(
              bottom: BorderSide(color: Palette.activeTextColor, width: 1.0),
            ),
          ),
          constraints: const BoxConstraints(minHeight: 50),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10),
                width: width / 2,
                child: Text(entry[0]),
              ),
              Container(
                padding: const EdgeInsets.only(left: 10),
                width: width / 2,
                child: Text(
                  entry[1] == 'null' ? '<Brak>' : entry[1],
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return fields;
  }

  List<Container> vehicleFields(double width, Driver driver) {
    List<Container> fields = [];
    List<List<String>> names = [];
    if (globals.prefs!.getBool('admin')!) {
      names = [
        ['ID', driver.driverId.toString()],
        ['Imie i nazwisko', '${driver.driverName} ${driver.driverSurname}'],
        ['Kod kierowcy', '${driver.driverCode}'],
        ['E-mail kierowcy', '${driver.driverMail}']
      ];
    } else {
      names = [
        ['ID', driver.driverId.toString()],
        ['Imie i nazwisko', '${driver.driverName} ${driver.driverSurname}']
      ];
    }
    for (final (index, entry) in names.indexed) {
      fields.add(
        Container(
          decoration: BoxDecoration(
            color: index % 2 == 0 ? Palette.loginBox : Palette.backgroundColor,
            border: const Border(
              bottom: BorderSide(color: Palette.activeTextColor, width: 1.0),
            ),
          ),
          constraints: const BoxConstraints(minHeight: 50),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10),
                width: width / 2,
                child: Text(entry[0]),
              ),
              Container(
                padding: const EdgeInsets.only(left: 10),
                width: width / 2,
                child: Text(
                  entry[1] == 'null' ? '<Brak>' : entry[1],
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return fields;
  }
}
