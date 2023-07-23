import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../palette.dart';

import '../globals.dart' as globals;

import 'home/home_view.dart';
import 'resetPassword_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final isSignupScreen = ValueNotifier<bool>(false);
  final isRememberMe =
      ValueNotifier<bool>(globals.prefs?.getBool('remember') ?? false);

  final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeySignup = GlobalKey<FormState>();

  final _emailLogin =
      TextEditingController(text: globals.prefs?.getString('email'));
  final _passwordLogin =
      TextEditingController(text: globals.prefs?.getString('password'));

  final _emailSignup = TextEditingController();
  final _passwordSignup = TextEditingController();
  final _confirmPassword = TextEditingController();

  // I hate this, but Form validator doesn't accept async Strings
  Map validation = {};

  @override
  void dispose() {
    _emailLogin.dispose();
    _passwordLogin.dispose();
    _emailSignup.dispose();
    _passwordSignup.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: Stack(
        children: [
          // Main container for login and signup
          const HeaderWidget(),
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
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          isSignupScreen.value = false;
                        },
                        child: ValueListenableBuilder(
                          valueListenable: isSignupScreen,
                          builder: (context, value, child) => Column(
                            children: [
                              Text(
                                "LOGOWANIE",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: !value
                                        ? Palette.activeTextColor
                                        : Palette.inactiveTextColor),
                              ),
                              if (!value)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  height: 2,
                                  width: 115,
                                  color: Palette.domjanColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          isSignupScreen.value = true;
                        },
                        child: ValueListenableBuilder(
                          valueListenable: isSignupScreen,
                          builder: (context, value, child) => Column(
                            children: [
                              Text(
                                "REJESTRACJA",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: !value
                                        ? Palette.inactiveTextColor
                                        : Palette.activeTextColor),
                              ),
                              if (value)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  height: 2,
                                  width: 115,
                                  color: Palette.domjanColor,
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ValueListenableBuilder(
                    valueListenable: isSignupScreen,
                    builder: (context, value, child) {
                      if (value) {
                        return buildSignupSection();
                      } else {
                        return buildLoginSection();
                      }
                    },
                  ),
                ],
              ),
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
                  ],
                ),
                child: GestureDetector(
                  onTap: () async {
                    // Signup a new user
                    if (isSignupScreen.value) {
                      await switchController();
                      _formKeySignup.currentState!.validate();

                      // Login an existing user
                    } else {
                      await switchController();
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
      ),
    );
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
                    ValueListenableBuilder(
                      valueListenable: isRememberMe,
                      builder: (context, value, child) => Checkbox(
                          value: value,
                          activeColor: Palette.domjanColor,
                          onChanged: (value) {
                            isRememberMe.value = !isRememberMe.value;
                          }),
                    ),
                    const Text('Zapamiętaj mnie',
                        style: TextStyle(
                            fontSize: 14, color: Palette.activeTextColor)),
                  ],
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 200),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 200),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const ResetPasswordView(),
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
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                borderSide: BorderSide(color: Palette.inactiveTextColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
                borderSide: BorderSide(width: 2, color: Palette.focusColor),
              ),
              hintText: hintText,
              hintStyle: const TextStyle(color: Palette.inactiveTextColor),
            ),
            validator: (value) {
              if (controller == _emailSignup) {
                return validation['signupEmail'] ??
                    validation['signUpEmailUsed'];
              } else if (controller == _passwordSignup) {
                return validation['signupPassword'];
              } else if (controller == _confirmPassword) {
                return validation['signupConfirmPassword'];
              } else if (controller == _emailLogin) {
                return validation['loginEmail'] ??
                    validation['loginEmailNotVerified'] ??
                    validation['loginWrong'];
              } else if (controller == _passwordLogin) {
                return validation['loginPassword'];
              } else {
                return null;
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> switchController() async {
    validation = {};
    if (isSignupScreen.value) {
      // Signin
      bool emailValid = true;
      bool passwordValid = true;
      bool confirmPasswordValid = true;
      // E-mail adress doesn't fit the regex
      if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(_emailSignup.text)) {
        emailValid = false;
        validation['signupEmail'] = 'Wpisz poprawny adres e-mail.';
      }
      // Password not inputted or shorter than 6 characters
      if (_passwordSignup.text.isEmpty || _passwordSignup.text.length < 6) {
        passwordValid = false;
        validation['signupPassword'] = 'Hasło musi mieć przynajmniej 6 znaków.';
      }
      // Second password doesn't match the first one
      if (_confirmPassword.text != _passwordSignup.text) {
        confirmPasswordValid = false;
        validation['signupConfirmPassword'] = 'Hasła się ze sobą nie zgadzają.';
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
          // Email already in use
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            validation['signUpEmailUsed'] =
                'Konto z takim adresem e-mail już istnieje.';
          }
        }
      }
    }

    // Login
    else {
      bool emailValid = true;
      bool passwordValid = true;
      // E-mail adress doesn't fit the regex
      if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(_emailLogin.text)) {
        emailValid = false;
        validation['loginEmail'] = 'Wpisz poprawny adres e-mail.';
      }
      // Password not inputted
      if (_passwordLogin.text.isEmpty) {
        passwordValid = false;
        validation['loginPassword'] = 'Wpisz hasło.';
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

            validation['loginEmailNotVerified'] =
                'Niezweryfikowany e-mail, sprawdź pocztę.';

            // You have been logged in
          } else {
            globals.prefs?.setString('email', _emailLogin.text);
            globals.prefs?.setString('password', _passwordLogin.text);
            globals.prefs?.setBool('remember', isRememberMe.value);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zostałeś pomyślnie zalogowany!')),
            );

            // Route to HomeView
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeView(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
            );
          }
          // Wrong login credentials
        } on FirebaseAuthException {
          validation['loginWrong'] = 'Konto z takimi danymi nie istnieje.';
        }
      }
    }
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 0,
      left: 0,
      child: Container(
        height: 250,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/login_background.png"),
          ),
        ),
      ),
    );
  }
}
