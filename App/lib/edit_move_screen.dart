import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'edit-audio.dart';
import 'edit-sensor.dart';

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



