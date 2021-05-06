import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Charts/octoLineChart.dart';
import 'package:squiddy/octopus/dataClasses/EnergyMonth.dart';
import 'package:squiddy/widgets/responsiveWidget.dart';

class MonthSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var eMonth = Provider.of<EnergyMonth>(context);
    var dailyData = eMonth.days;
    Map<String, num> data = {};
    dailyData.forEach((d) => data[d.date.day.toString()] = d.totalConsumption);

    return Container(
      // color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 60.0, 0, 0),
                child: ResponsiveWidget(
                  smallScreen: IntrinsicWidth(
                      child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minWidth: screenWidth - 70),
                          child:
                              OctoLineChart(aspectRatio: 14 / 9, data: data))),
                  largeScreen: IntrinsicWidth(
                      child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child:
                              OctoLineChart(aspectRatio: 14 / 9, data: data))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
