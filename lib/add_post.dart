import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ytapp/HomePage.dart';
import 'package:ytapp/LoginPage.dart';
import 'package:ytapp/data_update.dart';


class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}
class _AddPostState extends State<AddPost> {
  File? _imageFile;
  final _picker=ImagePicker();
  final _title=TextEditingController();
  final _desc=TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool processing=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: processing==true?Center(child: CircularProgressIndicator()):Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff01024E), Color(0xffFF1E56)]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white)
                    ),
                    height: 200,
                    width: 200,
                    child: _imageFile==null?Center(child: Icon(Icons.add_a_photo,size: 60,color: Colors.white,)):Image.file(_imageFile!),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                        },
                        child: Text("Add Image"),
                      ),
                      ElevatedButton(
                        onPressed: (){
                          setState(() {
                            _imageFile=null;
                          });
                        },
                        child: Text("Remove"),
                      ),
                    ],
                  ),
                  SizedBox(height: 60,),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white,width: 2),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    width: 360,
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(hintText: "Title",hintStyle: TextStyle(color: Colors.white),contentPadding: EdgeInsets.only(left: 5),border: InputBorder.none),
                      controller: _title,
                      validator: (text){
                        if(text!.isNotEmpty)
                          return null;
                        else
                          return "Value can't be blank";
                      },
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white,width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    width: 360,
                    child: TextFormField(
                      maxLines: null,
                      decoration: InputDecoration(border:InputBorder.none,hintText: "Description",hintStyle: TextStyle(color: Colors.white),contentPadding: EdgeInsets.only(left: 5)),
                      controller: _desc,
                      style: TextStyle(color: Colors.white),
                      validator: (text){
                        if(text!.isNotEmpty)
                          return null;
                        else
                          return "Can't be empty";
                      },
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(onPressed: (){
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
                  }, child: Text("Submit"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  uploadButton() async {
    setState(() {
      processing=true;
    });
    String imageURL=await uploadImageAndGetURL(_imageFile);
    saveAllDataToFirebase(imageURL);
  }

  Future<String> uploadImageAndGetURL(img)async{
    final Reference itemPicRef=FirebaseStorage.instance.ref().child("PostPics");
    String nameForPicture=DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask=itemPicRef.child(nameForPicture+".jpg").putFile(img);
    TaskSnapshot taskSnapshot =await uploadTask;
    String downloadUrl=await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  saveAllDataToFirebase(String imgURL)async{
    await FirebaseFirestore.instance.collection("Post").doc().set({
      "title":_title.text.trim(),
      "imageURL":imgURL,
      "desc":_desc.text.trim(),
      "name":BlogApp.sharedPreferences!.getString("name"),
      "userimage":BlogApp.sharedPreferences!.getString("image")
    }).whenComplete((){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Post Added successfully"),behavior: SnackBarBehavior.floating,));
      setState(() {
        processing=false;
        _imageFile=null;
        _title.clear();
        _desc.clear();
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));}).onError((error, stackTrace) => print(error));
  }
}
