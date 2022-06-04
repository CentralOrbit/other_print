import 'package:flutter_test/flutter_test.dart';
import 'package:other_print/provider/sheet_document.dart';

void main() {
  test("Sheet Test", () async {
    final sd = await SheetDocument.fetchGoogleSheet();
    expect(sd.headers.length , 2);
    expect(sd.rows.length, 26);
  });
}
