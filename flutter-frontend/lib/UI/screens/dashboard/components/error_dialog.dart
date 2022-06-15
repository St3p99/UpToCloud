import 'package:admin/support/extensions/string_capitalization.dart';
import 'package:flutter/material.dart';

import '../../../behaviors/app_localizations.dart';

class ErrorDialog extends StatelessWidget {
  ErrorDialog({Key? key, required this.title, this.message}) : super(key: key);

  String title;
  String? message;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: AlertDialog(
        title: Text(title),
        content: Text(message == null ? "" : message!),
        actions: <Widget>[
          TextButton(
            child: Text(
              AppLocalizations.of(context)!.translate("close")!.capitalize,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
