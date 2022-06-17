import 'dart:convert';

import 'package:admin/UI/responsive.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../../../../api/api_controller.dart';
import '../../../../models/document.dart';
import '../../../constants.dart';
import 'feedback_dialog.dart';

class PopupEditMetadata extends StatefulWidget {
  PopupEditMetadata({
    Key? key,
    required this.file,
  }) : super(key: key);

  Document file;

  @override
  _PopupEditMetadataState createState() => _PopupEditMetadataState();
}

class _PopupEditMetadataState extends State<PopupEditMetadata> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tagsEditingController = TextEditingController();

  String get _inputTags => _tagsEditingController.text.trim();

  late String _filename;
  String? _description;
  late List<String> _tags;
  late List<String> _suggestions = ["test1", "non", "ho", "fantasia"];
  late FocusNode _focusNode;

  refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    setState((){
      _filename = widget.file.name;
      if(widget.file.metadata.description != null)
        _description = widget.file.metadata.description;
      if(widget.file.metadata.tags != null)
        _tags = widget.file.metadata.tags!;
      else _tags = List.empty();
    });

    super.initState();
    _focusNode = FocusNode();
    _tagsEditingController.addListener(() => refreshState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _tagsEditingController.dispose();
  }

  void _pushData() async{
    _formKey.currentState!.save();
    Response? response = await new ApiController().setMetadata(widget.file.id, _filename, _description, _tags);
    switch (response!.statusCode) {
      case 200:
        {
          FeedbackDialog(
              type: CoolAlertType.success,
              context: context,
              title: "SUCCESS",
              message: "")
              .show().whenComplete(() => Navigator.pop(context));
        }
        break;
      default:
        {
          FeedbackDialog(
              type: CoolAlertType.error,
              context: context,
              title: "UNKNOWN ERROR",
              message: "")
              .show();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        backgroundColor: secondaryColor,
        scrollable: true,
        contentPadding: EdgeInsets.all(defaultPadding * 2),
        actionsPadding: EdgeInsets.all(defaultPadding * 2),
        content: Container(
          width: Responsive.metadataDialogWidth(context),
          height: Responsive.metadataDialogHeight(context),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      Text(
                        "\"" + widget.file.name + "\" | Edit Metadata",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: defaultPadding)),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        initialValue: widget.file.name,
                        decoration: InputDecoration(
                          label: Text("Name"),
                          fillColor: secondaryColor,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        onSaved: (value) => _filename = value!,
                        onFieldSubmitted: (value) {
                          _pushData();
                        },
                      ),
                      Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: defaultPadding)),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 3,
                        maxLength: 250,
                        initialValue: widget.file.metadata.description,
                        decoration: InputDecoration(
                          hintText: "Lorem ipsum...",
                          label: Text("Description"),
                          fillColor: secondaryColor,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        onSaved: (value) => _description = value!,
                        onFieldSubmitted: (value) {
                          _pushData();
                        },
                      ),
                    ]),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: defaultPadding),
                  ),
                  _tagsWidget()
                ],
              ),
            ),
          ),
        ),
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                onPressed: () { Navigator.of(context).pop();},
                child: Text("Close"),
              ),
            ),
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
                onPressed: () {_pushData();},
                child: Text("Save"),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Widget _tagsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_tags.length > 0) ...[
          Wrap(
            alignment: WrapAlignment.start,
            children: _tags
                .map((tag) => tagChip(
                      tag: tag,
                      onTap: () => _removeTag(tag),
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
        _tagsTextField(),
        Padding(
          padding: EdgeInsets.only(bottom: defaultPadding / 2),
        ),
        _displaySuggestions(),
      ],
    );
  }

  Widget _tagsTextField() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: _tagsEditingController,
              decoration: InputDecoration(
                hintText: "Add Tags",
                label: Text("Tags"),
                fillColor: secondaryColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
              // onChanged: (value) => _inputTags = value!,
              onSubmitted: (value) {
                _addTag(value);
                _tagsEditingController.clear();
                _focusNode.requestFocus();
              },
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_inputTags.isNotEmpty) ...[
            Padding(padding: EdgeInsets.only(right: defaultPadding)),
            InkWell(
              child: Icon(
                Icons.clear,
                color: Colors.grey.shade700,
              ),
              onTap: () => _tagsEditingController.clear(),
            )
          ],
        ],
      ),
    );
  }

  Widget tagChip({tag, onTap, action}) {
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
                  tag,
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

  _addTag(String tag) async {
    if (!_tags.contains(tag))
      setState(() {
        _tags.add(tag);
      });
  }

  _removeTag(String tag) async {
    if (_tags.contains(tag)) {
      setState(() {
        _tags.remove(tag);
      });
    }
  }

  _displaySuggestions() {
    return _suggestions.isNotEmpty
        ? _buildSuggestionWidget()
        : Text('No Labels added');
  }

  List<String> _filterSearchResultList() {
    if (_inputTags.isEmpty) return _suggestions;

    List<String> _tempList = [];
    for (int index = 0; index < _suggestions.length; index++) {
      String tag = _suggestions[index];
      if (tag.toLowerCase().trim().contains(_inputTags.toLowerCase())) {
        _tempList.add(tag);
      }
    }

    return _tempList;
  }

  Widget _buildSuggestionWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_filterSearchResultList().length > 0) ...[
        Text(
          'Suggestions',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: defaultPadding / 2),
        ),
        Wrap(
          alignment: WrapAlignment.start,
          children: _filterSearchResultList()
              .where((tag) => !_tags.contains(tag))
              .map((tag) => tagChip(
                    tag: tag,
                    onTap: () => _addTag(tag),
                    action: 'add',
                  ))
              .toList(),
        ),
      ]
    ]);
  }
}
