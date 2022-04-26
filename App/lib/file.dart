
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert' show utf8, base64;
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

Future<String> readFile(String path) async {
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref().child(path);
  DataSnapshot data = await ref.get();
  String fileWithHeader = data.value as String;
  String fileContent = fileWithHeader.split(',').last;
  // if (fileContent.length % 4 > 0) {
  //   fileContent += '=' * (4 - fileContent.length % 4) ;// as suggested by Albert221
  // }
  return utf8.decode(base64.decode(fileContent));
  //TODO: parse data
}

void writeFile(String path, String data) async {
  //TODO: how to write this file
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref().child(path);
  var bytes = utf8.encode(data);
  var base64Str = base64.encode(bytes);
  String file = "File,base64," + base64Str  ;
  ref.set( {"data": file});
}

Future<bool> existFile(int moveNumber) async{
  //TODO: change
  try{
    String fileName = "Move" + moveNumber.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(fileName);
    var data = await ref.getData();
    return true;
  }catch(e){
    return false;
  }
}

