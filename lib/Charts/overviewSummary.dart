import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Charts/octoLineChart.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';

class OverviewSummary extends StatelessWidget {
  final format = DateFormat('MMM');

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // print('ScreenWidth: $screenWidth');

    var months = Provider.of<List<EnergyMonth>>(context);
    List<EnergyMonth> rawData;
    if (months.length >= 6) {
      rawData = months.sublist(0, 6).reversed.toList();
    } else {
      rawData = months.reversed.toList();
    }

    Map<String, num> data = {};
    rawData.forEach((m) => data[format.format(m.begin)] =
        num.parse(m.totalConsumption.toStringAsFixed(2)));

    //Last six months
    num recentConsumption;
    if (months.length > 6) {
      recentConsumption = months
          .sublist(0, 6)
          .reversed
          .toList()
          .fold(0, (prev, el) => prev + el.totalConsumption);
    } else {
      recentConsumption =
          months.fold(0, (prev, el) => prev + el.totalConsumption);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // SizedBox(height: 600, width: 400, child: BarChartSample2()),
            IntrinsicWidth(
                child: ConstrainedBox(
                    //this should be screen width
                    constraints: BoxConstraints(minWidth: screenWidth - 70),
                    child: OctoLineChart(
                      aspectRatio: 16 / 9,
                      data: data,
                      isCurved: false,
                    ))),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        'Last Six Months',
                        style: TextStyle(fontSize: 36),
                      ),
                      Text(
                        '${recentConsumption.toStringAsFixed(2)}kWh',
                        style: TextStyle(
                            fontSize: 36, color: Colors.blueGrey[400]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
