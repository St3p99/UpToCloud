import 'dart:collection';

import 'package:admin/UI/responsive.dart';
import 'package:admin/api/api_controller.dart';
import 'package:admin/support/extensions/string_capitalization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../../models/document.dart';
import '../../../../models/user.dart';
import '../../../behaviors/app_localizations.dart';
import '../../../constants.dart';

class PopupShare extends StatefulWidget {
  PopupShare({
    Key? key,
    required this.files,
  }) : super(key: key);

  List<Document> files;

  @override
  _PopupShareState createState() => _PopupShareState();
}

class _PopupShareState extends State<PopupShare> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _typeAheadController = TextEditingController();

  String get _inputTags => _typeAheadController.text.trim();

  late List<User> _selectedUsers = List.empty(growable: true);

  HashSet<User> _suggestions = HashSet.from({
    User(id: "2", username: 'Alice', email: 'alice@example.com'),
    User(id: "3", username: 'Bob', email: 'bob@example.com'),
    User(id: "4", username: 'Charlie', email: 'charlie123@gmail.com'),
    User(id: "2", username: 'Alice', email: 'alice@example.com'),
    User(id: "3", username: 'Bob', email: 'bob@example.com'),
    User(id: "4", username: 'Charlie', email: 'charlie123@gmail.com'),
    User(id: "2", username: 'Alice', email: 'alice@example.com'),
    User(id: "3", username: 'Bob', email: 'bob@example.com'),
    User(id: "4", username: 'Charlie', email: 'charlie123@gmail.com'),
    User(id: "2", username: 'Alice', email: 'alice@example.com'),
    User(id: "3", username: 'Bob', email: 'bob@example.com'),
    User(id: "4", username: 'Charlie', email: 'charlie123@gmail.com'),
  });

  late FocusNode _focusNode;

  refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _typeAheadController.addListener(() => refreshState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _typeAheadController.dispose();
  }

  void _pushData() {}

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        scrollable: true,
        contentPadding: EdgeInsets.all(defaultPadding * 2),
        actionsPadding: EdgeInsets.all(defaultPadding * 2),
        backgroundColor: secondaryColor,
        content: Container(
          width: Responsive.shareDialogWidth(context),
          height: Responsive.shareDialogHeight(context),
          child: SingleChildScrollView(
              child: Center(
            child: Form(
              key: _formKey,
              child: Column(children: [
                Text(
                  widget.files.length > 1
                      ? "Share " + widget.files.length.toString() + " files"
                      : "Share \"" + widget.files.first.name+"\"",
                  style: Theme.of(context).textTheme.headline6,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: defaultPadding),
                ),
                if (_selectedUsers.length > 0) ...[
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: _selectedUsers
                        .map((user) => chip(
                              user: user,
                              onTap: () => _removeUser(user),
                              action: 'remove',
                            ))
                        .toSet()
                        .toList(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: defaultPadding / 2),
                  ),
                ] else
                  SizedBox(),
                TypeAheadFormField(
                  validator: (value) => _validateEmail(value!),
                  textFieldConfiguration: TextFieldConfiguration(
                    onChanged: (String value) async {
                      if (_getSuggestions(value).isNotEmpty) return;
                      if (_validateEmail(value)==null) {
                        User? user = await _getUser(value);
                        if (user != null) _suggestions.add(user);
                      }
                    },
                    onSubmitted: (String value) async{
                      if (_formKey.currentState!.validate() && _suggestions.isNotEmpty){
                        _addUser(_getSuggestions(value).first);
                        _typeAheadController.clear();
                      }
                    },
                    controller: _typeAheadController,
                    focusNode: _focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Add users',
                      fillColor: secondaryColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return await _getSuggestions(pattern);
                  },
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      shadowColor: Colors.white70,
                      constraints: BoxConstraints(
                          maxHeight: Responsive.shareDialogHeight(context)*5/4)),
                  noItemsFoundBuilder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'No Items Found!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).disabledColor,
                            fontSize: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .fontSize),
                      ),
                    );
                  },
                  itemBuilder: (context, User suggestion) {
                    return ListTile(
                      leading: SvgPicture.asset(
                        "icons/menu_profile.svg",
                        color: Colors.white,
                        height: 20,
                      ),
                      title: Text(suggestion.username.capitalize),
                      subtitle: Text(
                        suggestion.email.toLowerCase(),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: Colors.white54),
                      ),
                    );
                  },
                  onSuggestionSelected: (User suggestion) {
                    _addUser(suggestion);
                    _typeAheadController.clear();
                  },
                ),
                // Padding(
                //     padding: EdgeInsets.symmetric(vertical: defaultPadding)),
              ]),
            ),
          )),
        ),
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            // ButtonTheme(
            //   minWidth: 25.0,
            //   height: 25.0,
            //   child: ElevatedButton(
            //     style: TextButton.styleFrom(
            //       padding: EdgeInsets.symmetric(
            //         horizontal: defaultPadding * 1.5,
            //         vertical:
            //         defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
            //       ),
            //     ),
            //     onPressed: () {},
            //     child: Text("Close"),
            //   ),
            // ),
            ButtonTheme(
              minWidth: 25.0,
              height: 25.0,
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical:
                    defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                  ),
                ),
                onPressed: () {},
                child: Text("Confirm"),
              ),
            ),
          ])
        ],
      ),
    );
  }

  _validateEmail(String? value) {
    return value != null && EmailValidator.validate(value)
        ? null
        : "* " +
            AppLocalizations.of(context)!
                .translate("enter_valid_email")!
                .capitalize;
  }

  Future<User?> _getUser(String email) async {
    User fakeUser =
        new User(id: "100", username: email.split("@").first, email: email);
    if (_suggestions.contains(fakeUser))
      return Future.value(_suggestions.lookup(fakeUser));
    else
      return fakeUser;
    // await ApiController.sharedInstance!.searchUserByEmail(email);
  }

  HashSet<User> _getSuggestions(String pattern) {
    if (_inputTags.isEmpty) return _suggestions;

    HashSet<User> _tempList = new HashSet();
    _suggestions.forEach((element) {
      String username = element.username;
      String email = element.email;
      if (email.toLowerCase().trim().contains(_inputTags.toLowerCase()) ||
          username.toLowerCase().trim().contains(_inputTags.toLowerCase())) {
        _tempList.add(element);
      }
    });
    return _tempList;
  }

  Widget chip({required User user, required onTap, required action}) {
    return InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 5.0,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Theme.of(context).textTheme.bodyText1!.fontSize,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: CircleAvatar(
                backgroundColor: primaryColor,
                radius: 8.0,
                child: Icon(
                  action == 'add' ? Icons.add : Icons.clear,
                  size: 10.0,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ));
  }

  _addUser(User user) async {
    if (!_selectedUsers.contains(user))
      setState(() {
        _selectedUsers.add(user);
      });
  }

  _removeUser(User user) async {
    if (_selectedUsers.contains(user)) {
      setState(() {
        _selectedUsers.remove(user);
      });
    }
  }
}
