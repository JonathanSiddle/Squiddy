import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Theme/SquiddyTheme.dart';
import 'package:squiddy/Util/DialogUtil.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:url_launcher/url_launcher.dart';

class BootStrap extends StatefulWidget {
  BootStrap();

  @override
  _BootStrapPageState createState() => _BootStrapPageState();
}

class _BootStrapPageState extends State<BootStrap> {
  // var _formKey = GlobalKey<FormState>();
  Map<String, List<String>> meterPoints;
  String selectedMp;
  String selectedMeter;
  String validatedAPIKey = '';
  var apiKeyTEC = TextEditingController();
  var accountTEC = TextEditingController();

  var _checkingAccountDetails = false;
  var _stepIndex = 0;
  bool loading = false;
  SettingsManager settingsManager;
  OctopusManager octopusManager;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final sm = Provider.of<SettingsManager>(context);
    octopusManager = Provider.of<OctopusManager>(context);
    if (sm != settingsManager) {
      settingsManager = sm;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(50),
        child: Column(
          children: <Widget>[
            Image.asset('assets/Stephen.png'),
            Center(
                child: SquiddyTheme.squiddytHeadingBig2('Squiddy',
                    color: SquiddyTheme.squiddyPrimary)),
            Stepper(
                type: StepperType.vertical,
                physics: NeverScrollableScrollPhysics(),
                currentStep: _stepIndex ?? 0,
                controlsBuilder: (context, {onStepCancel, onStepContinue}) {
                  if (_stepIndex != 0) {
                    return OutlineButton(
                      color: SquiddyTheme.squiddySecondary,
                      child: Text(
                        'Back',
                        style: TextStyle(color: SquiddyTheme.squiddySecondary),
                      ),
                      onPressed: () {
                        setState(() {
                          _stepIndex -= 1;
                        });
                      },
                    );
                  }

                  return Container();
                },
                steps: [
                  Step(
                      isActive: _stepIndex == 0 ? true : false,
                      title: Text('Account Details'),
                      content: Column(
                        children: <Widget>[
                          !_checkingAccountDetails
                              ? Column(
                                  children: <Widget>[
                                    Text('Please enter your developer API key'),
                                    Text(''),
                                    InkWell(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Where do I get an API key?',
                                                style: TextStyle(
                                                    color: Colors.blue)),
                                          ],
                                        ),
                                        onTap: () =>
                                            launch('https://github.com/JonathanSiddle/Squiddy/wiki/Logging-into-Squiddy')),
                                    TextFormField(
                                      key: Key('apiKey'),
                                      controller: apiKeyTEC,
                                      decoration:
                                          InputDecoration(hintText: 'API Key'),
                                      onChanged: (v) {
                                        settingsManager.apiKey = v.trim();
                                      },
                                    ),
                                    TextFormField(
                                      key: Key('accountId'),
                                      controller: accountTEC,
                                      decoration: InputDecoration(
                                          hintText: 'AccountID'),
                                      onChanged: (v) {
                                        settingsManager.accountId = v.trim();
                                      },
                                    ),
                                    RaisedButton(
                                      color: SquiddyTheme.squiddyPrimary,
                                      child: Text(
                                        'Go',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        print('Tapped go button');
                                        setState(() {
                                          _checkingAccountDetails = true;
                                        });
                                        var account = await octopusManager
                                            .getAccountDetails(
                                                accountTEC.text.trim(),
                                                apiKeyTEC.text.trim());
                                        print('Got account details');
                                        print(account.toString());
                                        if (account != null) {
                                          meterPoints = Map();
                                          print('got account details');
                                          account.electricityMeterPoints
                                              .forEach((el) {
                                            meterPoints[el.mpan] = el.meters
                                                .map((e) => e.serialNumber)
                                                .toList();
                                          });
                                          if (meterPoints.length > 0 &&
                                              meterPoints[meterPoints?.keys
                                                          ?.toList()[0]]
                                                      .length >
                                                  0) {
                                            setState(() {
                                              selectedMp = meterPoints?.keys
                                                  ?.toList()[0];
                                              //default meter point in settings manager
                                              //just in case it isn't changed later
                                              settingsManager.meterPoint =
                                                  meterPoints?.keys
                                                      ?.toList()[0];
                                              selectedMeter =
                                                  meterPoints[selectedMp][0];
                                              settingsManager.meter =
                                                  selectedMeter;
                                              //set meters
                                              _stepIndex += 1;
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            _checkingAccountDetails = false;
                                          });
                                          await DialogUtil.messageDialog(
                                              context,
                                              'Uh oh',
                                              'Something went wrong, please check your details and try again');
                                        }
                                      },
                                    )
                                  ],
                                )
                              : CircularProgressIndicator(),
                        ],
                      )),
                  Step(
                      isActive: _stepIndex == 1 ? true : false,
                      title: Text('Meter'),
                      content: Column(
                        children: <Widget>[
                          Text('Select a meter point'),
                          DropdownButton<String>(
                            value: selectedMp,
                            onChanged: (v) {
                              setState(() {
                                selectedMp = v;
                                settingsManager.meterPoint = v;
                              });
                            },
                            items: meterPoints?.keys
                                ?.map<DropdownMenuItem<String>>(
                                    (e) => DropdownMenuItem<String>(
                                          value: e,
                                          child: Text(e),
                                        ))
                                ?.toList(),
                          ),
                          selectedMp == null
                              ? Container()
                              : DropdownButton<String>(
                                  value: selectedMeter,
                                  onChanged: (v) {
                                    setState(() {
                                      selectedMeter = v;
                                      settingsManager.meter = v;
                                    });
                                  },
                                  items: meterPoints[selectedMp]
                                      ?.map<DropdownMenuItem<String>>(
                                          (e) => DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              ))
                                      ?.toList(),
                                ),
                          RaisedButton(
                            color: SquiddyTheme.squiddyPrimary,
                            child: Text(
                              'Test',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              var recentReadings =
                                  await octopusManager.getConsumptionLast30Days(
                                      apiKeyTEC.text,
                                      selectedMp,
                                      selectedMeter);
                              print('${recentReadings.length} recent readings');
                              var proceed = await DialogUtil.showYesNoDialog(
                                  context,
                                  '${recentReadings.length} recent readings for $selectedMeter do you want to use this meter?');

                              if (proceed) {
                                print('Tapped Yes');
                                await settingsManager.saveSettings();
                                //make sure octomanager re-inits data with new settings
                                octopusManager.initData(
                                    apiKey: settingsManager.apiKey,
                                    accountId: settingsManager.apiKey,
                                    meterPoint: settingsManager.meterPoint,
                                    meter: settingsManager.meter);
                              } else {
                                print('Tapped No');
                              }
                            },
                          )
                        ],
                      )),
                ]),
          ],
        ),
      ),
    );
  }
}
