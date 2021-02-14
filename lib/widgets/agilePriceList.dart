import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/widgets/agilePriceCard.dart';

class AgilePriceList extends StatefulWidget {
  @override
  _AgilePriceListState createState() => _AgilePriceListState();
}

class _AgilePriceListState extends State<AgilePriceList> {
  final timeFormat = DateFormat('HH:mm');

  Future<List<AgilePrice>> _agilePriceFuture;

  @override
  initSate() {
    var octoManager = Provider.of<OctopusManager>(context);
    var settingsManager = Provider.of<SettingsManager>(context);

    _agilePriceFuture = octoManager.getAgilePrices(
        tariffCode: settingsManager.activeAgileTariff, onlyAfterDateTime: true);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var octoManager = Provider.of<OctopusManager>(context);
    var settingsManager = Provider.of<SettingsManager>(context);

    _agilePriceFuture = octoManager.getAgilePrices(
        tariffCode: settingsManager.activeAgileTariff, onlyAfterDateTime: true);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
          child: FutureBuilder<List<AgilePrice>>(
              future: _agilePriceFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Shimmer.fromColors(
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
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    child: Text('Uh oh, could not get Agile prices'),
                  );
                }

                return Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      var ap = snapshot.data[index];
                      return AgilePriceCard(
                          time: timeFormat.format(ap.validFrom),
                          price: ap.valueIncVat);
                    },
                  ),
                );
              }),
        ),
      ],
    );
  }
}
