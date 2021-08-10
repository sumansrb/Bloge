import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ytapp/LoginPage.dart';
import 'package:ytapp/User.dart';
import 'package:ytapp/add_post.dart';
import 'package:ytapp/utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Post> postlist = [];

  Future<void> getPost() async {
    postlist.clear();
    var data = await FirebaseFirestore.instance.collection("Post").get();
    for (int i = 0; i < data.docs.length; i++) {
      Post post = Post(
          name: data.docs[i].data()["name"],
          postDesc: data.docs[i].data()["desc"],
          imageURL: data.docs[i].data()["userimage"],
          postTitle: data.docs[i].data()["title"],
          postURL: data.docs[i].data()["imageURL"]);
      postlist.add(post);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Feed",
          style: TextStyle(
            color: Color(0xffF0E3FF),


          ),
        ),
        backgroundColor: Color(0xff1A1A2E),
      ),
      body: RefreshIndicator(
        onRefresh: getPost,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff01024E), Color(0xffFF1E56)]),
          ),
          child: Container(
            child: postlist.length == 0
                ? Center(child: Text("No Post",style: TextStyle(fontSize: 20,color: Colors.white),),)
                : ListView.builder(
                    itemCount: postlist.length,
                    itemBuilder: (_, index) {
                      return PostCard(
                          postlist[index].postTitle,
                          postlist[index].postURL,
                          postlist[index].postDesc,
                          postlist[index].name,
                          postlist[index].imageURL);
                    },
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddPost()));
        },
        child: Icon(
          Icons.add,
          color: Color(0xffffffff),
        ),
        backgroundColor: Color(0xffE41F7B),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xff1A1A2E),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              icon: Icon(
                Icons.home,
                color: Color(0xffF0E3FF),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserProfile()));
              },
              icon: Icon(
                Icons.person,
                color: Color(0xffF0E3FF),
              ),
            ),
            IconButton(
              onPressed: () {
                void signOut() async {
                  await _auth.signOut().then((value) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  });
                }

                signOut();
              },
              icon: Icon(Icons.power_settings_new, color: Color(0xffF0E3FF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget PostCard(String? title, String? postImage, String? desc, String? user,
      String? userpic) {
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
          Text(
            title!,
            style: TextStyle(
                color: Colors.white, fontSize: 26,fontFamily: "Pacifico", fontWeight: FontWeight.w400),
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
                    backgroundImage:NetworkImage(userpic!) ,
                    radius: 30,
                    backgroundColor: Colors.transparent,
                  ),
                  Text(
                    user!,
                    style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  } //use this to modify card
}

class Post {
  String? name;
  String? imageURL;
  String? postTitle;
  String? postDesc;
  String? postURL;
  Post({this.name, this.imageURL, this.postTitle, this.postDesc, this.postURL});
}
