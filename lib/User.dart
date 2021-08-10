import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ytapp/HomePage.dart';
import 'package:ytapp/data_update.dart';
import 'package:ytapp/utils/routes.dart';

import 'LoginPage.dart';

class UserProfile extends StatelessWidget {
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          "Hi! ${BlogApp.sharedPreferences!.getString("name")}",
          style: const TextStyle(fontSize: 20,fontFamily: "Pacifico"),
        ),
        backgroundColor: Color(0xff1A1A2E),
    ),body: Center(
      child: Container(
        height: double.infinity,
        width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 60,),
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(BlogApp.sharedPreferences!.getString("image").toString()),
              ),
              SizedBox(height: 60,),
              Container(
                margin: EdgeInsets.only(left: 30,right: 30),
                padding: EdgeInsets.all(10),
                height: 150,
                width: double.infinity,
                child: Center(child: Text('''"After a while, necessary actions can start to feel like chores."''',style: TextStyle(fontSize: 20,color: Colors.white,fontFamily: "Pacifico",fontWeight: FontWeight.w400,),textAlign: TextAlign.center,)),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white,width: 3),
                  borderRadius: BorderRadius.circular(10)
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                  colors: [Color(0xff01024E), Color(0xffFF1E56)]
         ),
    ),
      ),
    ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xff1A1A2E),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()));} , icon: Icon(Icons.home,color: Color(
                0xfff0e3ff),),),
            IconButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>UserProfile()));}, icon: Icon(Icons.person,color: Color(0xffF0E3FF),),),
            IconButton(onPressed: () {
              void signOut()async{
                await _auth.signOut().then((value){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                });
              }
              signOut();
            }, icon: Icon(Icons.power_settings_new,color: Color(0xffF0E3FF)),),
          ],
        ),
      ),


    );
  }
}
