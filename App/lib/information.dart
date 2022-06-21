import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Information extends StatefulWidget {
  const Information({Key? key}) : super(key: key);

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: primaryOrange(),
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Column(
              children: [
                newText(27, Colors.white, "About animatronics", false, true),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
            text: TextSpan(
                text: 'An educational, open source, development kit that combines robotics and movement capture. \n\n'
                    'The system is built upon three main components:\n\n'
                    '• A Puppet which “plays” the recorded movements and sound.\n'
                    '• A Glove which enables to “record” the wearers movements.\n'
                    '• An App which supplies the user with a graphic interface to view and edit the recorded movements and sounds.',
                style: TextStyle(
                    color: primaryOrange(),
                    fontSize: 20,
                    ))),
      ),
    );
  }
}