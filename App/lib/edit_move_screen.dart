import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'line_chart_sample2.dart';

class EditMove extends StatefulWidget {
  const EditMove({Key? key}) : super(key: key);

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
        body: getTabs(context));
  }
}

DefaultTabController getTabs(context) {
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
      body: const TabBarView(
        children: [
          EditSensor(),
          EditSensor(),
          EditSensor(),
          EditAudio(),
        ],
      ),
    ),
  );
}

Tab tabCreator(IconData icon, String text) {
  return Tab(icon: Icon(icon, size: 30), text: text);
}

Tab tabCreatorFromAssets(String image, String text) {
  return Tab(icon: ImageIcon(
      AssetImage(image),
      size:30
  ), text: text);
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
      padding: const EdgeInsets.only(top:20),
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
  const EditAudio({Key? key}) : super(key: key);

  @override
  _EditAudioState createState() => _EditAudioState();
}

class _EditAudioState extends State<EditAudio> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}





