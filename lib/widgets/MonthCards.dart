import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Theme/SquiddyTheme.dart';
import 'package:squiddy/Util/SlideRoute.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/dataClasses/EnergyMonth.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/routes/monthDaysPage.dart';
import 'package:squiddy/widgets/SquiddyCard.dart';

class MonthCards extends StatefulWidget {
  @override
  _MonthCardsState createState() => _MonthCardsState();
}

class _MonthCardsState extends State<MonthCards> {
  final urlDate = DateFormat('yyyy/MM');

  SettingsManager settings;
  OctopusManager octoManager;
  Set<EnergyMonth> monthsCache;
  bool loading;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // settings = Provider.of<SettingsManager>(context);
    // octoManager = Provider.of<OctopusManager>(context);
  }

  @override
  //This method is currently being used inside a custom scroll view
  //so it needs to return a sliver
  Widget build(BuildContext context) {
    loading = context.select((OctopusManager man) => man.loadingData);
    monthsCache = context.select((OctopusManager man) => man.monthsCache);
    // print('Starting to build months cache');
    // var initialised = Provider.of<OctopusManager>(context).initialised;

    // return SliverList(
    //   delegate: SliverChildListDelegate([
    //     Column(
    //       children: [
    //         Text('Loading: ${loading.toString()}'),
    //         Text('Months: ${monthsCache.length}'),
    //       ],
    //     )
    //   ]),
    // );

    // return ResponsiveWidget(
    //   smallScreen: getSmallScreenView(months),
    //   mediumScreen: getLargeScreenView(months, gridSize: 2),
    //   largeScreen: getLargeScreenView(months, gridSize: 3),
    //   exLargeScreen: getLargeScreenView(months, gridSize: 4),
    // );
    // return getLargeScreenView(months, gridSize: 3);
    // return getSmallScreenView(monthsCache);
    return getLargeScreenView(monthsCache, gridSize: 3);
  }

  Widget getLargeScreenView(Set<EnergyMonth> months, {int gridSize = 2}) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize, childAspectRatio: 21 / 9),
      delegate: SliverChildBuilderDelegate((context, index) {
        var cMonth = months.elementAt(index);
        var displayFormat = DateFormat.yMMM();

        var urlMonth = urlDate.format(cMonth.begin);
        var monthDays = cMonth.days;

        Map<String, num> data = {};
        monthDays
            .forEach((d) => data[d.date.day.toString()] = d.totalConsumption);
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
                            create: (_) => cMonth, child: MonthDaysPage())));
              },
              color: SquiddyTheme.squiddyPrimary,
              inkColor: SquiddyTheme.squiddyPrimary[300],
              title: displayFormat.format(cMonth.begin),
              total: '${cMonth.totalConsumption.toStringAsFixed(2)}kWh',
              totalCost: '${cMonth.totalPricePounds.toStringAsFixed(2)}',
            ),
          ),
        );
      }, childCount: months.length),
    );
  }

  Widget getSmallScreenView(Set<EnergyMonth> months) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        var cMonth = months.elementAt(index);
        var displayFormat = DateFormat.yMMM();

        var urlMonth = urlDate.format(cMonth.begin);
        var monthDays = cMonth.days;

        Map<String, num> data = {};
        monthDays
            .forEach((d) => data[d.date.day.toString()] = d.totalConsumption);
        return Container(
          child: SquiddyCard(
            graphData: data,
            onTap: () {
              Navigator.push(
                  context,
                  SlideLeftRoute(
                      name: '/monthDays/$urlMonth',
                      page: Provider(
                          create: (_) => cMonth, child: MonthDaysPage())));
            },
            color: SquiddyTheme.squiddyPrimary,
            inkColor: SquiddyTheme.squiddyPrimary[300],
            title: displayFormat.format(cMonth.begin),
            total: '${cMonth.totalConsumption.toStringAsFixed(2)}kWh',
          ),
        );
      }, childCount: months.length),
    );
  }
}
