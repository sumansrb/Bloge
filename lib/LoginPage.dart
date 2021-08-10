import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';
import 'package:ytapp/HomePage.dart';
import 'package:ytapp/admin_panel.dart';
import 'package:ytapp/data_update.dart';
import 'package:ytapp/utils/routes.dart';
import 'signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _email = TextEditingController();

  TextEditingController _pass = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  FirebaseAuth _auth = FirebaseAuth.instance;

  bool process = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: process == true
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Image.asset("assets/images/i1.1.gif",
                      width: 380, fit: BoxFit.cover),
                  Text(
                    "Welcome",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (text) {
                              if (isEmail(text!.trim()) == true) {
                                return null;
                              } else {
                                return "Enter email properly";
                              }
                            },
                            controller: _email,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: "Enter Email",
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: _pass,
                            obscureText: true,
                            validator: (text) {
                              if (text!.isEmpty) {
                                return "Enter password";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: "Enter Password",
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          InkWell(
                            onTap: () {
                              void singIn() async {
                                setState(() {
                                  process = true;
                                });
                                if (_email.text == "admin@email.com" &&
                                    _pass.text == "123456") {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AdminPanel()));
                                  setState(() {
                                    process = false;
                                  });
                                } else {
                                  try {
                                    _auth
                                        .signInWithEmailAndPassword(
                                            email: _email.text.trim(),
                                            password: _pass.text.trim())
                                        .then((value) async {
                                      var data = await FirebaseFirestore
                                          .instance
                                          .collection("User")
                                          .where("email",
                                              isEqualTo: _email.text.trim())
                                          .get();
                                      if (data.docs.isNotEmpty) {
                                        data.docs.forEach((element) async {
                                          var url = element.data()["imageURL"];
                                          var name = element.data()["name"];
                                          BlogApp.sharedPreferences!
                                              .setString("name", name);
                                          BlogApp.sharedPreferences!
                                              .setString("image", url);
                                        });
                                      }
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomePage()));
                                    });
                                  } catch (e) {
                                    print(e);
                                  }
                                  setState(() {
                                    process = false;
                                  });
                                }
                              }

                              if (_formKey.currentState!.validate()) {
                                singIn();
                              }
                            },
                            child: AnimatedContainer(
                              duration: Duration(seconds: 1),
                              width: 100,
                              height: 40,
                              alignment: Alignment.center,
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xff7C83FD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            // height: 20,
                            child: Container(
                                child:
                                    Text("or", style: TextStyle(fontSize: 14))),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => signup()));
                            },
                            child: AnimatedContainer(
                              duration: Duration(seconds: 1),
                              width: 150,
                              height: 50,
                              alignment: Alignment.center,
                              child: Text("Sign-up",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff301B3F),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

class BlogApp {
  static SharedPreferences? sharedPreferences;
}
