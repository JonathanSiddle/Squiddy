import 'dart:math';

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
  List<Color> colors = [
    Colors.orange.shade300,
    Colors.orange.shade500,
    Colors.green.shade300,
    Colors.green.shade500,
    Colors.red.shade300,
    Colors.red.shade500
  ];
  final urlDate = DateFormat('yyyy/MM');
  final rnd = Random();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    settings = Provider.of<SettingsManager>(context);
    octoManager = Provider.of<OctopusManager>(context);
  }

  void _onRefresh() async {
    await refreshData();

    _refreshController.refreshCompleted();
  }

  refreshData() async {
    if (octoManager != null && settings != null) {
      await octoManager.initData(
          apiKey: settings.apiKey,
          accountId: settings.accountId,
          meterPoint: settings.meterPoint,
          meter: settings.meter);
    }
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
        : months.length == 0 && octoManager.timeoutError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Icon(
                      FontAwesomeIcons.sadTear,
                      size: 55,
                      color: SquiddyTheme.squiddyPrimary,
                    ),
                  ),
                  Center(
                      child: Text(
                          "uh oh, taking readings was taking an unexpectedly long time.")),
                  Text(
                      'If the problem continues, try loging out and logging back in'),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: RaisedButton(
                        child: Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: SquiddyTheme.squiddySecondary,
                        onPressed: () async {
                          setState(() {
                            octoManager.retryLogin();
                          });
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: RaisedButton(
                        child: Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.red,
                        onPressed: () async {
                          await settings.cleanSettings();
                        }),
                  )
                ],
              )
            : months.length == 0 || octoManager.errorGettingData
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Text(
                              "Uh oh, doesn't look like you have any readings")),
                      Text(''),
                      Text(
                        "If you think you should have readings ",
                      ),
                      Text('try logging out and logging back in'),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: RaisedButton(
                            child: Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.red,
                            onPressed: () async {
                              await settings.cleanSettings();
                            }),
                      )
                    ],
                  )
                //Main area section if all goes well...
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
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 5),
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
                                    padding: const EdgeInsets.fromLTRB(
                                        10.0, 0, 10, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Current Prices',
                                          style: TextStyle(fontSize: 24),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 0),
                                          child: Icon(
                                              FontAwesomeIcons.questionCircle),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ]),
                          ),
                          //What will become the new agile price section
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                              child: Container(
                                height: 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 20,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: 100,
                                        child: Card(
                                            color: colors[rnd.nextInt(5)],
                                            elevation: 0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${rnd.nextInt(24)}:00',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                    '${rnd.nextInt(34)}.${rnd.nextInt(100)}p'),
                                              ],
                                            )),
                                      );
                                    }),
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate([
                              Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: OverviewSummary(),
                                  ),
                                ],
                              ),
                            ]),
                          ),
                          // SliverList(
                          //     delegate: SliverChildBuilderDelegate(
                          //         (context, index) {},
                          //         childCount: 20)),
                          SliverList(
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                              var cMonth = months[index];
                              var displayFormat = DateFormat.yMMM();

                              var urlMonth = urlDate.format(cMonth.begin);
                              var monthDays = cMonth.days;

                              Map<String, num> data = {};
                              monthDays.forEach((d) =>
                                  data[d.date.day.toString()] =
                                      d.totalConsumption);
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
                                inkColor: cardColors[index] ==
                                        SquiddyTheme.squiddyPrimary
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
