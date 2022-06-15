import 'constants.dart';

class FileUtils{

  static String loadIcon(String mimeType){
    String key = "";
    if(mimeType.contains("text")) key = "text";
    else if(mimeType.contains("image")) key = "text";
    else if(mimeType.contains("video")) key = "video";
    else if(mimeType.contains("audio")) key = "audio";
    else key = mimeType;
    if(FILE_TYPE_ICONS_MAP.containsKey(key))
      return FILE_TYPE_ICONS_MAP[key]!;
    else
      return "unknown.svg";
  }
}