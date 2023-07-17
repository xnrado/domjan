import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import '../palette.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isSignupScreen = false;
  bool isRememberMe = false;
  bool overwriteValid = false; // This is stupid, but it works.

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeySignup = GlobalKey<FormState>();

  final _emailLogin = TextEditingController();
  final _passwordLogin = TextEditingController();

  final _emailSignup = TextEditingController();
  final _passwordSignup = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _emailLogin.dispose();
    _passwordLogin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Palette.backgroundColor,
        body: Stack(
          children: [
            // Main container for login and signup
            Positioned(
                top: 20,
                right: 0,
                left: 0,
                child: Container(
                  height: 250,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/login_background.png"))),
                )),
            // Text Fields and other decorations
            Positioned(
              top: 250,
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width - 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    color: Palette.loginBox,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5)
                    ]),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSignupScreen = false;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              "LOGOWANIE",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: !isSignupScreen
                                      ? Palette.activeTextColor
                                      : Palette.inactiveTextColor),
                            ),
                            if (!isSignupScreen)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                height: 2,
                                width: 115,
                                color: Palette.domjanColor,
                              )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSignupScreen = true;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              "REJESTRACJA",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: !isSignupScreen
                                      ? Palette.inactiveTextColor
                                      : Palette.activeTextColor),
                            ),
                            if (isSignupScreen)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                height: 2,
                                width: 115,
                                color: Palette.domjanColor,
                              )
                          ],
                        ),
                      )
                    ],
                  ),
                  if (!isSignupScreen)
                    buildLoginSection()
                  else
                    buildSignupSection()
                ]),
              ),
            ),
            // Button
            Positioned(
              top: 625,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 90,
                  width: 90,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Palette.loginBox,
                      borderRadius: BorderRadius.circular(300),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1))
                      ]),
                  child: GestureDetector(
                    onTap: () async {
                      // Signup a new user
                      if (isSignupScreen) {
                        if (_formKeySignup.currentState!.validate()) {
                          final email = _emailSignup.text;
                          final password = _passwordSignup.text;

                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: email, password: password);
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password);
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null && !user.emailVerified) {
                              user.sendEmailVerification();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Na twój e-mail został wysłany link aktywacyjny!')),
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'email-already-in-use') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Konto z takim adresem e-mail już istnieje!')),
                              );
                            }
                          }
                        }
                        // Login an existing user
                      } else {
                        overwriteValid = true;
                        if (_formKeyLogin.currentState!.validate()) {
                          final email = _emailLogin.text;
                          final password = _passwordLogin.text;

                          try {
                            var user = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password);
                            bool isEmailVerified =
                                user.user?.emailVerified ?? false;
                            // You haven't verified your e-mail
                            if (!isEmailVerified) {
                              FirebaseAuth.instance.currentUser
                                  ?.sendEmailVerification();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Musisz zweryfikować swój adres e-mail!')),
                              );
                              // You have been logged in
                            } else {
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              pref.setString('email', email);
                              pref.setString('password', password);
                              pref.setBool('remember', isRememberMe);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Zostałeś pomyślnie zalogowany!')),
                              );
                              // Transition to the /home/ route
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home/',
                                (route) => false,
                              );
                            }
                            // Wrong login credentials
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found' ||
                                e.code == 'wrong-password') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Konto z takimi danymi nie istnieje!')),
                              );
                              overwriteValid = false;
                              _formKeyLogin.currentState!.validate();
                            }
                          }
                        }
                      }
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [
                                  Colors.deepOrangeAccent,
                                  Palette.domjanColor
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(300)),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 40,
                        )),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Container buildSignupSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Form(
        key: _formKeySignup,
        child: Column(
          children: [
            buildTextField(
                const Icon(
                  Icons.alternate_email,
                  color: Palette.inactiveTextColor,
                ),
                hintText: 'Adres e-mail',
                controller: _emailSignup,
                isEmail: true),
            buildTextField(
                const Icon(
                  Icons.key,
                  color: Palette.inactiveTextColor,
                ),
                hintText: 'Hasło',
                controller: _passwordSignup,
                isPassword: true),
            buildTextField(
                const Icon(
                  Icons.key,
                  color: Palette.inactiveTextColor,
                ),
                hintText: 'Powtórz hasło',
                controller: _confirmPassword,
                isPassword: true),
          ],
        ),
      ),
    );
  }

  Container buildLoginSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Form(
        key: _formKeyLogin,
        child: Column(
          children: [
            buildTextField(
                const Icon(
                  Icons.alternate_email,
                  color: Palette.inactiveTextColor,
                ),
                hintText: 'Adres e-mail',
                controller: _emailLogin,
                isEmail: true),
            buildTextField(
                const Icon(
                  Icons.key,
                  color: Palette.inactiveTextColor,
                ),
                hintText: 'Hasło',
                controller: _passwordLogin,
                isPassword: true),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                        value: isRememberMe,
                        activeColor: Palette.domjanColor,
                        onChanged: (value) {
                          setState(() {
                            isRememberMe = !isRememberMe;
                          });
                        }),
                    const Text('Zapamiętaj mnie',
                        style: TextStyle(
                            fontSize: 14, color: Palette.activeTextColor)),
                  ],
                ),
                TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Zapomniałeś hasła?',
                      style: TextStyle(color: Palette.linkColor),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildTextField(Icon icon,
      {String? hintText,
      bool isPassword = false,
      bool isEmail = false,
      TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Palette.activeTextColor),
            obscureText: isPassword,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(
                prefixIcon: icon,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Palette.inactiveTextColor)),
                focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide:
                        BorderSide(width: 2, color: Palette.focusColor)),
                hintText: hintText,
                hintStyle: const TextStyle(color: Palette.inactiveTextColor)),
            validator: (value) {
              var (text, valid) = switchController(controller);
              if (!valid) {
                return text;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  (String, bool) switchController(TextEditingController? controller) {
    bool valid = false;
    // Signin
    if (controller == _emailSignup) {
      valid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(_emailSignup.text);
      return ('Wpisz poprawny adres e-mail.', valid);
    } else if (controller == _passwordSignup) {
      valid =
          _passwordSignup.text.isNotEmpty && _passwordSignup.text.length > 5;
      return ('Hasło musi mieć przynajmniej 6 znaków.', valid);
    } else if (controller == _confirmPassword) {
      valid = _confirmPassword.text == _passwordSignup.text;
      return ('Hasła się ze sobą nie zgadzają.', valid);
      // Login
    } else if (controller == _passwordLogin) {
      valid = overwriteValid ? true : false;
      return ('Hasło lub adres e-mail się ze sobą nie zgadzają.', valid);
    } else if (controller == _emailLogin) {
      valid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(_emailLogin.text);
      return ('Wpisz poprawny adres e-mail.', valid);
      // ???
    } else {
      valid = false;
      return (' ', valid);
    }
  }
}
