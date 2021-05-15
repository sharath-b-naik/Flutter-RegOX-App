import 'dart:io';

import 'package:assign/Models/models.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Export {
  final List<Client> listOfClient;
  final String fileformat;
  final String startDateTime;
  final String endDateTime;

  Export.export(this.listOfClient, this.fileformat, this.startDateTime,
      this.endDateTime) {
    int startIndex;
    int endIndex;
    List<List<dynamic>> listOfClientData = [];

    // Convert List<Client> to List<<List<dynamic>>
    for (var client in listOfClient) {
      listOfClientData.add(client.lists());
    }

    //  Get Start Date index if present
    String start = "$startDateTime".split(" ")[0];
    for (int index = 0; index < listOfClientData.length; index++) {
      if (listOfClientData[index].contains(start)) {
        startIndex = index;
        break;
      }
    }

    // Get End Date index if present
    String end = "$endDateTime".split(" ")[0];
    for (int index = 0; index < listOfClientData.length; index++) {
      if (listOfClientData[index].contains(end)) {
        endIndex = index + 1;
      }
    }
    if (startIndex == null) {
      startIndex = 0;
    }
    if (endIndex == null) {
      endIndex = listOfClientData.length;
    }

    var finalDataToExport =
        listOfClientData.getRange(startIndex, endIndex).toList();

    _saveFile(finalDataToExport);
  }

  Future<bool> _saveFile(List<List<dynamic>> data) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";

          var folders = directory.path.split("/");
          for (int i = 1; i < folders.length; i++) {
            String folder = folders[i];
            if (folder != "Android") {
              newPath += "/$folder";
            } else {
              break;
            }
          }
          newPath += "/RegOX";
          directory = Directory(newPath);
        } else {
          return false;
        }
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      if (await directory.exists()) {
        if (fileformat == "xlsx") {
          var excel = Excel.createExcel();
          Sheet sheetObject = excel['Sheet1'];
          for (var x in data) {
            sheetObject.appendRow(x);
          }
          excel.encode().then((onValue) {
            File("${directory.path}/export.xlsx")
              ..createSync(recursive: true)
              ..writeAsBytesSync(onValue);
          });
        } else {
          File saveFile = File("${directory.path}/export.csv");
          // save here csv file
          String csv = ListToCsvConverter().convert(data);
          saveFile.writeAsString(csv);
        }
      }
    } catch (e) {}
    return false;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }
}
