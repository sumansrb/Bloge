import 'package:flutter/cupertino.dart';

class NameStatus extends ChangeNotifier{
  late String _name;
  String getName()=>_name;
  updateName(String name){
    _name=name;
    notifyListeners();
  }
}


class PicStatus extends ChangeNotifier{
  late String _picURL;
  String getImage()=>_picURL;
  updateImage(String imageURL){
    _picURL=imageURL;
    notifyListeners();
  }
}