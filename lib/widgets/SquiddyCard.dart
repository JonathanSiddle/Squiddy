import 'package:flutter/material.dart';
import 'package:squiddy/Charts/octoLineChart.dart';

class SquiddyCard extends StatelessWidget {
  final String title;
  final String total;
  final Color color;
  final Color inkColor;
  final double ratio;
  final void Function() onTap;
  final Map<String, num> graphData;
  final bool graphInteractive;
  final bool graphShowLeftAxis;
  final bool graphShowBottomAxis;
  final EdgeInsets graphPadding;
  final List<Color> graphColours;

  SquiddyCard(
      {@required this.title,
      @required this.total,
      @required this.graphData,
      this.graphInteractive,
      this.graphColours,
      this.color,
      this.ratio,
      this.graphShowLeftAxis,
      this.graphShowBottomAxis,
      this.graphPadding,
      this.inkColor,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    var textColour = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 5, 10, 5),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 120),
        child: Card(
          elevation: 10,
          // color: Color.fromARGB(255, 228, 78, 168),
          color: color,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColour),
                        ),
                        Text(
                          total,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColour),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        graphData != null
                            ? Padding(
                                padding: this.graphPadding ??
                                    const EdgeInsets.all(10.0),
                                child: OctoLineChart(
                                  data: graphData,
                                  aspectRatio: this.ratio ?? 21.0 / 3.0,
                                  interactive: this.graphInteractive ?? false,
                                  showLeftAxis: this.graphShowLeftAxis ?? false,
                                  showBottomAxis:
                                      this.graphShowBottomAxis ?? false,
                                  isCurved: true,
                                  gradientColours: this.graphColours ??
                                      [Colors.grey, Colors.grey],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Center(
                                  child: Text(
                                    'Data missing',
                                    style: TextStyle(fontSize: 36),
                                  ),
                                ),
                              )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
