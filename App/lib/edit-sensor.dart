import 'package:animatronics/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'external/line_chart.dart';
import 'firebase.dart';

class EditSensor extends StatefulWidget {
  List<String> sensorData;
  int sensorNumber;
  int moveNumber;
  EditSensor({Key? key, required this.sensorData, required this.sensorNumber,
  required this.moveNumber}) : super(key: key);

  @override
  _EditSensorState createState() => _EditSensorState();
}

class _EditSensorState extends State<EditSensor> {
  double anglePressed = 0;
  int angleIndexPressed = 0;
  List<Data> data = [];

  @override
  void initState(){
    double time = 0;
    for(int i= 0 ; i< widget.sensorData.length ; i ++){
      data.add(Data(time, double.parse(widget.sensorData[i])));
      //TODO: are we sure?
      time += 0.05;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: LineGraph(data: data, updateSelectedAngle: updateSelectedAngle),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SpinBox(
              //TODO: change to angles limits
              min: -100,
              max: 100,
              value: anglePressed,
              onChanged: (value) {
                double time = data[angleIndexPressed].second;
                data[angleIndexPressed] = Data(time, value);
                setState(() {
                });
              } ,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 110.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.save,
                  color: darkPink(),
                ),
                iconSize: 40,
                onPressed: () async {
                  await updateFileInFirebase();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> updateFileInFirebase() async{
    String path = "glove/move" + widget.moveNumber.toString() + "/data";
    String content = await readFileWithoutParse(path);
    String modifyContent = "";
    var parts = content.split(' ');
    parts.removeLast();

    //TODO: change to 3
    int row = 2;
    //TODO: change to 3
    int col = (parts.length / 2).round() ;
    var matrix = List.generate(row, (i) => List.filled(col, "", growable: false), growable: false);
    //TODO: change to 3
    for(int i = 0 ; i< parts.length; i+=2){
      matrix[i][0] = parts[i];
      matrix[i+1][1] = parts[i+1];
      //TODO: uncomment
     // matrix[i+2][2] = parts[i+2];

    }
  }


  void updateSelectedAngle(double angle, int index){
    anglePressed = angle;
    angleIndexPressed = index;
    setState(() {

    });
  }
}