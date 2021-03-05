import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DialogUtil {
  ///show a dialog box with a [title] and [message]
  ///can be made [dismissible] with optional param
  static Future<bool> messageDialog(
      BuildContext context, String title, String message,
      {dismissible = false}) async {
    bool pressedYes = false;

    await showDialog<String>(
      context: context,
      barrierDismissible:
          dismissible, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor)),
          content: Text(message,
              style: TextStyle(color: Theme.of(context).accentColor)),
          actions: <Widget>[
            TextButton(
              child: Text('OK',
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return pressedYes;
  }

  ///Dialog shows a Yes/No dialog, takes a [message] and returns a Future<bool>
  ///true if the user tapped yes, false if the user tapped no
  static Future<bool> showYesNoDialog(BuildContext context, String message,
      {String title}) async {
    bool pressedYes = false;

    await showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Confirm'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                pressedYes = true;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                print('Clicked No option!');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return pressedYes;
  }
}
