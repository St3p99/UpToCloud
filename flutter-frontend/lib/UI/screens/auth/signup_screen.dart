import 'dart:html';

import 'package:admin/UI/constants.dart';
import 'package:admin/UI/main.dart';
import 'package:admin/UI/screens/dashboard/home_screen.dart';
import 'package:admin/api/api_controller.dart';
import 'package:admin/support/extensions/string_capitalization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:page_transition/page_transition.dart';

import '../../../controllers/user_provider.dart';
import '../../../models/user.dart';
import '../../../support/constants.dart';
import '../../../support/login_result.dart';
import '../../behaviors/app_localizations.dart';
import '../../responsive.dart';
import '../dashboard/components/feedback_dialog.dart';
import '../main/main_screen.dart';
import 'package:cool_alert/cool_alert.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String _email;
  late String _username;
  late String _password;
  final _formKey = GlobalKey<FormState>();
  UserProvider userProvider = new UserProvider();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
      children: [Theme(
        data: Theme.of(context),
        child: Container(
            width: Responsive.isDesktop(context)
                ? MediaQuery.of(context).size.width * 0.3
                : Responsive.isTablet(context)
                    ? MediaQuery.of(context).size.width * 0.4
                    : MediaQuery.of(context).size.width * 0.7,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: secondaryColor,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding * 2),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Signup",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    Text(
                      "The safest site on the web for storing your data!",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(height: defaultPadding),
                    Form(
                      key: _formKey,
                      child: Column(children: [
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: "Please write your email address",
                            label: Text("email"),
                            fillColor: secondaryColor,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          validator: (value) => _validateEmail(value!),
                          onSaved: (value) => _email = value!,
                          onFieldSubmitted: (value) {
                            _signup();
                          },
                        ),
                        const SizedBox(
                          height: defaultPadding,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: "Please write your username",
                            label: Text("username"),
                            fillColor: secondaryColor,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          validator: (value) => _validateUsername(value!),
                          onSaved: (value) => _username = value!,
                          onFieldSubmitted: (value) {
                            _signup();
                          },
                        ),
                        const SizedBox(
                          height: defaultPadding,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            label: Text("password"),
                            hintText: "Please write your password",
                            fillColor: secondaryColor,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          validator: (value) => _validatePassword(value!),
                          onSaved: (value) => _password = value!,
                          onFieldSubmitted: (value) {
                            // _password = value;
                            _signup();
                          },
                          obscureText: true, //TODO: button obscureText
                        ),
                      ]),
                    ),
                    const SizedBox(height: defaultPadding),
                    GestureDetector(
                        onTap: () => _signup(),
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          child: Material(
                            child: Center(
                              child: Text(
                                "Signup",
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                            elevation: 24,
                            color: primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                          ),
                        ))
                  ],
                ),
              ),
            )),
      ),]
    ))));
  }

  _validateEmail(String value) {
    if(DEBUG_MODE) return null;
    if (value.isEmpty) {
      return "* " +
          AppLocalizations.of(context)!.translate("required")!.capitalize;
    }
    else if (EmailValidator.validate(value))
      return null;
    else
      return "* " +
          AppLocalizations.of(context)!
              .translate("enter_valid_email")!
              .capitalize;
  }

  _validateUsername(String value) {
    if(DEBUG_MODE) return null;
    if (value.isEmpty) {
      return "* " +
          AppLocalizations.of(context)!.translate("required")!.capitalize;
    }
    else return null;
  }

  _validatePassword(String value) {
    if(DEBUG_MODE) return null;
    if (value.isEmpty)
      return "* " +
          AppLocalizations.of(context)!.translate("required")!.capitalize;
    else if (value.length < 6)
      return AppLocalizations.of(context)!
          .translate("pwd_min_6_char")!
          .capitalize;
    else if (value.length > 15)
      return AppLocalizations.of(context)!
          .translate("pwd_max_25_char")!
          .capitalize;
    else
      return null;
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Processing Data'),
        duration: Duration(seconds: 1),
      ));

      User newUser = new User(
          id: "", // dummy ID
          username: _username,
          email: _email,);
      Response? response = await new ApiController().newUser(newUser, _password)!;

      if (response == null)
        FeedbackDialog(
            type: CoolAlertType.error,
            context:context, title:"UNKNOWN ERROR").show();

      if(response!.statusCode == HttpStatus.created){
        FeedbackDialog(
            type: CoolAlertType.success,
            context: context,
            title: "SUCCESS",
            message: "")
            .show().whenComplete(() => Navigator.pop(context));

      }
      else if(response!.statusCode == HttpStatus.conflict){
        if(response!.body == RESPONSE_ERROR_MAIL_USER_ALREADY_EXISTS)
          FeedbackDialog(
              type: CoolAlertType.error,
              context:context, title:"ERROR", message:"Already exists an account registered with this email address").show();

        else if(response!.body == RESPONSE_ERROR_MAIL_USER_ALREADY_EXISTS)
          FeedbackDialog(
              type: CoolAlertType.error,
              context:context, title:"ERROR", message:"Already exists an account registered with this username").show();
        else FeedbackDialog(
              type: CoolAlertType.error,
              context:context, title:"UNKNOWN ERROR").show();
      }
      else {
        FeedbackDialog(
            type: CoolAlertType.error,
            context:context, title:"UNKNOWN ERROR").show();
      }
    }
  }
}
