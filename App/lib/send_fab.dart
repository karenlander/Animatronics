// import 'package:animatronics/utils.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class FabWidget extends StatefulWidget {
//   int numOfMoves = 0;
//   List<String> moves;
//
//   FabWidget({required this.numOfMoves, required this.moves, Key? key}) : super(key: key);
//
//   @override
//   _FabWidgetState createState() => _FabWidgetState();
// }
//
// class _FabWidgetState extends State<FabWidget> {
//   final audioPlayer = AudioPlayer();
//
//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//         child: Icon(Icons.send),
//         backgroundColor: primaryOrange(),
//         onPressed: () {
//           //playAllAudio();
//         });
//   }
//
//   void playAllAudio() async
//   {
//     audioPlayer.setReleaseMode(ReleaseMode.STOP);
//
//     FirebaseStorage storage = FirebaseStorage.instance;
//     // /widget.moveNumber.toString()
//     String fileName = "move" + "1" + '.aac';
//     Reference ref = storage.ref().child(fileName);
//     String url = await ref.getDownloadURL();
//     audioPlayer.setUrl(url);
//   }
//
//   void dispose() {
//     audioPlayer.dispose();
//     super.dispose();
//   }
//
// }