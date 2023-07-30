import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../palette.dart';

import '../../globals.dart' as globals;

import '../home/home_view.dart';
import 'login_view.dart';

class CodeView extends StatefulWidget {
  const CodeView({super.key});

  @override
  State<CodeView> createState() => _CodeViewState();
}

class _CodeViewState extends State<CodeView> {
  late StreamController<ErrorAnimationType> errorController;

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(size: 36, color: Palette.domjanColor),
        backgroundColor: Palette.appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const LoginView(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        SlideTransition(
                  position: animation.drive(
                    Tween(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.ease)),
                  ),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 250 -
                (AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top),
            child: Container(
              height: 300,
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
                  Column(
                    children: [
                      const Text(
                        'KOD KIEROWCY',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Palette.activeTextColor),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        height: 2,
                        width: 140,
                        color: Palette.domjanColor,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                  ),
                  const Text(
                    'Przed użyciem aplikacji musisz przypisać do swojego konta kod kierowcy.',
                    style:
                        TextStyle(color: Palette.activeTextColor, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Palette.errorColor,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                    width: 300,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Palette.errorColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Uwaga: Rozmiar liter ma znaczenie',
                          style: TextStyle(color: Palette.errorColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Theme(
                    data: ThemeData(
                        textTheme: const TextTheme(
                          labelLarge: TextStyle(color: Palette.activeTextColor),
                        ),
                        dialogTheme: const DialogTheme(
                          backgroundColor: Palette.backgroundColor,
                          titleTextStyle: TextStyle(
                              color: Palette.activeTextColor, fontSize: 24),
                        ),
                        dialogBackgroundColor: Palette.backgroundColor),
                    child: PinCodeTextField(
                      pastedTextStyle:
                          const TextStyle(color: Palette.domjanColor),
                      dialogConfig: DialogConfig(
                          affirmativeText: 'Skopiuj',
                          negativeText: 'Anuluj',
                          dialogContent: 'Czy chcesz skopiować kod ',
                          dialogTitle: 'Kopiowanie kodu'),
                      enablePinAutofill: false,
                      keyboardType: TextInputType.text,
                      appContext: context,
                      length: 6,
                      obscureText: false,
                      animationType: AnimationType.fade,
                      textStyle:
                          const TextStyle(color: Palette.activeTextColor),
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Palette.backgroundColor,
                          selectedColor: Palette.selectColor,
                          inactiveColor: Palette.inactiveTextColor,
                          activeColor: Palette.domjanColor),
                      animationDuration: const Duration(milliseconds: 300),
                      errorAnimationController: errorController,
                      onCompleted: (v) async {
                        List codes = [];
                        final query = await globals.conn!.execute(
                            'SELECT driver_code FROM drivers WHERE driver_mail IS null');
                        for (final row in query.rows) {
                          codes.add(row.typedColByName<String>('driver_code'));
                        }
                        // If code valid
                        if (codes.contains(v)) {
                          await globals.conn!.execute(
                              'UPDATE drivers SET driver_mail = "${FirebaseAuth.instance.currentUser?.email}" WHERE driver_code = "$v"');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Pomyślnie przypisano kod "${v}" do adresu "${FirebaseAuth.instance.currentUser?.email}"!')),
                          );
                          Navigator.of(context).pushAndRemoveUntil(
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 200),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 200),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const HomeView(),
                              transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) =>
                                  SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          errorController.add(ErrorAnimationType.shake);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
