import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:other_print/page/sheet.dart';
import 'package:other_print/provider/sheet_document.dart';
import 'package:other_print/state/app_state.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  static List<NavOption> OPTIONS = [
    NavOption(name: "Create", icon: Icon(Icons.create)),
    NavOption(name: "Sheets", icon: Icon(Icons.table_view)),
    NavOption(name: "My Labels", icon: Icon(Icons.folder)),
    NavOption(name: "Settings", icon: Icon(Icons.settings)),
    NavOption(name: "Shop", icon: Icon(Icons.shopping_cart))
  ];

  onItemClick(BuildContext context, int i) {
    setState(() async {
      _currentIndex = i;

      if (OPTIONS[i].name == 'Sheets') {
        // final data = await SheetDocument.fetchGoogleSheet();

        await Navigator.push(context, MaterialPageRoute(
            builder: (BuildContext context) {
              return HookConsumer(
                builder: (context, ref, child) {
                  SheetDocument data = ref.watch(sheetsProvider).maybeWhen( data: (value) => value, orElse: () => SheetDocument(headers: [], rows: []));
                  return SheetWidget(data: data);
                },
              );
            }

        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var items = OPTIONS.map((item) {
      return BottomNavigationBarItem(
          icon: item.icon, label: item.name, backgroundColor: Colors.blue);
    }).toList();
    return BottomNavigationBar(
      items: items,
      currentIndex: _currentIndex,
      selectedItemColor: Colors.amber[800],
      onTap: (i) {
        onItemClick(context, i);
      },
    );
  }
}

class NavOption {
  String name;
  Icon icon;

  NavOption({required this.name, required this.icon});
}
