import 'dart:math';

import 'package:flutter/material.dart';

class AgilePriceCard extends StatelessWidget {
  final String time;
  final num price;
  final rnd = Random();
  final maxPrice = 35;
  final List<Color> colors = [
    Colors.orange.shade300,
    Colors.orange.shade500,
    Colors.green.shade300,
    Colors.green.shade500,
    Colors.red.shade300,
    Colors.red.shade500
  ];

  AgilePriceCard({this.time, this.price});

  Color getColour(num price) {
    if (price > ((maxPrice / 100) * 0.60) * 100) {
      return Colors.red.shade500;
    } else if (price > ((maxPrice / 100) * 0.50) * 100) {
      return Colors.red.shade300;
    } else if (price > ((maxPrice / 100) * 0.45) * 100) {
      return Colors.orange.shade500;
    } else if (price > ((maxPrice / 100) * 0.40) * 100) {
      return Colors.orange.shade300;
    } else if (price > ((maxPrice / 100) * 0.35) * 100) {
      return Colors.green.shade300;
    } else if (price < ((maxPrice / 100) * 0.35) * 100) {
      return Colors.green.shade500;
    }
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Card(
          color: getColour(price),
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('${price.toStringAsFixed(2)}p'),
            ],
          )),
    );
  }
}
