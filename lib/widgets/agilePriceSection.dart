import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/dataClasses/AgilePrice.dart';
import 'package:squiddy/widgets/agilePriceCard.dart';

class AgilePriceSection extends StatefulWidget {
  final int gridSize;
  final bool compactView;

  AgilePriceSection({this.gridSize = 8, this.compactView = false});

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
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
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
              padding: const EdgeInsets.fromLTRB(0, 5, 10, 10),
              child: currentAgilePrices.length < 1
                  //todo update loading style to new format
                  ? Shimmer.fromColors(
                      baseColor: Colors.black12,
                      highlightColor: Colors.white,
                      child: Container(
                        height: 100,
                        child: Row(
                          children: [
                            Text('Loading prices...')
                            // AgilePriceCard(time: '...', price: 0),
                            // AgilePriceCard(time: '...', price: 0),
                            // AgilePriceCard(time: '...', price: 0),
                            // AgilePriceCard(time: '...', price: 0),
                          ],
                        ),
                      ),
                    )
                  : currentAgilePrices.length > 0
                      ? this.widget.compactView
                          ? getCompactview(currentAgilePrices)
                          : getCustomGridView(currentAgilePrices,
                              gridSize: this.widget.gridSize)
                      : Container(
                          child: Text('Uh oh, could not get Agile prices'),
                        )),
        ],
      ),
    );
  }

  Widget getCompactview(List<AgilePrice> currentAgilePrices) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: currentAgilePrices.length,
        itemBuilder: (context, index) {
          var ap = currentAgilePrices[index];
          return AgilePriceCard(
              time: timeFormat.format(ap.validFrom), price: ap.valueIncVat);
        },
      ),
    );
  }

  Widget getCustomGridView(List<AgilePrice> agilePrices,
      {int gridSize, double width = 650}) {
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

    return Container(
      height: 300,
      width: width,
      child: ListView.builder(
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        itemCount: agilePriceRows.length,
        itemBuilder: (context, index) {
          var row = agilePriceRows[index];
          return Row(
            children: [
              ...row
                  .map((ap) => AgilePriceCard(
                        time: timeFormat.format(ap.validFrom),
                        price: ap.valueIncVat,
                      ))
                  .toList()
            ],
          );
        },
      ),
    );
  }
}
