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
      body: Center(
          child: RichText(
              text: TextSpan(
                  text: 'Bla bla bla',
                  style: TextStyle(
                      color: primaryOrange(),
                      fontSize: 30,
                      )))
      ),
    );
  }
}