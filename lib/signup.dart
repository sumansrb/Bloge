import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ytapp/HomePage.dart';
import 'package:ytapp/LoginPage.dart';
import 'package:ytapp/utils/routes.dart';
import 'package:string_validator/string_validator.dart';
import 'dart:io';

import 'data_update.dart';

class signup extends StatefulWidget {

  @override
  _signupState createState() => _signupState();
}

class _signupState extends State<signup> {
  TextEditingController _name=TextEditingController();


  TextEditingController _email=TextEditingController();

  TextEditingController _pass=TextEditingController();

  TextEditingController _cpass=TextEditingController();
  final _picker=ImagePicker();

  final _formKey = GlobalKey<FormState>();

  FirebaseAuth _auth = FirebaseAuth.instance;

  File? _imageFile;

  bool processing=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:processing==true?Center(child: CircularProgressIndicator()): SingleChildScrollView(
          child: Column(
            children: [
              // IconButton(
              //   icon: const Icon(Icons.download), onPressed: () {  },
              // ),
              //Image.asset("assets/images/i4.gif",
                //  fit: BoxFit.cover,height: 210),
              SizedBox(
                height: 35,
              ),
              Text(
                "Welcome",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,color: Color(0xff060930)
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xff476072))
                        ),
                        height: 100,
                        width: 100,
                        child: _imageFile==null?Center(child: Icon(Icons.add_a_photo,color: Color(0xffD83A56),)):Image.file(_imageFile!),
                      ),SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: (){
                          void addImage()async{
                            final pickedFile=await _picker.getImage(source: ImageSource.gallery);
                            if(pickedFile!=null){
                              setState(() {
                                _imageFile=File(pickedFile.path);
                              });
                            }
                          }
                          addImage();
                        },style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
                          ),
                        child: Text("Add profile Image"),
                      ),
                      ElevatedButton(
                        onPressed: (){
                          setState(() {
                            _imageFile=null;
                          });
                        },style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color(0xffDA0037))),
                        child: Text("Remove"),
                      ),
                      TextFormField(
                        controller: _name,
                        validator: (text){
                          if(text!.isEmpty){
                            return "Please Enter Name";
                          }
                          else{
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.sort_by_alpha),
                          hintText: "Name",
                        ),

                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        validator: (text){
                          if(isEmail(text!)==true){
                            return null;
                          }
                          else{
                            return "Enter email properly";
                          }
                        },
                        controller: _email,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_add),
                          hintText: "Enter Email",
                        ),

                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        validator: (text){
                          if(text!.isEmpty){
                            return "Enter password";
                          }
                          else if(text.trim().length<=5){
                            return "Password is too small";
                          }
                          else{
                            return null;
                          }
                        },
                        controller: _pass,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: "Enter Password",
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        validator: (text){
                          if(text!.trim()==_pass.text){
                            return null;
                          }
                          else{
                            return "Password not matching";
                          }
                        },
                        controller: _cpass,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.security),
                          hintText: "Confirm Password",
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Future<String> uploadImageAndGetURL(img)async{
                            final Reference itemPicRef=FirebaseStorage.instance.ref().child("UserPics");
                            String nameForPicture=DateTime.now().millisecondsSinceEpoch.toString();
                            UploadTask uploadTask=itemPicRef.child(nameForPicture+".jpg").putFile(img);
                            TaskSnapshot taskSnapshot =await uploadTask;
                            String downloadUrl=await taskSnapshot.ref.getDownloadURL();
                            return downloadUrl;
                          }
                          saveAllDataToFirebase(String imgURL)async{
                            await FirebaseFirestore.instance.collection("User").doc().set({
                              "name":_name.text.trim(),
                              "imageURL":imgURL,
                              "email":_email.text.trim(),
                              "password":_pass.text.trim()
                            }).whenComplete(()async{
                              var data=await FirebaseFirestore.instance.collection("User").where("email", isEqualTo: _email.text.trim()).get();
                              if(data.docs.isNotEmpty){
                                data.docs.forEach((element) async{
                                  var url=element.data()["imageURL"];
                                  var name=element.data()["name"];
                                  BlogApp.sharedPreferences!.setString("name", name);
                                  BlogApp.sharedPreferences!.setString("image", url);
                                });
                              }
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User registered successfully"),behavior: SnackBarBehavior.floating,));
                              setState(() {
                                processing=false;
                                _imageFile=null;
                                _name.clear();
                                _email.clear();
                                _pass.clear();
                              });
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));}).onError((error, stackTrace) => print(error));
                          }
                          uploadButton() async {
                            setState(() {
                              processing=true;
                            });
                            _auth.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim()).then((value) async {
                              String imageURL=await uploadImageAndGetURL(_imageFile);
                              saveAllDataToFirebase(imageURL);
                            });

                          }
                          if(_imageFile==null){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Please add image"),
                              duration: Duration(seconds: 2),
                            ));
                          }
                          else{
                            if(_formKey.currentState!.validate()){uploadButton();}
                            else{print("Something wrong");}
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          child:Text(
                            "Sign-up",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          decoration: BoxDecoration(
                              color: Color(0xff7C83FD),
                              borderRadius: BorderRadius.circular(8)),
                        ),

                      ),
                      SizedBox(
                        height: 20,
                      ),

                      SizedBox(

                        //height: 20,
                        child: Container(
                            child: Text("Already have an account",
                                style: TextStyle(
                                    fontSize: 14
                                )
                            )
                        ),
                      ),
                      // ElevatedButton(onPressed: () {
                      //   Navigator.pushNamed(context, MyRoutes.homeRoute);
                      // }, child: Text("Login"),

                      // style: TextButton.styleFrom(minimumSize: Size(90, 40),
                      //     backgroundColor: Color(0xff334257),
                      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                        },
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          width: 150,
                          height: 50,
                          alignment: Alignment.center,
                          child:Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff301B3F),
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        )
    );
  }
}
