import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:squiddy/Charts/overviewSummary.dart';
import 'package:squiddy/Theme/SquiddyTheme.dart';
import 'package:squiddy/Util/SlideRoute.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/routes/monthDaysPage.dart';
import 'package:squiddy/routes/settingPage.dart';

import '../monthDisplayCard.dart';

class MonthsOverview extends StatefulWidget {
  MonthsOverview();

  @override
  _MonthsOverviewState createState() => _MonthsOverviewState();
}

class _MonthsOverviewState extends State<MonthsOverview> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  SettingsManager settings;
  OctopusManager octoManager;
  final urlDate = DateFormat('yyyy/MM');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    settings = Provider.of<SettingsManager>(context);
    octoManager = Provider.of<OctopusManager>(context);
  }

  void _onRefresh() async {
    if (octoManager != null && settings != null) {
      await octoManager.initData(
          apiKey: settings.apiKey,
          accountId: settings.accountId,
          meterPoint: settings.meterPoint,
          meter: settings.meter);
    }

    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    var months = Provider.of<List<EnergyMonth>>(context);

    //always ensure the oldest card is secondary colour
    var cardIsPink = false;
    var cardColors = months.reversed
        .toList()
        .map((m) {
          if (cardIsPink) {
            cardIsPink = !cardIsPink;
            return SquiddyTheme.squiddyPrimary;
          } else {
            cardIsPink = !cardIsPink;
            return SquiddyTheme.squiddySecondary;
          }
        })
        .toList()
        .reversed
        .toList();

    return months == null && !octoManager.errorGettingData
        ? Center(child: CircularProgressIndicator())
        : months.length == 0 || octoManager.errorGettingData
            ? Column(
              children: [
                Text("Uh oh, doesn't look like you have any readings")
              ],
            )
            : SafeArea(
                child: SmartRefresher(
                  enablePullDown: true,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'Overview',
                                      style: TextStyle(fontSize: 48),
                                    ),
                                    Expanded(child: Container()),
                                    IconButton(
                                        icon: Icon(
                                          FontAwesomeIcons.cog,
                                          size: 36,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              SlideTopRoute(
                                                  page: SettingsPage(),
                                                  name: 'settings'));
                                        }),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: OverviewSummary(),
                              ),
                            ],
                          ),
                        ]),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          var cMonth = months[index];
                          var displayFormat = DateFormat.yMMM();

                          var urlMonth = urlDate.format(cMonth.begin);
                          var monthDays = cMonth.days;

                          Map<String, num> data = {};
                          monthDays.forEach((d) =>
                              data[d.date.day.toString()] = d.totalConsumption);
                          return SquiddyCard(
                            graphData: data,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  SlideLeftRoute(
                                      name: '/monthDays/$urlMonth',
                                      page: Provider(
                                          create: (_) => cMonth,
                                          child: MonthDaysPage())));
                            },
                            color: cardColors[index],
                            inkColor:
                                cardColors[index] == SquiddyTheme.squiddyPrimary
                                    ? SquiddyTheme.squiddyPrimary[300]
                                    : SquiddyTheme.squiddySecondary[300],
                            title: displayFormat.format(cMonth.begin),
                            total:
                                '${cMonth.totalConsumption.toStringAsFixed(2)}kWh',
                          );
                        }, childCount: months.length),
                      )
                    ],
                  ),
                ),
              );
  }
}
