import 'package:animatronics/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'external/line_chart_sample2.dart';

class EditMove extends StatefulWidget {
  int moveNumber;
  EditMove({Key? key, required this.moveNumber}) : super(key: key);

  @override
  _EditMoveState createState() => _EditMoveState();
}

class _EditMoveState extends State<EditMove> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: lightPink(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: primaryOrange(),
            elevation: 0,
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                children: [
                  newText(27, Colors.white, "Edit Move", false, true),
                ],
              ),
            ),
          ),
        ),
        body: getTabs(context, widget.moveNumber));
  }
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
            tabCreatorFromAssets("lib/head.png", "HEAD"),
            tabCreatorFromAssets("lib/mouth.png", "MOUTH"),
            tabCreatorFromAssets("lib/body.png", "BODY"),
            tabCreator(Icons.music_note_rounded, "AUDIO")
          ],
        ),
      ),
      body: TabBarView(
        children: [
          EditSensor(),
          EditSensor(),
          EditSensor(),
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

class EditSensor extends StatefulWidget {
  const EditSensor({Key? key}) : super(key: key);

  @override
  _EditSensorState createState() => _EditSensorState();
}

class _EditSensorState extends State<EditSensor> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LineChartSample2(),
          ),
        ],
      ),
    );
  }
}

class EditAudio extends StatefulWidget {
  int moveNumber;
  EditAudio({Key? key, required this.moveNumber}) : super(key: key);

  @override
  _EditAudioState createState() => _EditAudioState();
}

class _EditAudioState extends State<EditAudio> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  void initState() {
    setAudio();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.STOP);

    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = "move" + widget.moveNumber.toString() + '.aac';
    Reference ref = storage.ref().child(fileName);
    String url = await ref.getDownloadURL();
    audioPlayer.setUrl(url);
  }

  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    String sDuration = _printDuration(duration);
    String sPosition = _printDuration(position);

    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Column(
        children: [
          Slider(
            activeColor:lightOrange(),
            inactiveColor: primaryPink(),
            min: 0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: (value) async {
              final position = Duration(seconds: value.toInt());
              await audioPlayer.seek(position);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sPosition,
                  style: TextStyle(
                      color: darkOrange(), fontFamily: 'Poppins', fontSize: 16),
                ),
                Text(
                  sDuration,
                  style: TextStyle(
                      color: darkOrange(), fontFamily: 'Poppins', fontSize: 16),
                ),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: lightOrange(),
            radius: 35,
            child: IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                color: lightPink(),
              ),
              iconSize: 50,
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer.pause();
                } else {
                  await audioPlayer.resume();
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
