import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../palette.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final GlobalKey<FormState> _formKeyPassReset = GlobalKey<FormState>();

  final _emailPassReset = TextEditingController();

  Map validation = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(size: 36, color: Palette.domjanColor),
        backgroundColor: Palette.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
              height: 200,
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
                        'RESETOWANIE HASŁA',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Palette.activeTextColor),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        height: 2,
                        width: 185,
                        color: Palette.domjanColor,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Form(
                      key: _formKeyPassReset,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailPassReset,
                                  style: const TextStyle(
                                      color: Palette.activeTextColor),
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.alternate_email),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide: BorderSide(
                                          color: Palette.inactiveTextColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      borderSide: BorderSide(
                                          width: 2, color: Palette.focusColor),
                                    ),
                                    hintText: 'Adres e-mail',
                                    hintStyle: TextStyle(
                                        color: Palette.inactiveTextColor),
                                  ),
                                  validator: (value) =>
                                      validation['resetPassEmail'] ??
                                      validation['resetPassNotFound'],
                                )
                              ],
                            ),
                          ),
                        ], // Icons.alternate_email
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 425 -
                (AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top),
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
                    await switchController();
                    _formKeyPassReset.currentState!.validate();
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

  Future<void> switchController() async {
    validation = {};

    bool emailValid = true;

    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailPassReset.text)) {
      emailValid = false;
      validation['resetPassEmail'] = 'Wpisz poprawny adres e-mail.';
    }

    if (emailValid) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailPassReset.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Na twój e-mail został wysłany link do zresetowania hasła!')),
        );
      } on FirebaseAuthException {
        validation['resetPassNotFound'] =
            'Konto z takim adresem e-mail nie istnieje.';
        return;
      }
    }
  }
}
