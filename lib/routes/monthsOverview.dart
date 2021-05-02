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
import 'package:squiddy/widgets/agilePriceList.dart';
import 'package:squiddy/widgets/responsiveWidget.dart';

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
  final timeFormat = DateFormat('HH:mm');

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
          meter: settings.meter,
          updateAccountSettings: (EnergyAccount ea) {
            if (settings.showAgilePrices) {
              if (settings.selectedAgileRegion != null &&
                  settings.selectedAgileRegion != '' &&
                  settings.selectedAgileRegion != 'AT') {
                settings.activeAgileTariff =
                    'E-1R-AGILE-18-02-21${settings.selectedAgileRegion}';
              } else if (ea.hasActiveAgileAccount()) {
                settings.showAgilePrices = true;
                settings.activeAgileTariff = ea.getAgileTariffCode();
                settings.selectedAgileRegion = 'AT';
              }
            } else {
              settings.activeAgileTariff = '';
              settings.selectedAgileRegion = '';
            }
          });
    }
  }

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    var months = Provider.of<List<EnergyMonth>>(context);
    print('months length: ${months.length}');
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
                    "uh oh, taking readings was taking an unexpectedly long time.",
                    softWrap: true,
                  )),
                  Text(
                    'If the problem continues, try loging out and logging back in',
                    softWrap: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                        child: Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                SquiddyTheme.squiddySecondary)),
                        onPressed: () async {
                          setState(() {
                            octoManager.retryLogin();
                          });
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                        child: Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red)),
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
                        child: ElevatedButton(
                            child: Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red)),
                            onPressed: () async {
                              await settings.cleanSettings();
                            }),
                      )
                    ],
                  )
                /**********************
                 *Main area section if all goes well...
                ***********************/
                : ResponsiveWidget(
                    smallScreen: getSmallScreenView(months, cardColors),
                    mediumScreen:
                        getLargeScreenView(months, cardColors, gridSize: 2),
                    largeScreen:
                        getLargeScreenView(months, cardColors, gridSize: 3),
                    exLargeScreen:
                        getLargeScreenView(months, cardColors, gridSize: 4),
                  );
  }

  Widget getLargeScreenView(
      List<EnergyMonth> months, List<MaterialAccentColor> cardColors,
      {int gridSize = 2}) {
    return SafeArea(
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
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
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
                  ],
                ),
              ]),
            ),
            /********************
                           * Agile price section
                           *******************/
            //What will become the new agile price section
            settings.showAgilePrices
                ? SliverToBoxAdapter(
                    child: AgilePriceList(),
                  )
                : SliverToBoxAdapter(
                    child: Container(
                      height: 10,
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
            // ResponsiveWidget(
            //   smallScreen: SliverList(
            //     delegate:
            //         SliverChildBuilderDelegate((context, index) {
            //       var cMonth = months[index];
            //       var displayFormat = DateFormat.yMMM();

            //       var urlMonth = urlDate.format(cMonth.begin);
            //       var monthDays = cMonth.days;

            //       Map<String, num> data = {};
            //       monthDays.forEach((d) =>
            //           data[d.date.day.toString()] =
            //               d.totalConsumption);
            //       return SquiddyCard(
            //         graphData: data,
            //         onTap: () {
            //           Navigator.push(
            //               context,
            //               SlideLeftRoute(
            //                   name: '/monthDays/$urlMonth',
            //                   page: Provider(
            //                       create: (_) => cMonth,
            //                       child: MonthDaysPage())));
            //         },
            //         color: cardColors[index],
            //         inkColor: cardColors[index] ==
            //                 SquiddyTheme.squiddyPrimary
            //             ? SquiddyTheme.squiddyPrimary[300]
            //             : SquiddyTheme.squiddySecondary[300],
            //         title: displayFormat.format(cMonth.begin),
            //         total:
            //             '${cMonth.totalConsumption.toStringAsFixed(2)}kWh',
            //       );
            //     }, childCount: months.length),
            //   ),
            //   // largeScreen: SliverGrid(
            //   //     delegate: SliverChildBuilderDelegate(
            //   //         (context, index) {
            //   //       var cMonth = months[index];
            //   //       var displayFormat = DateFormat.yMMM();

            //   //       var urlMonth = urlDate.format(cMonth.begin);
            //   //       var monthDays = cMonth.days;

            //   //       Map<String, num> data = {};
            //   //       monthDays.forEach((d) =>
            //   //           data[d.date.day.toString()] =
            //   //               d.totalConsumption);
            //   //       return Container(
            //   //           constraints: BoxConstraints(
            //   //               maxWidth: 200, maxHeight: 200),
            //   //           child: SquiddyCard(
            //   //             graphData: data,
            //   //             onTap: () {
            //   //               Navigator.push(
            //   //                   context,
            //   //                   SlideLeftRoute(
            //   //                       name: '/monthDays/$urlMonth',
            //   //                       page: Provider(
            //   //                           create: (_) => cMonth,
            //   //                           child: MonthDaysPage())));
            //   //             },
            //   //             color: cardColors[index],
            //   //             inkColor: cardColors[index] ==
            //   //                     SquiddyTheme.squiddyPrimary
            //   //                 ? SquiddyTheme.squiddyPrimary[300]
            //   //                 : SquiddyTheme
            //   //                     .squiddySecondary[300],
            //   //             title:
            //   //                 displayFormat.format(cMonth.begin),
            //   //             total:
            //   //                 '${cMonth.totalConsumption.toStringAsFixed(2)}kWh',
            //   //           ));
            //   //     }, childCount: months.length),
            //   //     gridDelegate:
            //   //         SliverGridDelegateWithFixedCrossAxisCount(
            //   //             crossAxisCount: 2)),
            // ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize, childAspectRatio: 21 / 8),
              delegate: SliverChildBuilderDelegate((context, index) {
                var cMonth = months[index];
                var displayFormat = DateFormat.yMMM();

                var urlMonth = urlDate.format(cMonth.begin);
                var monthDays = cMonth.days;

                Map<String, num> data = {};
                monthDays.forEach(
                    (d) => data[d.date.day.toString()] = d.totalConsumption);
                return IntrinsicHeight(
                  child: Container(
                    child: SquiddyCard(
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
                      inkColor: cardColors[index] == SquiddyTheme.squiddyPrimary
                          ? SquiddyTheme.squiddyPrimary[300]
                          : SquiddyTheme.squiddySecondary[300],
                      title: displayFormat.format(cMonth.begin),
                      total: '${cMonth.totalConsumption.toStringAsFixed(2)}kWh',
                    ),
                  ),
                );
              }, childCount: months.length),
            ),
            //working
            // SliverList(
            //   delegate:
            //       SliverChildBuilderDelegate((context, index) {
            //     var cMonth = months[index];
            //     var displayFormat = DateFormat.yMMM();

            //     var urlMonth = urlDate.format(cMonth.begin);
            //     var monthDays = cMonth.days;

            //     Map<String, num> data = {};
            //     monthDays.forEach((d) =>
            //         data[d.date.day.toString()] =
            //             d.totalConsumption);
            //     return SquiddyCard(
            //       graphData: data,
            //       onTap: () {
            //         Navigator.push(
            //             context,
            //             SlideLeftRoute(
            //                 name: '/monthDays/$urlMonth',
            //                 page: Provider(
            //                     create: (_) => cMonth,
            //                     child: MonthDaysPage())));
            //       },
            //       color: cardColors[index],
            //       inkColor: cardColors[index] ==
            //               SquiddyTheme.squiddyPrimary
            //           ? SquiddyTheme.squiddyPrimary[300]
            //           : SquiddyTheme.squiddySecondary[300],
            //       title: displayFormat.format(cMonth.begin),
            //       total:
            //           '${cMonth.totalConsumption.toStringAsFixed(2)}kWh',
            //     );
            //   }, childCount: months.length),
            // )
          ],
        ),
      ),
    );
  }

  Widget getSmallScreenView(
      List<EnergyMonth> months, List<MaterialAccentColor> cardColors) {
    return SafeArea(
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
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
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
                  ],
                ),
              ]),
            ),
            /********************
                           * Agile price section
                           *******************/
            //What will become the new agile price section
            settings.showAgilePrices
                ? SliverToBoxAdapter(
                    child: AgilePriceList(),
                  )
                : SliverToBoxAdapter(
                    child: Container(
                      height: 10,
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
            // ResponsiveWidget(
            //   smallScreen: SliverList(
            //     delegate:
            //         SliverChildBuilderDelegate((context, index) {
            //       var cMonth = months[index];
            //       var displayFormat = DateFormat.yMMM();

            //       var urlMonth = urlDate.format(cMonth.begin);
            //       var monthDays = cMonth.days;

            //       Map<String, num> data = {};
            //       monthDays.forEach((d) =>
            //           data[d.date.day.toString()] =
            //               d.totalConsumption);
            //       return SquiddyCard(
            //         graphData: data,
            //         onTap: () {
            //           Navigator.push(
            //               context,
            //               SlideLeftRoute(
            //                   name: '/monthDays/$urlMonth',
            //                   page: Provider(
            //                       create: (_) => cMonth,
            //                       child: MonthDaysPage())));
            //         },
            //         color: cardColors[index],
            //         inkColor: cardColors[index] ==
            //                 SquiddyTheme.squiddyPrimary
            //             ? SquiddyTheme.squiddyPrimary[300]
            //             : SquiddyTheme.squiddySecondary[300],
            //         title: displayFormat.format(cMonth.begin),
            //         total:
            //             '${cMonth.totalConsumption.toStringAsFixed(2)}kWh',
            //       );
            //     }, childCount: months.length),
            //   ),
            //   // largeScreen: SliverGrid(
            //   //     delegate: SliverChildBuilderDelegate(
            //   //         (context, index) {
            //   //       var cMonth = months[index];
            //   //       var displayFormat = DateFormat.yMMM();

            //   //       var urlMonth = urlDate.format(cMonth.begin);
            //   //       var monthDays = cMonth.days;

            //   //       Map<String, num> data = {};
            //   //       monthDays.forEach((d) =>
            //   //           data[d.date.day.toString()] =
            //   //               d.totalConsumption);
            //   //       return Container(
            //   //           constraints: BoxConstraints(
            //   //               maxWidth: 200, maxHeight: 200),
            //   //           child: SquiddyCard(
            //   //             graphData: data,
            //   //             onTap: () {
            //   //               Navigator.push(
            //   //                   context,
            //   //                   SlideLeftRoute(
            //   //                       name: '/monthDays/$urlMonth',
            //   //                       page: Provider(
            //   //                           create: (_) => cMonth,
            //   //                           child: MonthDaysPage())));
            //   //             },
            //   //             color: cardColors[index],
            //   //             inkColor: cardColors[index] ==
            //   //                     SquiddyTheme.squiddyPrimary
            //   //                 ? SquiddyTheme.squiddyPrimary[300]
            //   //                 : SquiddyTheme
            //   //                     .squiddySecondary[300],
            //   //             title:
            //   //                 displayFormat.format(cMonth.begin),
            //   //             total:
            //   //                 '${cMonth.totalConsumption.toStringAsFixed(2)}kWh',
            //   //           ));
            //   //     }, childCount: months.length),
            //   //     gridDelegate:
            //   //         SliverGridDelegateWithFixedCrossAxisCount(
            //   //             crossAxisCount: 2)),
            // ),
            //working
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                var cMonth = months[index];
                var displayFormat = DateFormat.yMMM();

                var urlMonth = urlDate.format(cMonth.begin);
                var monthDays = cMonth.days;

                Map<String, num> data = {};
                monthDays.forEach(
                    (d) => data[d.date.day.toString()] = d.totalConsumption);
                return IntrinsicHeight(
                  child: Container(
                    child: SquiddyCard(
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
                      inkColor: cardColors[index] == SquiddyTheme.squiddyPrimary
                          ? SquiddyTheme.squiddyPrimary[300]
                          : SquiddyTheme.squiddySecondary[300],
                      title: displayFormat.format(cMonth.begin),
                      total: '${cMonth.totalConsumption.toStringAsFixed(2)}kWh',
                    ),
                  ),
                );
              }, childCount: months.length),
            )
          ],
        ),
      ),
    );
  }

  // SliverChildDelegate getChildDelegate(
  //     {int maxWidth,
  //     int maxHeight,
  //     List<EnergyMonth> months,
  //     List<MaterialAccentColor> cardColors}) {
  //   return;
  // }
}
