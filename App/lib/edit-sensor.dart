import 'package:flutter/cupertino.dart';
import 'package:flutter_spinbox/material.dart';
import 'external/line_chart.dart';

class EditSensor extends StatefulWidget {
  List<String> sensorData;
  EditSensor({Key? key, required this.sensorData}) : super(key: key);

  @override
  _EditSensorState createState() => _EditSensorState();
}

class _EditSensorState extends State<EditSensor> {
  double anglePressed = 0;
  int angleIndexPressed = 0;
  late List<Data> data ;

  @override
  void initState(){
    data = [
      Data(0, 35),
      Data(1, 37),
      Data(2, 39),
      Data(4, 42),
      Data(13, 40),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: LineGraph(data: data, updateSelectedAngle: updateSelectedAngle),

            ),
          ),
          SpinBox(
            //TODO: change to angles limits
            min: 1,
            max: 100,
            value: anglePressed,
            onChanged: (value) {
              double time = data[angleIndexPressed].second;
              data[angleIndexPressed] = Data(time, value);
              setState(() {

              });
            } ,
          )
        ],
      ),
    );
  }

  void updateSelectedAngle(double angle, int index){
    anglePressed = angle;
    angleIndexPressed = index;
    setState(() {

    });
  }
}