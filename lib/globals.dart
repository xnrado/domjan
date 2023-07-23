library domjan.globals;

import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

MySQLConnection? conn;
SharedPreferences? prefs;
Map drivers = {};
