import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';


Future<String> readFile() async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child("testRead.txt");
  var data = await ref.getData();
  return String.fromCharCodes(data!);
  //TODO: parse data
}

void writeFile(String data) async {
  //TODO: how to write this file
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('testWrite.txt');
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/my_file.txt');
  await file.writeAsString(data);
  var uploadTask = await ref.putFile(File(file.path));
}