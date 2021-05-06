import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Charts/monthSummary.dart';
import 'package:squiddy/Theme/SquiddyTheme.dart';
import 'package:squiddy/octopus/dataClasses/EnergyDay.dart';
import 'package:squiddy/octopus/dataClasses/EnergyMonth.dart';
import 'package:squiddy/widgets/SquiddyCard.dart';
import 'package:squiddy/widgets/responsiveWidget.dart';

class MonthDaysPage extends StatelessWidget {
  final headingDateFormat = DateFormat('MMM yyyy');
  final displayFormat = DateFormat('EEE, dd');
  MonthDaysPage();

  @override
  Widget build(BuildContext context) {
    var eMonth = Provider.of<EnergyMonth>(context);
    var dailyConsumptions = eMonth.days.reversed.toList();

    return Scaffold(
      // appBar:
      //     AppBar(title: Text('${headingDateFormat.format(eMonth.begin)}')),
      body: dailyConsumptions == null
          ? Center(child: CircularProgressIndicator())
          : ResponsiveWidget(
              smallScreen: getSmallScreenView(eMonth, dailyConsumptions),
              mediumScreen:
                  getLargeScreenView(eMonth, dailyConsumptions, gridSize: 2),
              largeScreen:
                  getLargeScreenView(eMonth, dailyConsumptions, gridSize: 3),
              exLargeScreen:
                  getLargeScreenView(eMonth, dailyConsumptions, gridSize: 4),
            ),
    );
  }

  Widget getSmallScreenView(
      EnergyMonth eMonth, List<EnergyDay> dailyConsumptions) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        pinned: true,
        elevation: 10.0,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text('${headingDateFormat.format(eMonth.begin)}'),
        ),
      ),
      SliverList(
        delegate: SliverChildListDelegate([
          Column(
            children: <Widget>[
              MonthSummary(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          'Total',
                          style: TextStyle(fontSize: 36),
                        ),
                        Text(
                          '${eMonth.totalConsumption.toStringAsFixed(2)}kWh',
                          style: TextStyle(
                              fontSize: 36, color: Colors.blueGrey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        ]),
      ),
      SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
        Map<String, num> graphData;
        var cDay = dailyConsumptions[index];
        if (cDay.validreading) {
          graphData = cDay.getConsumptionByHour();
        }

        return SquiddyCard(
          graphData: graphData,
          graphColours: [
            SquiddyTheme.squiddyPrimary,
            SquiddyTheme.squiddyPrimary
          ],
          ratio: 16 / 5,
          graphPadding: const EdgeInsets.fromLTRB(30.0, 20, 30, 0),
          graphInteractive: true,
          graphShowLeftAxis: false,
          graphShowBottomAxis: true,
          // onTap: () => print('Tapped Card'),
          title: '${displayFormat.format(cDay.date)}',
          total: cDay.validreading
              ? '${cDay.totalConsumption.toStringAsFixed(2)}kWh'
              : '',
        );
      }, childCount: dailyConsumptions.length))
    ]);
  }

  Widget getLargeScreenView(
      EnergyMonth eMonth, List<EnergyDay> dailyConsumptions,
      {int gridSize = 2}) {
    return CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        pinned: true,
        elevation: 10.0,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text('${headingDateFormat.format(eMonth.begin)}'),
        ),
      ),
      SliverList(
        delegate: SliverChildListDelegate([
          Column(
            children: <Widget>[
              MonthSummary(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          'Total',
                          style: TextStyle(fontSize: 36),
                        ),
                        Text(
                          '${eMonth.totalConsumption.toStringAsFixed(2)}kWh',
                          style: TextStyle(
                              fontSize: 36, color: Colors.blueGrey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        ]),
      ),
      SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize, childAspectRatio: 16 / 9),
          delegate: SliverChildBuilderDelegate((context, index) {
            Map<String, num> graphData;
            var cDay = dailyConsumptions[index];
            if (cDay.validreading) {
              graphData = cDay.getConsumptionByHour();
            }

            return SquiddyCard(
              graphData: graphData,
              graphColours: [
                SquiddyTheme.squiddyPrimary,
                SquiddyTheme.squiddyPrimary
              ],
              ratio: 16 / 5,
              graphPadding: const EdgeInsets.fromLTRB(30.0, 20, 30, 0),
              graphInteractive: true,
              graphShowLeftAxis: false,
              graphShowBottomAxis: true,
              // onTap: () => print('Tapped Card'),
              title: '${displayFormat.format(cDay.date)}',
              total: cDay.validreading
                  ? '${cDay.totalConsumption.toStringAsFixed(2)}kWh'
                  : '',
            );
          }, childCount: dailyConsumptions.length))
    ]);
  }
}
