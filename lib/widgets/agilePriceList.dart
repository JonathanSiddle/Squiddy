import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';
import 'package:squiddy/widgets/agilePriceCard.dart';

class AgilePriceList extends StatelessWidget {
  final timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (context, child, OctopusManager octoManager) {
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
                future: octoManager.getAgilePrices(
                    tarrifCode: octoManager.agileTarrifCode,
                    onlyAfterDateTime: true),
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
    });
  }
}
