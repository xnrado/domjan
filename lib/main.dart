import 'package:domjan/palette.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var home = LoginView();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
              return HomeView();
            } else {
              return LoginView();
            }
          } else {
            return LoginView();
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
  var pref = new Map();

  // Get last session preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  pref['email'] = prefs.getString('email');
  pref['password'] = prefs.getString('password');
  pref['isRememberMe'] = prefs.getBool('remember');

  return pref;
}
