import 'package:flutter/cupertino.dart';

import 'external/line_chart_sample2.dart';

class EditSensor extends StatefulWidget {
  const EditSensor({Key? key}) : super(key: key);

  @override
  _EditSensorState createState() => _EditSensorState();
}

class _EditSensorState extends State<EditSensor> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
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