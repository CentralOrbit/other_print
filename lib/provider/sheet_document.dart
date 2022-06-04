import 'package:gsheets/gsheets.dart';

// TODO: Move this out
const _credentials = r'''
{
  "type": "service_account",
  "project_id": "",
  "private_key_id": "",
  "private_key": "",
  "client_email": "gsheets@jcdang.iam.gserviceaccount.com",
  "client_id": "109259781473640298967",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40jcdang.iam.gserviceaccount.com"
}
''';


const _spreadsheetId = '1vOiMXx-98NU5_5jflJgfkmmBV4RCAvDxyS3tTp8mXIQ';


extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but the callback has index as second argument
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  void forEachIndexed(void Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }
}


class SheetDocument {
  List<String> headers;
  List<Map<String, dynamic>> rows;
  SheetDocument({required this.headers, required this.rows});

  static fetchGoogleSheet() async {
    final gSheets = GSheets(_credentials);
    final gDocument = await gSheets.spreadsheet(_spreadsheetId);
    final gWorkSheet = gDocument.sheets.single;
    final gHeader = await gWorkSheet.cells.row(1);

    final dataHeaders = gHeader.map((column) => column.value).toList();
    final fRows =  await gWorkSheet.values.allRows();
    final dataRows = fRows.skip(1).map<Map<String, dynamic>>((List<String> tmpList) {
      final tmpMap = <String, dynamic>{};

      tmpList.forEachIndexed((String cValue, int c) {
        tmpMap.putIfAbsent(dataHeaders[c], () => cValue);
      });
      return tmpMap;
    }).toList();
    return SheetDocument(headers: dataHeaders, rows: dataRows);
  }
}