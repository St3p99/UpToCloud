import 'dart:collection';
import 'dart:html';

import 'package:admin/models/document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../File.dart';
import '../../../../api/api_controller.dart';
import '../../../../support/constants.dart';
import '../../../constants.dart';
import 'my_abstract_datatable_source.dart';

class FileDataTableSource extends MyAbstractDataTableSource{
  ApiController api = new ApiController();
  bool sortNameAsc = true;
  bool sortDateAsc = true;
  bool sortSizeAsc = true;
  @override
  DataRow? getRow(int index) {
    Document file = result!.elementAt(index);
    return DataRow(
      selected: selectedFiles.contains(index),
      onSelectChanged: (isSelected) {
        onSelected(index, isSelected!);
        notifyListeners();
      },
      cells: [
        DataCell(
          Container(
            constraints: BoxConstraints(minWidth: 200),
            child: Row(
              children: [
                SvgPicture.asset(
                  "icons/filetype/"+file.icon!,
                  height: 30,
                  width: 30,
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Text(file.name),
                ),
              ],
            ),
          ),
        ),
        DataCell(Container(
            constraints: BoxConstraints(minWidth: 200),
            child: Text(file.metadata.uploadedAt.toString().split(".").first))),
        DataCell(Container(
            constraints: BoxConstraints(minWidth: 200),
            child: Text(file.getFileSize()))),
        // DataCell(Options(file: file,))
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => result!.length;

  @override
  int get selectedRowCount => selectedFiles.length;


  onSelected(int index, bool isSelected){
    if (isSelected) {
      selectedFiles.add(index);
    } else {
      selectedFiles.remove(index);
    }
  }

  @override
  Future<List<Document>>? pullData() async {
    List<Document>? recentFiles = await api.loadRecentFilesOwned();
    recentFiles!.forEach((file) {file.loadIcon();});
    result = recentFiles;
    notifyListeners();
    return result!;
  }

  @override
  void sort(int columnIndex, bool sortAscending) {
    switch(columnIndex){
      case 0: {
        if (columnIndex == sortColumnIndex) {
          sortAsc = sortNameAsc = sortAscending;
        } else {
          sortColumnIndex = columnIndex;
          sortAsc = sortNameAsc;
        }
        if (sortAscending)
          result!.sort((a, b) => a.name.compareTo(b.name));
        else
          result!.sort((a, b) => b.name.compareTo(a.name));
      } break;
      case 1: {
        if (columnIndex == sortColumnIndex) {
          sortAsc = sortDateAsc = sortAscending;
        } else {
          sortColumnIndex = columnIndex;
          sortAsc = sortDateAsc;
        }
        if (sortAscending)
          result!.sort((a, b) => a.metadata.uploadedAt.compareTo(b.metadata.uploadedAt));
        else
          result!.sort((a, b) => b.metadata.uploadedAt.compareTo(a.metadata.uploadedAt));
      } break;
      case 2: {
        if (columnIndex == sortColumnIndex) {
          sortAsc = sortSizeAsc = sortAscending;
        } else {
          sortColumnIndex = columnIndex;
          sortAsc = sortSizeAsc;
        }
        if (sortAscending)
          result!.sort((a, b) => a.metadata.fileSize.compareTo(b.metadata.fileSize));
        else
          result!.sort((a, b) => b.metadata.fileSize.compareTo(a.metadata.fileSize));
      } break;
      default: {
        return;
      }
    }
    notifyListeners();
  }
}
