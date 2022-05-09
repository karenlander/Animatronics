import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

Color primaryOrange(){
  return Color(0xffff7043);
}

Color lightOrange(){
  return Color(0xffffa270);
}

Color darkOrange(){
  return Color(0xffc63f17);
}

Color primaryPink(){
  return Color(0xffffccbc);
  //return Color(0xff24ffd3);
}

Color darkPink(){
  return Color(0xffcb9b8c);
}

Color lightPink(){
  return Color(0xffffffee);
}

Widget newIcon(IconData icon, double size, onPressedFunction, Color c){
  return IconButton(
    visualDensity: VisualDensity(horizontal: -2.0, vertical: -2.0),
    padding: EdgeInsets.zero,
    icon: Icon(
      icon,
      size: size,
      color: c,
    ),
    onPressed: onPressedFunction,
  );
}

Widget newText(double size, Color c, String text, bool isBold, bool alignCenter){
  FontWeight f = FontWeight.normal;
  if(isBold){
    f= FontWeight.bold;
  }
  TextAlign t = TextAlign.left;
  if(alignCenter){
    t = TextAlign.center;
  }
  return Text(
    text,
    textAlign:  t,
    style: TextStyle(color: Colors.white,
        fontFamily: 'Poppins',
        fontSize: size,
        fontWeight: f),
  );
}

Widget newButton(text, onPressedFunction){
  return Material(
    elevation: 5.0,
    borderRadius: BorderRadius.circular(30.0),
    color: lightOrange(),
    child: MaterialButton(
      minWidth: 300.0,
      height: 50.0,
      onPressed: onPressedFunction,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w800),
          ),
          SizedBox(width: 10,),
          Icon(
            Icons.arrow_forward,
            color: Colors.white,
          )
        ],
      ),
    ),
  );
}

Widget animatronicsTittle(String text, Color c, double fontSize){
  return Text(
    text,
    style: TextStyle(
        color: c,
        fontSize: fontSize,
        fontFamily: "Pacifico"),
  );
}

Widget newTextButton (String text, onPressedFunction){
  return TextButton(
    style: TextButton.styleFrom(
      primary: Color(0xff6200EE),
    ),
    onPressed: onPressedFunction,
    child: Text(text),
  );
}

Widget greyText(String text){
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: TextStyle(
          color: Colors.grey, fontFamily: 'Poppins', fontSize: 16),
    ),
  );
}

Widget textAndIcon(icon,onPressedFunction,text){
  return  Row(
    children: [
      newIcon(icon, 30, onPressedFunction, primaryPink()),
      greyText(text)
    ],
  );
}

Widget countdown(_stopWatchTimer, alignment) {
  return Align(
    alignment: alignment,
    child: TextButton(
        style: TextButton.styleFrom(
          primary: darkOrange(),
        ),
        onPressed: () {},
        child: StreamBuilder<int>(
            stream: _stopWatchTimer.rawTime,
            initialData: 0,
            builder: (context, snapshot) {
              final value = snapshot.data;
              final displayTime = StopWatchTimer.getDisplayTime(value!);
              return Text(displayTime,
                style: TextStyle(
                    color: darkOrange(), fontFamily: 'Poppins', fontSize: 15),
              );
            }
        )),
  );
}
