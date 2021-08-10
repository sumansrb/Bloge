import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class Analysis extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analytics"),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back,color: Colors.white,),
        ), backgroundColor: Color(0xff1A1A2E),
      ),
      body: WebView(
        initialUrl: "https://console.firebase.google.com/u/0/project/blogapp-bcf7a/overview",
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
