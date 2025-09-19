import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:xinyutest/config/size_config.dart';
import 'package:xinyutest/Global/audiogramData.dart';

class paintAudiogram extends StatefulWidget {
  @override
  _paintAudiogramState createState() => _paintAudiogramState();
}

class _paintAudiogramState extends State<paintAudiogram> {
  List<Color> gradientColors = [
    Color.fromARGB(255, 187, 219, 255),
    Color.fromARGB(255, 33, 137, 255),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            height: SizeConfig.screenHeight * 0.5,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
                color: Color.fromARGB(255, 255, 255, 255)),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 75, left: 12.0, top: 26, bottom: 12),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 15,
            child: Text(
              '听阈/dB  HL',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none),
            ),
          ),
          Positioned(
              right: 0,
              bottom: 39,
              child: Text('频率/Hz',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none)))
        ],
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true, //网格显示
        drawVerticalLine: false,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) {
          if (value % 20 == 0) {
            return FlLine(
              color: Colors.black,
              strokeWidth: 1,
            );
          } else {
            return FlLine(color: Colors.white);
          }
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.black,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTextStyles: (context, value) => const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            getTitles: (value) {
              switch (value) {
                case 0:
                  return '125';
                case 1:
                  return '250';
                case 2:
                  return '500';

                case 3:
                  return '1k';

                case 4:
                  return '2k';

                case 5:
                  return '4k';

                case 6:
                  return '8k';
              }
              return '';
            },
            margin: 8,
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
            getTitles: (value) {
              if (value % 20 == 0) {
                return value.toInt().toString();
              } else {
                return '';
              }
            },
            reservedSize: 30,
            margin: 12,
          ),
          rightTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(showTitles: false)),
      borderData: FlBorderData(
          show: true,
          border: Border(
              left: BorderSide(color: const Color(0xff37434d), width: 1),
              bottom: BorderSide(color: const Color(0xff37434d), width: 1))),
      minX: 0,
      maxX: 6.2,
      minY: 0,
      maxY: 130,
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: (audioGram.isRightEar
              ? audioGram.rightEarData
              : audioGram.leftEarData)
          .map<FlSpot>((e) => FlSpot(e[0], e[1]))
          .toList(),
      isCurved: false,
      colors: gradientColors,
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
      ),
      belowBarData: BarAreaData(
        show: true,
        colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
      ),
    );
    return [lineChartBarData1];
  }
}
