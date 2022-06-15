import 'dart:collection';

import 'package:admin/UI/responsive.dart';
import 'package:admin/UI/screens/dashboard/components/drop_zone_widget.dart';
import 'package:admin/UI/screens/dashboard/components/dropped_file_widget.dart';
import 'package:admin/api/api_controller.dart';
import 'package:admin/support/extensions/string_capitalization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';

import '../../../../models/document.dart';
import '../../../../models/file_data_model.dart';
import '../../../../models/user.dart';
import '../../../behaviors/app_localizations.dart';
import '../../../constants.dart';
import 'error_dialog.dart';

class PopupUpload extends StatefulWidget {
  PopupUpload({
    Key? key,
  }) : super(key: key);


  @override
  _PopupUploadState createState() => _PopupUploadState();
}

class _PopupUploadState extends State<PopupUpload> {
  FileDataModel? file;

  refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          width: Responsive.uploadDialogWidth(context),
          height: Responsive.uploadDialogHeight(context),
          child: SingleChildScrollView(
              child: Center(
                child:Column(
                  children: [
                    // here DropZoneWidget is statefull widget file
                    Container(
                      height: 300,
                      child: DropZoneWidget(
                        onDroppedFile: (file) => setState(()=> this.file = file) ,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(bottom: defaultPadding),),
                    DroppedFileWidget(file: file)
                  ],
                )
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
                onPressed: () {
                  _upload();
                },
                child: Text("Confirm"),
              ),
            ),
          ])
        ],
      ),
    );
  }

  Future<void> _upload() async {
    StreamedResponse? response = await new ApiController().uploadFile(file!);
    switch (response!.statusCode) {
      case 200:{
        Navigator.pop(context);
      }break;
      default:{
        showDialog(
            context: context,
            builder: (context) => ErrorDialog(title:"UNKNOWN ERROR", message:"")
        );
      }
        break;
    }
  }


}
