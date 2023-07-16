import 'package:domjan/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'views/login_view.dart';
import 'views/home_view.dart';

import 'globals.dart' as globals;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Initialize preferences
  globals.prefs = await SharedPreferences.getInstance();

  // Connect to the database
  globals.conn = await MySqlConnection.connect(ConnectionSettings(
    host: dotenv.env['HOST'] as String,
    user: dotenv.env['USER'] as String,
    password: dotenv.env['PASSWORD'] as String,
    db: dotenv.env['DB'] as String,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOM-JAN',
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Palette.cursorColor,
            selectionColor: Palette.textSelection,
            selectionHandleColor: Palette.cursorColor),
        useMaterial3: true,
      ),
      home: FutureBuilder<Map>(
        future: getPreferences(),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Map preferences = snapshot.data as Map;
            if ((preferences['isRememberMe'] ?? false) &&
                (preferences['email']?.isNotEmpty ?? false) &&
                (preferences['password']?.isNotEmpty ?? false)) {
              FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: preferences['email'] as String,
                  password: preferences['password'] as String);
              return const HomeView();
            } else {
              return const LoginView();
            }
          } else {
            return const LoginView();
          }
        },
      ),
      routes: {
        '/login/': (context) => const LoginView(),
        '/home/': (context) => const HomeView()
      },
    );
  }
}

Future<Map> getPreferences() async {
  var pref = {};

  // Get last session preferences
  pref['email'] = globals.prefs.getString('email');
  pref['password'] = globals.prefs.getString('password');
  pref['isRememberMe'] = globals.prefs.getBool('remember');

  return pref;
}
