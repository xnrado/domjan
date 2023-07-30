import 'package:flutter/material.dart';

import '../globals.dart' as globals;

class Event {
  final int assignmentId;
  final String? assignmentName;
  final DateTime assignmentDatetime;
  final DateTime? assignmentDatetimeEnd;
  final Color assignmentColor;
  final int? driverId;
  final String? driverName;
  final String? driverSurname;
  final int? busId;
  final String? busName;
  final String? busRegion;
  final String? busPlate;

  Event(
      {required this.assignmentId,
      required this.assignmentDatetime,
      required this.assignmentColor,
      this.assignmentName,
      this.assignmentDatetimeEnd,
      this.driverId,
      this.driverName,
      this.driverSurname,
      this.busId,
      this.busName,
      this.busRegion,
      this.busPlate});
}

Future<Map<DateTime, List<Event>>> getEvents(ID, type) async {
  var query = await globals.conn!.execute("""
  SELECT 
    assignment_id,
    a.driver_id, 
    a.bus_id,
    assignment_name, 
    assignment_datetime, 
    assignment_end_datetime,
    assignment_color,
    driver_name, 
    driver_surname, 
    bus_name, 
    bus_region, 
    bus_plate 
  FROM 
    assignments a 
    LEFT JOIN drivers d ON a.driver_id = d.driver_id 
    LEFT JOIN buses b ON a.bus_id = b.bus_id 
  WHERE 
    a.${type}_id = $ID
  ORDER BY 
    assignment_datetime;""");

  Map<DateTime, List<Event>> events = {};

  for (final row in query.rows) {
    final int assignmentId = row.typedColByName<int>('assignment_id')!;
    final String? assignmentName =
        row.typedColByName<String>('assignment_name');
    final DateTime assignmentDatetime =
        DateTime.parse(row.colByName('assignment_datetime')!);
    final DateTime? assignmentDatetimeEnd =
        DateTime.tryParse(row.colByName('assignment_end_datetime') ?? '');
    final Color assignmentColor = Color(
        int.parse(row.typedColByName<String>('assignment_color')!, radix: 16) +
            0xFF000000);
    final int? driverId = row.typedColByName<int>('driver_id');
    final String? driverName = row.typedColByName('driver_name');
    final String? driverSurname = row.typedColByName('driver_surname');
    final int? busId = row.typedColByName<int>('bus_id');
    final String? busName = row.typedColByName('bus_name');
    final String? busRegion = row.typedColByName('bus_region');
    final String? busPlate = row.typedColByName('bus_plate');

    print(assignmentColor);

    DateTime date = DateTime.utc(assignmentDatetime.year,
        assignmentDatetime.month, assignmentDatetime.day);
    if (events[date] == null) {
      events[date] = [
        Event(
            assignmentId: assignmentId,
            assignmentName: assignmentName,
            assignmentDatetime: assignmentDatetime,
            assignmentDatetimeEnd: assignmentDatetimeEnd,
            assignmentColor: assignmentColor,
            driverId: driverId,
            driverName: driverName,
            driverSurname: driverSurname,
            busId: busId,
            busName: busName,
            busRegion: busRegion,
            busPlate: busPlate)
      ];
    } else {
      events[date]!.add(
        Event(
            assignmentId: assignmentId,
            assignmentName: assignmentName,
            assignmentDatetime: assignmentDatetime,
            assignmentDatetimeEnd: assignmentDatetimeEnd,
            assignmentColor: assignmentColor,
            driverId: driverId,
            driverName: driverName,
            driverSurname: driverSurname,
            busId: busId,
            busName: busName,
            busRegion: busRegion,
            busPlate: busPlate),
      );
    }
  }
  return events;
}

class Driver {
  final int driverId;
  final String driverName;
  final String driverSurname;
  final String driverCode;
  final String? driverMail;
  final List? driverBuses;
  final bool admin;

  Driver(
      {required this.driverId,
      required this.driverName,
      required this.driverSurname,
      required this.driverCode,
      this.driverMail,
      this.driverBuses = const [],
      required this.admin});
}

Future<Map<int, Driver>> getDrivers() async {
  var query = await globals.conn!.execute("""
  SELECT 
  driver_id, 
  driver_name, 
  driver_surname, 
  driver_code, 
  driver_mail, 
  admin, 
  bus_name 
FROM 
  drivers d 
  LEFT JOIN buses b ON d.driver_id = b.bus_owner;""");

  Map<int, Driver> drivers = {};

  for (final row in query.rows) {
    final int driverId = row.typedColByName<int>('driver_id')!;
    final String driverName = row.typedColByName<String>('driver_name')!;
    final String driverSurname = row.typedColByName<String>('driver_surname')!;
    print('uno');
    final String driverCode = row.typedColByName<String>('driver_code')!;
    print('dos');
    final String? driverMail = row.typedColByName<String>('driver_mail');
    final bool admin = row.typedColByName<bool>('admin')!;
    final String? busName = row.typedColByName<String>('bus_name');

    if (drivers[driverId] == null) {
      drivers[driverId] = Driver(
          driverId: driverId,
          driverName: driverName,
          driverSurname: driverSurname,
          driverCode: driverCode,
          driverMail: driverMail,
          driverBuses: busName != null ? [busName] : [],
          admin: admin);
    } else {
      drivers[driverId]!.driverBuses!.add(busName);
    }
  }

  return drivers;
}
