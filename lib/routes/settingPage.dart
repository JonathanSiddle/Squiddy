import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Util/AppConfig.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  OctopusManager octoManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    octoManager = Provider.of<OctopusManager>(context);
  }

  @override
  Widget build(BuildContext context) {
    var settingsManager = Provider.of<SettingsManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.infoCircle),
              onPressed: () {
                showAboutDialog(
                    context: context,
                    applicationIcon: Image.asset('assets/SSquid3.png',
                        height: 50.0),
                    applicationName: 'Squiddy',
                    applicationVersion: AppConfig.appVersion,
                    children: <Widget>[
                      Text(AppConfig.overview),
                      Center(
                        child: InkWell(
                            child: Text('https://octopus.energy', style: TextStyle(color: Colors.blue),),
                            onTap: () => launch('https://octopus.energy')),
                      ),
                      Text(''),
                      InkWell(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.github),
                              Text('Squiddy Project', style: TextStyle(color: Colors.blue)),
                            ],
                          ),
                          onTap: () => launch('https://github.com/JonathanSiddle/Squiddy'))
                    ]);
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text(
              'Theme',
              style: TextStyle(fontSize: 36),
            ),
            //  DropdownButton(),
            DropdownButton<ThemeBrightness>(
                isExpanded: true,
                value: settingsManager.themeBrightness,
                onChanged: (ThemeBrightness nv) {
                  DynamicTheme.of(context).setBrightness(nv.toBrightness());
                  nv.saveSetting(settingsManager);
                },
                items: ThemeBrightness.values.map((tb) {
                  return DropdownMenuItem<ThemeBrightness>(
                      value: tb, child: Text(tb.niceString()));
                }).toList()),
            Spacer(),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.red,
                    elevation: 5,
                    onPressed: () async {
                      print('Logging out');
                      await settingsManager.cleanSettings();
                      octoManager.resetState();
                      //pop navigation
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
