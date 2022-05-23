
import 'package:cloud_firestore/cloud_firestore.dart';
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
  parts.removeLast();
  int sensor = 0 ;
  for(int i= 0; i< parts.length ; i++){
      if(sensor == 0){
        s1Data.add(cutEnter(parts[i]));
      }else if(sensor == 1){
        s2Data.add(parts[i]);
      }else{
        s3Data.add(parts[i]);
      }
      //TODO; change for sensor 3
      sensor = (sensor + 1) % 2;
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

Future<String> readFileWithoutParse(String path) async {
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref().child(path);
  DataSnapshot data = await ref.get();
  String fileWithHeader = data.value as String;
  String fileContent = fileWithHeader.split(',').last;
  // if (fileContent.length % 4 > 0) {
  //   fileContent += '=' * (4 - fileContent.length % 4) ;// as suggested by Albert221
  // }

  return utf8.decode(base64.decode(fileContent));
}

Future<int> getNumOfMoves() async{
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref().child('numOfMoves/numOfMoves');
  DataSnapshot data = await ref.get();
  return data.value as int;
}

Future<String> getTotalAudioTime() async{
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref().child('audioTime/audioTime');
  DataSnapshot data = await ref.get();
  return data.value as String;
}

void setTotalAudioTime(String audioTime) async{
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref().child('audioTime');
  ref.set( {"audioTime": audioTime});
}

void setNumOfMoves(int numOfMoves) async{
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = database.ref().child('numOfMoves');
  ref.set( {"numOfMoves": numOfMoves});
}

void setMovesOnFirebase(int numOfMoves, var _moves){
  var moves = {
    "moves" : _moves
  };
  var reference = FirebaseFirestore.instance.collection("moves").doc("Cy2AIQT0ZNJRqELykUeq");
  reference.set(moves);
}

Future<List<String>> getMovesOnFirebase() async{
  var reference = FirebaseFirestore.instance.collection("moves").doc("Cy2AIQT0ZNJRqELykUeq");
  return await reference.get().then((value) => value.data()!['moves'].cast<String>());
}


