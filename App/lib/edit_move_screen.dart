import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                children: [
                  newText(27, Colors.white, "Edit Move", false, true),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top:20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left:20),
                child: Row(
                 // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      child: Icon(
                          Icons.visibility_rounded,
                          color: lightPink()
                      ),
                      backgroundColor: darkPink(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineChartSample2(),
              )
            ],
          ),
        ));
  }
}



