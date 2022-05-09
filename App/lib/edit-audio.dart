import 'package:animatronics/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'external/audio-recorder.dart';

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
  final recorder = SoundRecorder();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  void initState() {
    setAudio();
    recorder.init();
    recorder.setRefresh(refresh);
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.STOP);

    FirebaseStorage storage = FirebaseStorage.instance;
    String fileName = "move" + widget.moveNumber.toString() + '.aac';
    Reference ref = storage.ref().child(fileName);
    String url = await ref.getDownloadURL();
    audioPlayer.setUrl(url);
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

  void dispose() {
    audioPlayer.dispose();
    recorder.dispose();
    _stopWatchTimer.dispose();
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
    bool isRecording = recorder.isRecording;
    final icon = isRecording ? Icons.stop : Icons.play_arrow;

    String sDuration = _printDuration(duration);
    String sPosition = _printDuration(position);

    return Padding(
      padding: const EdgeInsets.only(top: 45.0),
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
          ),
          Padding(
            padding: const EdgeInsets.only(top:38.0),
            child: textAndIcon(icon, playAndStop,"Record new audio"),
          ),
          Padding(
            padding: const EdgeInsets.only(left :55.0),
            child: countdown(_stopWatchTimer, Alignment.centerLeft),
          ),
        ],
      ),
    );
  }

  void playAndStop() async {
    final isRecording = await recorder.toggleRecording(widget.moveNumber, true);
    setState(() {});
    if(recorder.isRecording){
      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    }else{
      setAudio();
      setState(() {});
    }
  }

  void refresh() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    setState(() {
    });
  }
}
