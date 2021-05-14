import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/widgets/agilePriceCard.dart';

class AgilePriceList extends StatefulWidget {
  @override
  _AgilePriceListState createState() => _AgilePriceListState();
}

class _AgilePriceListState extends State<AgilePriceList> {
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
            child: octopusManager.loadingData
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
                    ? Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: currentAgilePrices.length,
                          itemBuilder: (context, index) {
                            var ap = currentAgilePrices[index];
                            return AgilePriceCard(
                                time: timeFormat.format(ap.validFrom),
                                price: ap.valueIncVat);
                          },
                        ),
                      )
                    : Container(
                        child: Text('Uh oh, could not get Agile prices'),
                      )),
      ],
    );
  }
}
