import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animatronics/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'edit-audio.dart';
import 'edit-sensor.dart';
import 'expandable-fab.dart';
import 'firebase.dart';

class EditMove extends StatefulWidget {
  int moveNumber;
  List<String> moves;
  EditMove({Key? key, required this.moveNumber, required this.moves}) : super(key: key);

  @override
  _EditMoveState createState() => _EditMoveState();
}

class _EditMoveState extends State<EditMove> {
  bool loadingFirebase = true;
  late List<List<String>> sensorsData;
  bool fromPause = false;
  var audioPlayer = AudioPlayer();

  void initState() {
    super.initState();
    parseFileOfMove();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  void parseFileOfMove() async {
    String path = "Glove/RecordedMoves/Move" + widget.moveNumber.toString() + "/data";
    sensorsData = await readFile (path);
    setState(() {
      loadingFirebase = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget main;
    if (loadingFirebase) {
      main = Center(
        child: CircularProgressIndicator(color: darkOrange()),
      );
    } else {
      main = getTabs(context, widget.moveNumber);
    }
    return Scaffold(
        backgroundColor: lightPink(),
        floatingActionButton: ExpandableFab(
          distance: 112.0,
          children: [
            stopFab(),
            pauseFab(),
            playFab(),
          ],
        ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: primaryOrange(),
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                children: [
                  newText(27, Colors.white, "Move " + widget.moveNumber.toString(), false, true),
                ],
              ),
            ),
          ),
        ),
        body: main
    );
  }

  Widget playFab() {
    return ActionButton(
      icon: const Icon(Icons.play_arrow, color: Colors.white),
      onPressed: () async {
          if (widget.moves.isNotEmpty) {
            postRequest("/play/");
            if(fromPause){
              fromPause = false;
              await audioPlayer.resume();
            }else{
              await playAudio();
            }
          }
      },
    );
  }

  Widget stopFab() {
    return ActionButton(
      icon: const Icon(Icons.stop, color: Colors.white),
      onPressed: () async {
        getRequest("/stop/", "http://192.168.43.70");
        await audioPlayer.stop();
      },
    );
  }

  Future<void> getRequest(String function, String ip) async {
    String stringUrl = ip + function;
    Uri url = Uri.parse(stringUrl);
    await http.get(url);
  }

  Widget pauseFab() {
    return ActionButton(
      icon: const Icon(Icons.pause, color: Colors.white),
      onPressed: () async {
        fromPause = true;
        getRequest("/pause/", "http://192.168.43.70");
        await audioPlayer.pause();
      },
    );
  }

  Future<void> playAudio() async {
    audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.STOP);
    FirebaseStorage storage = FirebaseStorage.instance;
    await setUrl(widget.moveNumber, storage);
    await audioPlayer.resume();
  }

  Future<void> postRequest(String function) async {
    String stringUrl = "http://192.168.225.70" + function;
    Uri url = Uri.parse(stringUrl);
    Map<String, dynamic> args = {"move": widget.moveNumber};
    var body = json.encode(args);
    await http.post(url, body: body, headers: {'Content-type': 'application/json'});
  }

  DefaultTabController getTabs(context, int moveNumber) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: lightPink(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: lightPink(),
          toolbarHeight: 5,
          bottom: TabBar(
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
            labelColor: primaryOrange(),
            unselectedLabelColor: darkPink(),
            indicatorPadding: const EdgeInsets.all(5),
            indicator: BoxDecoration(
              border: Border.all(color: lightPink(), width: 3),
              borderRadius: BorderRadius.circular(10),
              color: lightPink(),
            ),
            tabs: [
              tabCreatorFromAssets("lib/assets/mouth.png", "MOUTH"),
              tabCreatorFromAssets("lib/assets/body.png", "BODY"),
              tabCreatorFromAssets("lib/assets/head.png", "HEAD"),
              tabCreator(Icons.music_note_rounded, "AUDIO")
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EditSensor(sensorData: sensorsData[0], sensorNumber: 1, moveNumber: widget.moveNumber,),
            EditSensor(sensorData: sensorsData[1], sensorNumber: 2, moveNumber: widget.moveNumber),
            EditSensor(sensorData: sensorsData[2], sensorNumber: 3, moveNumber: widget.moveNumber),
            EditAudio(moveNumber: moveNumber),
          ],
        ),
      ),
    );
  }

  Tab tabCreator(IconData icon, String text) {
    return Tab(icon: Icon(icon, size: 30), text: text);
  }

  Tab tabCreatorFromAssets(String image, String text) {
    return Tab(icon: ImageIcon(AssetImage(image), size: 30), text: text);
  }

  Future<void> setUrl(int moveNumber, storage) async {
    String fileName = "move" + moveNumber.toString() + '.aac';
    Reference ref = storage.ref().child(fileName);
    String url = await ref.getDownloadURL();
    audioPlayer.setUrl(url);
    await audioPlayer.resume();
  }
}



