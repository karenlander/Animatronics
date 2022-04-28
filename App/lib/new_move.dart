import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class newMoveWindow extends StatefulWidget {
  newMoveWindow({Key? key}) : super(key: key);

  @override
  _newMoveWindowState createState() => _newMoveWindowState();
}

class _newMoveWindowState extends State<newMoveWindow> {
  TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          newText(19, darkOrange(), "Create a move", true, true),
          const SizedBox(height: 20),
          TextFormField(
            controller: nameController,
            style: const TextStyle(
              color: Color(0xff001878),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              newTextButton("CANCEL", (){}),
              newTextButton("OK", (){}),
            ],
          ),

        ],
      ),
    );
  }
}
