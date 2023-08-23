import 'package:domjan/views/classes.dart';
import 'package:flutter/material.dart';

import '../../palette.dart';
import '../../globals.dart' as globals;

class Buses extends StatefulWidget {
  const Buses({super.key});

  @override
  State<Buses> createState() => _BusesState();
}

class _BusesState extends State<Buses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.backgroundColor,
        body: () {
          final double width = MediaQuery.of(context).size.width - 20;
          final double idWidth = (width / 10) * 1;
          final double nameWidth = (width / 10) * 4 - 2;
          final double plateWidth = (width / 10) * 2.4 - 1;
          final double ownerWidth = (width / 10) * 2.6;

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
                          child: const Text('Pojazd'),
                        ),
                        const VerticalDivider(
                          color: Palette.inactiveTextColor,
                          width: 1,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          width: plateWidth,
                          child: const Text('Rejestracja'),
                        ),
                        const VerticalDivider(
                          color: Palette.inactiveTextColor,
                          width: 1,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          width: ownerWidth,
                          child: const Text('Opiekun'),
                        ),
                      ],
                    ),
                  ),
                  BusFields(),
                ],
              ),
            ),
          );
        }());
  }
}

class BusFields extends StatelessWidget {
  String? like;

  BusFields({super.key, this.like});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width - 20;
    final double idWidth = (width / 10) * 1;
    final double nameWidth = (width / 10) * 4 - 2;
    final double plateWidth = (width / 10) * 2.4 - 1;
    final double ownerWidth = (width / 10) * 2.6;

    return FutureBuilder(
      future: getBuses(where: 'driver_id', like: like),
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
          final Map<int, Bus> buses = snapshot.data as Map<int, Bus>;
          final List<Bus> busesValues = buses.values.toList();
          return Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(
                color: Palette.activeTextColor,
                height: 5,
                thickness: 0.5,
              ),
              itemCount: busesValues.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 200),
                        reverseTransitionDuration:
                            const Duration(milliseconds: 200),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            BusView(bus: buses[index + 1]!),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
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
                      constraints: const BoxConstraints(minHeight: 40),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: idWidth,
                            child: Text(busesValues[index].busId.toString()),
                          ),
                          const VerticalDivider(
                            color: Palette.inactiveTextColor,
                            width: 1,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: nameWidth,
                            child: Text.rich(TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: '${busesValues[index].busName}\n',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: busesValues[index].busModel)
                            ])),
                          ),
                          const VerticalDivider(
                            color: Palette.inactiveTextColor,
                            width: 1,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: plateWidth,
                            child: Text(
                                '${busesValues[index].busRegion} ${busesValues[index].busPlate}'),
                          ),
                          const VerticalDivider(
                            color: Palette.inactiveTextColor,
                            width: 1,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: ownerWidth,
                            child: () {
                              if (busesValues[index].driverName?.isNotEmpty ??
                                  false) {
                                return Text(
                                    '${busesValues[index].driverName} ${busesValues[index].driverSurname![0]}');
                              } else {
                                return const Text('<Brak>');
                              }
                            }(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
    );
  }
}

class BusView extends StatefulWidget {
  final Bus bus;

  BusView({super.key, required this.bus});

  @override
  State<BusView> createState() => _BusViewState();
}

class _BusViewState extends State<BusView> {
  @override
  Widget build(BuildContext context) {
    Bus bus = widget.bus;
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
        future: globals.conn!
            .execute('SELECT * FROM buses WHERE bus_owner = ${bus.busId}'),
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
                                  'Pojazd',
                                  style: TextStyle(fontSize: 20),
                                )
                              ],
                            ),
                          )
                        ] +
                        busFields(width, bus)),
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

  List<Container> busFields(double width, Bus bus) {
    List<Container> fields = [];
    List<List<String>> names = [];
    if (globals.prefs!.getBool('admin')!) {
      names = [
        ['ID', bus.busId.toString()],
        ['Nazwa', bus.busName],
        ['Model', bus.busModel],
        ['Rocznik', bus.busYear.toString()],
        ['Liczba Miejsc', bus.busCapacity ?? '-'],
        ['VIN', bus.busVin ?? '-'],
        ['Rejestracja', '${bus.busRegion} ${bus.busPlate}'],
        [
          'Opiekun',
          bus.driverName?.isNotEmpty ?? false
              ? '${bus.driverName} ${bus.driverSurname}'
              : 'null'
        ]
      ];
    } else {
      names = [
        ['ID', bus.busId.toString()],
        ['Nazwa', bus.busName],
        ['Model', bus.busModel],
        ['Rocznik', bus.busYear.toString()],
        ['Liczba Miejsc', bus.busCapacity ?? '-'],
        ['VIN', bus.busVin ?? '-'],
        ['Rejestracja', '${bus.busRegion} ${bus.busPlate}'],
        [
          'Opiekun',
          bus.driverName?.isNotEmpty ?? false
              ? '${bus.driverName} ${bus.driverSurname}'
              : 'null'
        ]
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
