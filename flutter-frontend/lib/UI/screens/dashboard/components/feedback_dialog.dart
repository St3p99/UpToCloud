import 'package:admin/support/extensions/string_capitalization.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';

import '../../../behaviors/app_localizations.dart';
import '../../../constants.dart';
import '../../../responsive.dart';

class FeedbackDialog{
  FeedbackDialog({Key? key, required this.type, required this.context, required this.title, this.message});

  CoolAlertType type;
  BuildContext context;
  String title;
  String? message;

  Future show(){
    return CoolAlert.show(
        context: context,
        type: type,
        title: title,
        text: message == null ? "": message,
        width: Responsive.isMobile(context) ? MediaQuery.of(context).size.width*.8 :
        Responsive.isTablet(context) ? MediaQuery.of(context).size.width*.6 :
        MediaQuery.of(context).size.width*.2,
        backgroundColor: bgColor,
        confirmBtnColor: primaryColor,
        onConfirmBtnTap: () => Navigator.pop(context));
  }
}
