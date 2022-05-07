import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

import '../firebase.dart';

class SoundRecorder{
  FlutterSoundRecorder? _audioRecorder;
  bool isRecorderInitialized = false;

  bool get isRecording => _audioRecorder!.isRecording;
  late Function refresh;

  setRefresh(refresh){
    this.refresh = refresh;
  }

  Future init() async{
    _audioRecorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if(status != PermissionStatus.granted){
      throw RecordingPermissionException("Microphone permission denied");
    }
    await _audioRecorder!.openAudioSession();
    isRecorderInitialized = true;
  }

  void dispose(){
    if(!isRecorderInitialized){
      return;
    }
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    isRecorderInitialized = false;
  }

  Future _record() async{
    if(!isRecorderInitialized){
      return;
    }
    await _audioRecorder!.startRecorder(toFile: 'audio.aac');
  }

  Future _stop(int nextMove) async {
    if(!isRecorderInitialized){
      return;
    }
    String? url = await _audioRecorder!.stopRecorder();
    this.refresh();
    FirebaseStorage storage = FirebaseStorage.instance;
    String Filename = 'move' + nextMove.toString() + '.aac';
    Reference ref = storage.ref().child(Filename);
    final File file = File(url!);
    await ref.putFile(File(file.path));
    setNumOfMoves(nextMove);
  }

  Future toggleRecording(int nextMove) async{
    if(_audioRecorder!.isStopped){
      await _record();
    }else{
      await _stop(nextMove);
    }
  }
}
