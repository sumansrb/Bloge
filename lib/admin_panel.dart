import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ytapp/LoginPage.dart';
import 'package:ytapp/analytics.dart';

import 'HomePage.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int count=0;
  Future<void> getPost() async {
    adminlist.clear();
    var data = await FirebaseFirestore.instance.collection("Post").get();
    count=data.docs.length;
    for (int i = 0; i < data.docs.length; i++) {
      Post2 post = Post2(
          name: data.docs[i].data()["name"],
          postDesc: data.docs[i].data()["desc"],
          imageURL: data.docs[i].data()["userimage"],
          postTitle: data.docs[i].data()["title"],
          postURL: data.docs[i].data()["imageURL"],
        id: data.docs[i].id
      );
      adminlist.add(post);
      setState(() {});
    }
  }

  List<Post2> adminlist = [];

  @override
  void initState() {
    getPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),

        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Analysis()));
          }, icon: Icon(Icons.analytics_outlined,color: Colors.green,)),
          SizedBox(width: 5,),
          IconButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
          }, icon: Icon(Icons.power_settings_new,color: Colors.red,)),

        ], backgroundColor: Color(0xff1A1A2E),
      ),
      body: RefreshIndicator(
        onRefresh: getPost,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff01024E), Color(0xffFF1E56)]),
            ),
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                SizedBox(height: 10,),
                Text("Total Post: $count",style: TextStyle(fontSize: 22,fontFamily:"Pacifico",color: Colors.white),),
                SizedBox(height: 5,),
                Expanded(
                  child: Container(
                    child: adminlist.length == 0
                        ? Center(
                            child: Text(
                              "No Post",
                              style: TextStyle(fontSize: 22, fontFamily:"Pacifico",color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                      shrinkWrap: true,
                            itemCount: adminlist.length,
                            itemBuilder: (_, index) {
                              return PostCard(
                                  adminlist[index].postTitle,
                                  adminlist[index].postURL,
                                  adminlist[index].postDesc,
                                  adminlist[index].name,
                                  adminlist[index].imageURL,
                                adminlist[index].id
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget PostCard(String? title, String? postImage, String? desc, String? user,
      String? userpic,String? id) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title!,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontFamily: "Pacifico",
                    fontWeight: FontWeight.w400),
              ),
              IconButton(onPressed: (){
                void delete()async{
                  await FirebaseFirestore.instance.collection("Post").doc(id).delete();
                  getPost();
                }
                delete();
              }, icon:Icon(Icons.delete_forever_rounded,color: Colors.white,)),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Image.network(
              postImage!,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 250,
                  child: Text(
                    "Description: $desc",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userpic!),
                    radius: 30,
                    backgroundColor: Colors.transparent,
                  ),
                  Text(
                    user!,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Post2 {
  String? name;
  String? imageURL;
  String? postTitle;
  String? postDesc;
  String? postURL;
  String? id;
  Post2({this.name, this.imageURL, this.postTitle, this.postDesc, this.postURL,this.id});
}