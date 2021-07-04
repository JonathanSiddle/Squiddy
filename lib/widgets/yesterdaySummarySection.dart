import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Charts/octoLineChart.dart';
import 'package:squiddy/Theme/SquiddyTheme.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/dataClasses/EnergyDay.dart';

class YesterdaySummarySection extends StatelessWidget {
  final double graphWidth;

  const YesterdaySummarySection({Key key, this.graphWidth = 650})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lastDay = Provider.of<OctopusManager>(context).lastDayReading;

    return lastDay == null
        ? Center(
            child: Text('Getting Data'),
          )
        : getWidget(lastDay, width: graphWidth);
  }

  Widget getWidget(EnergyDay lastDay,
      {double width = 650, double ratio = 20 / 9}) {
    final headingDateFormat = DateFormat('MMM-dd');
    return Container(
      width: width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${headingDateFormat.format(lastDay.date)}',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: OctoLineChart(
              data: lastDay.getConsumptionByHour(),
              aspectRatio: 20 / 9,
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
