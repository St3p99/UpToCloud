import 'package:admin/support/date_time_utils.dart';

import 'document.dart';

class DocumentMetadata {
  int id;
  Document? document;
  String? description;
  DateTime uploadedAt;
  String fileType;
  double fileSize;

  DocumentMetadata(
      {required this.id,
         this.document,
         this.description,
        required this.uploadedAt,
        required this.fileType,
      required this.fileSize});

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) {
    return DocumentMetadata(
      id: json['id'],
      document: json['document'] == null ? null : Document.fromJson(json["document"]),
      description: json['description'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      fileType: json['fileType'],
      fileSize: json['fileSize'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'document': document == null ? null : document!.toJson(),
        'description': description,
        'uploadedAt': uploadedAt,
        'fileType': fileType,
        'fileSize': fileSize,
      };

  @override
  String toString() {
    return 'DocumentMetadata{id: $id, document: $document, description: $description, uploadedAt: $uploadedAt, fileType: $fileType, fileSize: $fileSize,}';
  }
}
