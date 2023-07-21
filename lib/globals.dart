library domjan.globals;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

MySQLConnection? conn;
SharedPreferences? prefs;
Map drivers = {};
