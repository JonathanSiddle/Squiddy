import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Util/SlideRoute.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/routes/settingPage.dart';
import 'package:squiddy/widgets/agilePriceSection.dart';
import 'package:squiddy/widgets/yesterdaySummarySection.dart';

class OverviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsManager>(context);
    final loading = Provider.of<OctopusManager>(context).loadingData;

    var screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 450,
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
          Container(
            width: screenWidth,
            height: 350,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // children: [AgilePriceSection(), YesterdaySummarySection()],
              children: [
                Container(child: AgilePriceSection()),
                YesterdaySummarySection()
              ],
            ),
          )
          // Container(
          //   width: screenWidth,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       settings.showAgilePrices
          //           //todo fix this display for non-agile customers
          //           ? AgilePriceSection()
          //           : Container(
          //               height: 10,
          //             ),
          //       YesterdaySummarySection()
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
