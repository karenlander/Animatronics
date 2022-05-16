import 'package:animatronics/utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineGraph extends StatefulWidget {
  Function updateSelectedAngle;
  List<Data> data;
  LineGraph({Key? key, required this.data, required this.updateSelectedAngle}) : super(key: key);

  @override
  _LineGraphState createState() => _LineGraphState();
}

class _LineGraphState extends State<LineGraph> {
  @override
  Widget build(BuildContext context) {
    return  Column(children: [
      SfCartesianChart(
          primaryXAxis: NumericAxis( title: AxisTitle(
            alignment: ChartAlignment.far,
              text: 'Time (seconds)',
              textStyle:TextStyle(
                  color: Colors.grey, fontFamily: 'Poppins', fontSize: 11)
          )),
          primaryYAxis: NumericAxis( title: AxisTitle(
              alignment: ChartAlignment.center,
              text: 'Angle (degrees)',
              textStyle:TextStyle(
                  color: Colors.grey, fontFamily: 'Poppins', fontSize: 11)
          )),
          title: ChartTitle(text: 'Motor angle as a function of time',
              textStyle: TextStyle(
              color: Colors.grey, fontFamily: 'Poppins', fontSize: 14)),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<Data, double>>[
            LineSeries<Data, double>(
                color: lightOrange(),
                dataSource: widget.data,
                xValueMapper: (Data data, _) => data.second,
                yValueMapper: (Data data, _) => data.angle,
                xAxisName: "Time(seconds)",
                name : 'Time:Angle',
                width: 3,
                onPointTap: (ChartPointDetails details){
                  int? pressedIndex = details.pointIndex;
                  widget.updateSelectedAngle(widget.data[pressedIndex!].angle, pressedIndex);
                }
            )
          ]),
    ]);
  }
}

class Data {
  Data(this.second, this.angle);

  final double second;
  final double angle;
}



