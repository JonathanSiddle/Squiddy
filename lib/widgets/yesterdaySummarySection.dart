import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Charts/octoLineChart.dart';
import 'package:squiddy/Theme/SquiddyTheme.dart';
import 'package:squiddy/octopus/OctopusManager.dart';

class YesterdaySummarySection extends StatelessWidget {
  const YesterdaySummarySection({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headingDateFormat = DateFormat('MMM-dd');
    var lastDay = Provider.of<OctopusManager>(context).lastDayReading;

    return lastDay == null
        ? Center(
            child: Text('Getting Data'),
          )
        : Container(
            height: 250,
            child: Column(
              children: [
                Text('${headingDateFormat.format(lastDay.date)}'),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: OctoLineChart(
                    data: lastDay.getConsumptionByHour(),
                    aspectRatio: 16 / 9,
                    interactive: true,
                    showLeftAxis: true,
                    showBottomAxis: true,
                    isCurved: true,
                    gradientColours: [
                      SquiddyTheme.squiddyPrimary,
                      SquiddyTheme.squiddyPrimary
                    ],
                  ),
                )
              ],
            ),
          );
  }
}
