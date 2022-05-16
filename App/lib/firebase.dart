
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert' show utf8, base64;
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

Future<List<List<String>>> readFile(String path) async {
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref().child(path);
  DataSnapshot data = await ref.get();
  String fileWithHeader = data.value as String;
  String fileContent = fileWithHeader.split(',').last;
  // if (fileContent.length % 4 > 0) {
  //   fileContent += '=' * (4 - fileContent.length % 4) ;// as suggested by Albert221
  // }

  return parseData(utf8.decode(base64.decode(fileContent)));
}

List<List<String>> parseData(String content){
  List<String> s1Data =  <String> [];
  List<String> s2Data =  <String> [];
  List<String> s3Data =  <String> [];
  List<List<String>> sensorsData = [];
  var parts = content.split(' ');
  for(int i= 0; i< parts.length ; i++){
    if(parts[i] == "S1"){
      s1Data.add(cutEnter(parts[i-1]));
    }else if (parts[i] == "S2"){
      s2Data.add(parts[i-1]);
    }else if (parts[i] == "S3"){
      s3Data.add(parts[i-1]);
    }
  }
  sensorsData.add(s1Data);
  sensorsData.add(s2Data);
  sensorsData.add(s3Data);
  return sensorsData;
}

String cutEnter(String original){
  String toAdd = original;
  if(original.startsWith('\n')){
    var pos = original.lastIndexOf('\n');
    toAdd = original.substring(pos + 1);
  }
  return toAdd;
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

Future<int> getNumOfMoves() async{
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref().child('numOfMoves/numOfMoves');
  DataSnapshot data = await ref.get();
  return data.value as int;
}

void setNumOfMoves(int numOfMoves) async{
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref().child('numOfMoves');
  ref.set( {"numOfMoves": numOfMoves});
}


