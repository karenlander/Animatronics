import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'firebase.dart';

SnackBar get SoundDelaySaved =>
    const SnackBar(content: Text('Sound delay updated'));
SnackBar get MoveDelaySaved =>
    const SnackBar(content: Text('Move delay updated'));


class SetDelay extends StatefulWidget {
  int moveNumber;
  SetDelay({Key? key, required this.moveNumber}) : super(key: key);

  @override
  State<SetDelay> createState() => _SetDelayState();
}

class _SetDelayState extends State<SetDelay> {
  TextEditingController delayMoveController = TextEditingController();
  TextEditingController delaySoundController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink(),
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: primaryOrange(),
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Column(
              children: [
                newText(27, Colors.white, "Set delay", false, true),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top:8),
                child: RichText(
                    text: TextSpan(
                        text: 'Enter delay for the moves',
                        style: TextStyle(
                          color: primaryOrange(),
                          fontSize: 20,
                        ))),
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextFormField(
                        cursorColor: darkOrange(),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:darkOrange()),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkOrange()),
                          ),
                        ),
                        controller: delayMoveController,
                      ),
                    )),
                IconButton(
                  icon: Icon(Icons.save,
                    color: darkPink(),
                  ),
                  iconSize: 30,
                  onPressed: ()  {
                    setDelay(delayMoveController.text, "Move", widget.moveNumber);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(MoveDelaySaved);
                  },
                ),
              ],
            ),
            SizedBox(height:20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top:8),
                child: RichText(
                    text: TextSpan(
                        text: 'Enter delay for the sound',
                        style: TextStyle(
                          color: primaryOrange(),
                          fontSize: 20,
                        ))),
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:darkOrange()),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkOrange()),
                          ),
                        ),
                        cursorColor: darkOrange(),
                        controller: delaySoundController,
                      ),
                    )),
                IconButton(
                  icon: Icon(Icons.save,
                    color: darkPink(),
                  ),
                  iconSize: 30,
                  onPressed: () async {
                    setDelay(delaySoundController.text, "Sound", widget.moveNumber);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SoundDelaySaved);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
