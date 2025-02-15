import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenki/auth.dart';
import 'firestore_interface.dart';
import 'tenki_material/tenki_colors.dart';
import 'login_register_page.dart';
import 'package:tenki/verify.dart';
import 'tenki_material/appbars.dart';


class RegisterPage extends StatefulWidget {

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? errorMessage = '';
  bool _obscureText = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerPasswordConfirmation =
  TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      // Create database interface instance
      DatabaseInterface dbInterface = DatabaseInterface();
      // Add example data map for current user
      await dbInterface.addExampleDataMap();
      await dbInterface.addExampleLocationMap();
      // show success message
      showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: Text("Erfolgreich registriert!"),
              content: Text("Bitte bestätige deine E-Mail Adresse kurz, wir haben dir eine Mail geschickt."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text("Weiter zum Login"),
                ),
              ],
            ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return Text(
      'TENKI Registration',
      style: TextStyle(
        color: TenkiColor5(),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ElevatedButton(
        onPressed: () async {

          if (_formKey.currentState!.validate()) {
            if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty) {
              setState(() {
                errorMessage = 'Bitte gib eine E-Mail und ein Passwort an.';
              });
            } else if (_controllerPassword.text.length < 6) {
              setState(() {
                errorMessage = 'Das Passwort muss mindestens 6 Zeichen lang sein.';
              });
            } else if (_controllerPassword.text != _controllerPasswordConfirmation.text) {
              setState(() {
                errorMessage = 'Die eingegebenen Passwörter stimmen nicht überein - bitte überprüf das.';
              });
            } else {
              try {
                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _controllerEmail.text,
                  password: _controllerPassword.text,
                );
                // Create database interface instance
                DatabaseInterface dbInterface = DatabaseInterface();
                // Add example data map for current user
                await dbInterface.addExampleDataMap();
                await dbInterface.addExampleLocationMap();
                // show success message
                ///TO DO das sieht noch shit aus
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9F7F1),
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Erfolgreich registriert!",
                            style: TextStyle(
                              color: TenkiColor5(),
                              fontSize: 20.0,
                            ),
                          ),
                          SizedBox(height: 26.0),
                          Text(
                            "Bitte bestätige deine E-Mail Adresse kurz, wir haben dir eine Mail dazu geschickt.",
                            style: TextStyle(
                              color: TenkiColor5(),
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                Navigator.pop(context);
                              });
                              Navigator.of(context).pushReplacement( ///To Do: irgendwie muss sich dieses Fenster wieder schleißen!
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            child: Text(
                              "Weiter zum Login",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: TenkiColor1(),
                              ),
                            ),
                          )
                          ,],
                      ),
                  ),
                ));
              } on FirebaseAuthException catch (e) {
                if (e.code == 'email-already-in-use') {
                  setState(() {
                    errorMessage = 'Du hast bereits ein TENKI Konto!';
                  });
                } else if (e.code == 'weak-password') {
                  setState(() {
                    errorMessage = 'Das Passwort muss mindestens 6 Zeichen lang sein.';
                  });
                } else if (e.code == 'invalid-email') {
                  setState(() {
                    errorMessage = 'Bitte eine gültige E-Mail angeben.';
                  });
                } else if (e.code == 'passwords-dont-match') {
                  setState(() {
                    errorMessage = 'Die eingegebenen Passwörter stimmen nicht überein - bitte überprüfe das.';
                  });
                } else {
                  setState(() {
                    errorMessage = e.message ?? 'Bitte gib deine E-Mail und ein Passwort deiner Wahl an.';
                  });
                }
              }
            }
          }
        },
        child: Text(
          'Registrieren',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: TenkiColor1(),
          minimumSize: Size(double.infinity, 35),
        ),
      ),
    );
  }

  Widget _emptyField() {
    return SizedBox(height: 15);
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          labelStyle: TextStyle(color: TenkiColor4()),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: TenkiColor1(),
            ),
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
        ),
        cursorColor: TenkiColor4(),
        obscureText: isPassword ? _obscureText : false,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bitte Feld ausfüllen';
          }
          return null;
        },
      ),
    );
  }

    Widget _registerText() {
    return Text(
      'Bitte gib eine gültige Mailadresse an und wähle ein Passwort!',
      style: TextStyle(
        color: TenkiColor5(),
        fontSize: 16,
      ),
      textAlign: TextAlign.left,
    );
  }


  Widget _loginLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        child: Text(
          'Du hast bereits ein Konto? Hier entlang!',
          style: TextStyle(
            color: TenkiColor1(),
            fontSize: 16,
            decoration: TextDecoration.underline,
              ),
          textAlign: TextAlign.center,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBars.loginAppBar('Registrieren', context),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery
              .of(context)
              .size
              .height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE2DCCE), Color(0xFFFFFFFF)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              tileMode: TileMode.clamp,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _registerText(),
                  _emptyField(),
                  _entryField('E-Mail', _controllerEmail),
                  _entryField(
                      'Passwort', _controllerPassword, isPassword: true),
                  _entryField(
                      'Passwort bestätigen', _controllerPasswordConfirmation,
                      isPassword: true),
                  _emptyField(),
                  if (errorMessage != null && errorMessage!.isNotEmpty)
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: TenkiColor5(),
                        fontStyle: FontStyle.italic
                      ),
                    ),
                  _emptyField(),
                  _submitButton(),
                  _emptyField(),
                  _loginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}