import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Util/SlideRoute.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/routes/settingPage.dart';
import 'package:squiddy/widgets/agilePriceSection.dart';
import 'package:squiddy/widgets/responsiveWidget.dart';
import 'package:squiddy/widgets/yesterdaySummarySection.dart';

class OverviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loading = Provider.of<OctopusManager>(context).loadingData;

    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      // height: screenWidth < 600 ? 1000 : 450,
      // height: 600,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Row(
              children: <Widget>[
                Text(
                  'Squiddy',
                  style: TextStyle(fontSize: 48),
                ),
                loading
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
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
                              page: SettingsPage(), name: 'settings'));
                    }),
                //Agile price and yesterday information section
              ],
            ),
          ),
          ResponsiveWidget(
            smallScreen: columnView(),
            mediumScreen: columnView(),
            largeScreen: sideBySideViewScreen(gridSize: 6, graphWidth: 500),
            exLargeScreen: sideBySideViewScreen(gridSize: 8, graphWidth: 650),
          )
        ],
      ),
    );
  }

  Widget columnView({double screenWidth = 350, double height = 650}) {
    return Container(
      // width: screenWidth,
      // height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: AgilePriceSection(
              compactView: true,
            ),
          ),
          YesterdaySummarySection(graphWidth: 350),
        ],
      ),
    );
  }

  Widget sideBySideViewScreen(
      {int gridSize = 8,
      double graphWidth = 650,
      double screenWidth,
      double height = 350}) {
    return Container(
      width: screenWidth,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // children: [AgilePriceSection(), YesterdaySummarySection()],
        children: [
          Container(
              child: AgilePriceSection(
            gridSize: gridSize,
          )),
          YesterdaySummarySection(graphWidth: graphWidth),
        ],
      ),
    );
  }
}
