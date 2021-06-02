import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:squiddy/Charts/overviewSummary.dart';
import 'package:squiddy/Theme/SquiddyTheme.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/dataClasses/ElectricityAccount.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/widgets/MonthCards.dart';
import 'package:squiddy/widgets/agilePriceList.dart';
import 'package:squiddy/widgets/monthsOverview/OverviewSection.dart';

class MonthsOverview extends StatefulWidget {
  MonthsOverview();

  @override
  _MonthsOverviewState createState() => _MonthsOverviewState();
}

class _MonthsOverviewState extends State<MonthsOverview> {
  final stringList = {
    'Test1',
    'Test2',
    'Test3',
    'Test4',
    'Test5',
    'Test6',
    'Test7',
    'Test8',
    'Test9',
    'Test10',
    'Test11',
    'Test12',
    'Test13',
    'Test14',
    'Test15',
    'Test16',
    'Test17',
    'Test18',
    'Test19',
    'Test20',
    'Test21',
    'Test22',
    'Test23',
    'Test24',
    'Test25',
    'Test26',
    'Test27',
    'Test28',
    'Test29',
    'Test30',
    'Test31',
    'Test32',
    'Test33',
    'Test34',
    'Test35',
    'Test36',
    'Test37',
    'Test38',
    'Test39',
    'Test40',
    'Test41',
    'Test42',
    'Test43',
    'Test44',
    'Test45',
    'Test46',
    'Test47',
    'Test48',
    'Test49',
    'Test50',
    'Test51',
    'Test52',
    'Test53',
    'Test54',
    'Test55',
    'Test56',
    'Test57'
  };
  final RefreshController _refreshController =
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

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  refreshData() async {
    if (octoManager != null && settings != null) {
      await octoManager.initData(
          activeAgileTariff: settings.activeAgileTariff,
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

  @override
  Widget build(BuildContext context) {
    var initialised = Provider.of<OctopusManager>(context).initialised;
    var errorGettingData =
        Provider.of<OctopusManager>(context).errorGettingData;
    var timeoutError = Provider.of<OctopusManager>(context).timeoutError;

    return !initialised && !errorGettingData
        ? Center(child: CircularProgressIndicator())
        : initialised && timeoutError
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
            : octoManager.consumption.length == 0 ||
                    octoManager.errorGettingData
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
                              OverviewSection(),
                            ]),
                          ),
                          // /********************
                          //  * Agile price section
                          //  *******************/
                          // What will become the new agile price section
                          settings.showAgilePrices
                              ? SliverToBoxAdapter(
                                  child: AgilePriceList(),
                                )
                              : SliverToBoxAdapter(
                                  child: Container(
                                    height: 10,
                                  ),
                                ),
                          // SliverList(
                          //   delegate: SliverChildListDelegate([
                          //     Column(
                          //       children: <Widget>[
                          //         Padding(
                          //           padding: const EdgeInsets.all(10.0),
                          //           child: OverviewSummary(),
                          //         ),
                          //       ],
                          //     ),
                          //   ]),
                          // ),
                          /*
                          * Main month card section
                          */
                          MonthCards(),
                          SliverList(
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                              var string = stringList.toList()[index];
                              return Container(child: Text(string));
                            }, childCount: stringList.length),
                          )
                          // MonthCards(),
                        ],
                      ),
                    ),
                  );
  }
}
