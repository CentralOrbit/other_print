import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:other_print/provider/sheet_document.dart';

final sheetsProvider = FutureProvider<SheetDocument>((ref) async {
  final data = await SheetDocument.fetchGoogleSheet();
  return data;
});