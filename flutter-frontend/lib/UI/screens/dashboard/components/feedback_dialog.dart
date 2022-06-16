import 'package:admin/support/extensions/string_capitalization.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';

import '../../../behaviors/app_localizations.dart';
import '../../../constants.dart';

class FeedbackDialog{
  FeedbackDialog({Key? key, required this.type, required this.context, required this.title, this.message});

  CoolAlertType type;
  BuildContext context;
  String title;
  String? message;

  show(){
    CoolAlert.show(
        context: context,
        type: type,
        title: title,
        text: message == null ? "": message,
        backgroundColor: bgColor,
        confirmBtnColor: primaryColor,
        onConfirmBtnTap: () => Navigator.pop(context));
  }
}
