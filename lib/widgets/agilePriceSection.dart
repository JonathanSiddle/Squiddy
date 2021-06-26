import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/dataClasses/AgilePrice.dart';
import 'package:squiddy/widgets/agilePriceCard.dart';
import 'package:squiddy/widgets/responsiveWidget.dart';

class AgilePriceSection extends StatefulWidget {
  @override
  _AgilePriceSectionState createState() => _AgilePriceSectionState();
}

class _AgilePriceSectionState extends State<AgilePriceSection> {
  final timeFormat = DateFormat('HH:mm');
  OctopusManager octopusManager;

  @override
  void didChangeDependencies() {
    octopusManager = Provider.of<OctopusManager>(context);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var currentAgilePrices = octopusManager.currentAgilePrices;

    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Current Prices',
                  style: TextStyle(fontSize: 24),
                ),
                Tooltip(
                  message: 'Hide or show in settings',
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Icon(FontAwesomeIcons.questionCircle),
                  ),
                )
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              child: currentAgilePrices.length < 1
                  //todo update loading style to new format
                  ? Shimmer.fromColors(
                      baseColor: Colors.black12,
                      highlightColor: Colors.white,
                      child: Container(
                        height: 100,
                        child: Row(
                          children: [
                            AgilePriceCard(time: '...', price: 0),
                            AgilePriceCard(time: '...', price: 0),
                            AgilePriceCard(time: '...', price: 0),
                            AgilePriceCard(time: '...', price: 0),
                          ],
                        ),
                      ),
                    )
                  : currentAgilePrices.length > 0
                      ? ResponsiveWidget(
                          smallScreen: getCustomGridView(currentAgilePrices,
                              gridSize: 3),
                          mediumScreen: getCustomGridView(currentAgilePrices,
                              gridSize: 5),
                          largeScreen: getCustomGridView(currentAgilePrices,
                              gridSize: 7),
                        )
                      : Container(
                          child: Text('Uh oh, could not get Agile prices'),
                        )),
        ],
      ),
    );
  }

  Widget getLargeScreenView(List<AgilePrice> agilePrices, {int gridSize = 2}) {
    // return SliverGrid(
    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: 2, childAspectRatio: 4 / 3),
    //   delegate: SliverChildBuilderDelegate((context, index) {
    //     var ap = agilePrices[index];
    //     return AgilePriceCard(
    //         time: timeFormat.format(ap.validFrom), price: ap.valueIncVat);
    //   }),
    // );
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      children: List.generate(agilePrices.length, (index) {
        var ap = agilePrices[index];
        return AgilePriceCard(
            time: timeFormat.format(ap.validFrom), price: ap.valueIncVat);
      }),
    );
  }

  Widget getCustomGridView(List<AgilePrice> agilePrices, {int gridSize}) {
    List<List<AgilePrice>> agilePriceRows = [];

    var cGridCount = 0;
    List<AgilePrice> currentRow = [];
    for (var x = 0; x <= agilePrices.length - 1; x++) {
      if (cGridCount == gridSize) {
        agilePriceRows.add(currentRow);
        currentRow = [];
        cGridCount = 0;
      }

      var price = agilePrices[x];
      currentRow.add(price);
      cGridCount += 1;
    }

    // return ListView.builder(
    //   shrinkWrap: true,
    //   itemCount: agilePriceRows.length,
    //   itemBuilder: (context, index) {
    //     var row = agilePriceRows[index];

    //     return Row(
    //       children: [
    //         ...row
    //             .map((ap) => AgilePriceCard(
    //                   time: timeFormat.format(ap.validFrom),
    //                   price: ap.valueIncVat,
    //                 ))
    //             .toList()
    //       ],
    //     );
    //   },
    // );
    return Column(
      children: [
        ...agilePriceRows
            .map((r) => Row(
                  children: [
                    ...r
                        .map((ap) => AgilePriceCard(
                              time: timeFormat.format(ap.validFrom),
                              price: ap.valueIncVat,
                            ))
                        .toList()
                  ],
                ))
            .toList()
      ],
    );
  }
}
