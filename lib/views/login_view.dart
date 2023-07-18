import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../palette.dart';

import '../globals.dart' as globals;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isSignupScreen = false;
  bool isRememberMe = false;

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
                  if (isSignupScreen)
                    buildSignupSection()
                  else
                    buildLoginSection()
                ]),
              ),
            ),
            // Login/Signup button
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
                        _formKeySignup.currentState!.validate();

                        // Login an existing user
                      } else {
                        _formKeyLogin.currentState!.validate();
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
                      ),
                    ),
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
          FutureBuilder(
            future: switchController(controller),
            builder: (context, snapshot) {
              return TextFormField(
                controller: controller,
                style: const TextStyle(color: Palette.activeTextColor),
                obscureText: isPassword,
                keyboardType:
                    isEmail ? TextInputType.emailAddress : TextInputType.text,
                decoration: InputDecoration(
                    prefixIcon: icon,
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide:
                            BorderSide(color: Palette.inactiveTextColor)),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide:
                            BorderSide(width: 2, color: Palette.focusColor)),
                    hintText: hintText,
                    hintStyle:
                        const TextStyle(color: Palette.inactiveTextColor)),
                validator: (value) {
                  var text = snapshot.data?[0];
                  var valid = snapshot.data?[1];
                  if (!valid) {
                    return text;
                  }
                  return null;
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List> switchController(TextEditingController? controller) async {
    // Signin
    if ([_emailSignup, _passwordSignup, _confirmPassword]
        .contains(controller)) {
      bool emailValid = true;
      bool passwordValid = true;
      bool confirmPasswordValid = true;
      // E-mail adress doesn't fit the regex
      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(_emailSignup.text) &&
          controller == _emailSignup) {
        emailValid = false;
        return ['Wpisz poprawny adres e-mail.', false];
      }
      // Password not inputted or shorter than 6 characters
      if (_passwordSignup.text.isEmpty ||
          _passwordSignup.text.length < 6 && controller == _passwordSignup) {
        passwordValid = false;
        return ['Hasło musi mieć przynajmniej 6 znaków.', false];
      }
      // Second password doesn't match the first one
      if (_confirmPassword.text != _passwordSignup.text &&
          controller == _confirmPassword) {
        confirmPasswordValid = false;
        return ['Hasła się ze sobą nie zgadzają.', false];
      }
      // If everything is OK, try to sign up the user
      if (emailValid && passwordValid && confirmPasswordValid) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailSignup.text, password: _passwordSignup.text);
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _emailSignup.text, password: _passwordSignup.text);
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && !user.emailVerified) {
            user.sendEmailVerification();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Na twój e-mail został wysłany link aktywacyjny!')),
          );
          // If sign up is succesful, return everything as valid
          return ['', true];
          // Email already in use
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            if (controller == _emailSignup) {
              return ['Konto z takim adresem e-mail już istnieje.', false];
            }
          }
        }
      }

      // This is needed so valid inputs aren't registered as invalid
      return ['', true];
      // Login
    } else {
      bool emailValid = true;
      bool passwordValid = true;
      // E-mail adress doesn't fit the regex
      if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(_emailLogin.text) &&
          controller == _emailLogin) {
        emailValid = false;
        return ['Wpisz poprawny adres e-mail.', false];
      }
      // Password not inputted
      if (_passwordSignup.text.isEmpty && controller == _passwordLogin) {
        passwordValid = false;
        return ['Wpisz hasło.', false];
      }
      // If everything is OK, try to login the user
      if (emailValid && passwordValid) {
        try {
          var user = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _emailLogin.text, password: _passwordLogin.text);
          // The email isn't verified
          if (!(user.user?.emailVerified ?? false)) {
            FirebaseAuth.instance.currentUser?.sendEmailVerification();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Musisz zweryfikować swój adres e-mail!')),
            );

            if (controller == _emailLogin) {
              return [
                'Ten e-mail nie został zweryfikowany, sprawdź pocztę.',
                false
              ];
            } else {
              return ['', true];
            }
            // You have been logged in
          } else {
            globals.prefs.setString('email', _emailLogin.text);
            globals.prefs.setString('password', _passwordLogin.text);
            globals.prefs.setBool('remember', isRememberMe);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zostałeś pomyślnie zalogowany!')),
            );
            // Check if the driver has a valid code and route
            if (globals.prefs.getString('code')?.isNotEmpty ?? false) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home/',
                (route) => false,
              );
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/code/',
                (route) => false,
              );
            }

            return ['', true];
          }
          // Wrong login credentials
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' || e.code == 'wrong-password') {
            if (controller == _emailLogin) {
              return ['Konto z takimi danymi nie istnieje.', false];
            } else {
              return ['', true];
            }
          }
        }
      }

      // This is needed so valid inputs aren't registered as invalid
      return ['', true];
    }
  }
}
