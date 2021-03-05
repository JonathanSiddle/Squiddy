import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:squiddy/Theme/SquiddyTheme.dart';
import 'package:stats/stats.dart';

class OctoLineChart extends StatefulWidget {
  final Map<String, num> data;
  final bool isCurved;
  final showLeftAxis;
  final bool showBottomAxis;
  final double aspectRatio;
  final List<Color> gradientColours;
  final bool interactive;

  OctoLineChart(
      {@required this.data,
      @required this.aspectRatio,
      this.isCurved,
      this.showLeftAxis,
      this.showBottomAxis,
      this.gradientColours,
      this.interactive});

  @override
  _OctoLineChartState createState() => _OctoLineChartState();
}

class _OctoLineChartState extends State<OctoLineChart> {
  List<Color> gradientColors;
  //graph data stuff
  List<num> rawData;
  Stats<num> stats;
  List<num> normalisedData;
  List<FlSpot> graphData;
  List<String> graphBottomLabels;
  num maxY;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // * Graph calc stuff, should ensure only done once
    rawData = this.widget.data.values.toList();
    stats = Stats.fromData(rawData);
    normalisedData = normaliseData(data: rawData, rMin: 0, rMax: 10);
    graphData = getGraphSpots(normalisedData);
    maxY = stats.max;
    graphBottomLabels = this.widget.data.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    gradientColors = this.widget.gradientColours ??
        [
          SquiddyTheme.squiddySecondary[800],
          SquiddyTheme.squiddySecondary[400],
        ];

    return AspectRatio(
      // aspectRatio: 1.9,
      aspectRatio: widget.aspectRatio ?? 16 / 9,
      child: LineChart(
        displayData(rawData, graphData, graphBottomLabels, maxY),
      ),
    );
  }

  LineChartData displayData(
      List<num> rawData, List<FlSpot> graphData, List<String> days, num maxY) {
    return LineChartData(
      lineTouchData: LineTouchData(
          enabled: this.widget.interactive ?? true,
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                FlLine(color: SquiddyTheme.squiddyPrimary, strokeWidth: 4),
                FlDotData(
                  dotColor: SquiddyTheme.squiddyPrimary,
                  dotSize: 8,
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  var dataIndex = barSpot.spotIndex;

                  return LineTooltipItem(
                    '${rawData[dataIndex].toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              })),
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: this.widget.showBottomAxis ?? true,
        bottomTitles: SideTitles(
          showTitles: true,
          // reservedSize: 30,
          textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              fontSize: 12),
          rotateAngle: 45,
          getTitles: (value) {
            return days[value.toInt()];
          },
          // margin: 0,
        ),
        leftTitles: SideTitles(
          showTitles: this.widget.showLeftAxis ?? true,
          textStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            // color: Colors.tealAccent[800],
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            if (value.toInt() == 0) {
              return '0';
            } else if (value.toInt() == 10) {
              return maxY.round().toString() + '\nkWH';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: graphData.length.toDouble() - 1,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: graphData,
          preventCurveOverShooting: true,
          isCurved: this.widget.isCurved ?? false,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: this.widget.interactive ?? true,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  ///used to get the nearest big number for a value, for example,
  ///8 -> 10
  ///88 -> 100
  ///888 -> 1000
  num getMaxY(num value, bool scale) {
    var length = value.toInt().toString().length;
    var maxY = 0;
    switch (length) {
      case 1:
        maxY = 10;
        break;
      case 2:
        maxY = 100;
        break;
      case 3:
        maxY = 1000;
        break;
      case 4:
        maxY = 10000;
        break;
      case 5:
        maxY = 100000;
        break;
      case 6:
        maxY = 1000000;
        break;
      default:
        maxY = 1000;
        break;
    }

    if (scale) {
      maxY = maxY ~/ 2;
    }

    return maxY;
  }

  List<FlSpot> getGraphSpots(List<num> values) {
    List<FlSpot> returnData = [];

    int counter = 0;
    for (num v in values) {
      returnData
          .add(FlSpot(counter.toDouble(), num.parse(v.toStringAsFixed(2))));
      counter += 1;
    }

    return returnData;
  }

  List<num> getYValues(List<num> values) {
    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  }

  List<num> normaliseData(
      {@required List<num> data, @required int rMin, @required int rMax}) {
    List<num> inData = List<num>.from(data);
    var stats = Stats.fromData(data);
    var inMax = stats.max;
    var inMin = stats.min;
    var hasValGreaterThanTen = false;

    if (inData.length <= 1) return inData;
    hasValGreaterThanTen = inData.any((element) => element > 10);
    //this is just very rough scalling to cover an edge case, I think
    //this could probably be handled better in the long-term
    if (inMin == inMax) {
      print('min == max');
      while (hasValGreaterThanTen) {
        inData = inData.map((s) => s > 10 ? s / 10 : s).toList();
        hasValGreaterThanTen = inData.any((element) => element > 10);
        print('Got to the end of loop');
      }

      return inData;
    }

    return inData
        .map((d) => ((d - inMin) * (rMax - rMin) / (inMax - inMin)) + rMin)
        .toList();
  }
}
