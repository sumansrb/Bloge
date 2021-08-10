import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytapp/data_update.dart';
import 'package:firebase_core/firebase_core.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BlogApp.sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  runApp(MyApp());
}//standard tempelate for firebase use



class MyApp extends StatelessWidget {
  FirebaseAuth _auth =FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: getScreen(),
    );
  }
  Widget getScreen(){
    if(_auth.currentUser!=null){
      return HomePage();
    }
    else{
      return LoginPage();
    }
  } //if user is logged in in he will be redirected to home
}

