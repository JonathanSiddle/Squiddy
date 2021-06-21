import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Util/SlideRoute.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/routes/settingPage.dart';

class OverviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loading = Provider.of<OctopusManager>(context).loadingData;

    return Column(
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
                    Navigator.push(context,
                        SlideTopRoute(page: SettingsPage(), name: 'settings'));
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
