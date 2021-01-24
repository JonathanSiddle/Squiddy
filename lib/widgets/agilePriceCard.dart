import 'dart:math';

import 'package:flutter/material.dart';

class AgilePriceCard extends StatelessWidget {
  final String time;
  final String price;
  final rnd = Random();
  final List<Color> colors = [
    Colors.orange.shade300,
    Colors.orange.shade500,
    Colors.green.shade300,
    Colors.green.shade500,
    Colors.red.shade300,
    Colors.red.shade500
  ];

  AgilePriceCard({this.time, this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Card(
          color: colors[rnd.nextInt(5)],
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('$price'),
            ],
          )),
    );
  }
}
