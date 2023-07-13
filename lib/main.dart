import 'package:domjan/palette.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'views/login_view.dart' as login_view;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const login_view.LoginView(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
