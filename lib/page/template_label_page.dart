import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:another_brother/label_info.dart';
import 'package:another_brother/printer_info.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as IMG;
import 'package:other_print/state/app_state.dart';
import 'dart:ui' as UI;
import '../provider/sheet_document.dart';
import 'editor.dart';

class TemplateLabelPage extends StatefulWidget {
  const TemplateLabelPage({Key? key}) : super(key: key);

  @override
  _TemplateLabelPageState createState() => _TemplateLabelPageState();
}

const List<int> kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
];

class _TemplateLabelPageState extends State<TemplateLabelPage> {
  static List<TabOption> OPTIONS = [
    TabOption(name: "AssetManagement"),
    TabOption(name: "Bar code (0.47\")"),
    TabOption(name: "Bar code (0.70\")"),
    TabOption(name: "Bar code (0.94\")"),
    TabOption(name: "CD/DVD Label"),
    TabOption(name: "Cabinet"),
    TabOption(name: "Cable"),
    TabOption(name: "Covid-19_0.94\""),
    TabOption(name: "Covid-19_1.4\""),
    TabOption(name: "Date"),
    TabOption(name: "File"),
    TabOption(name: "Frame"),
    TabOption(name: "Media"),
    TabOption(name: "Name")
  ];

  Uint8List? currentImage;

  Widget getTabForOption(TabOption optionName) {
    return ListView.builder(
        padding: const EdgeInsets.all(100),
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return RecordLabelWidget();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    var tabs = OPTIONS.map((tab) {
      return Tab(text: tab.name);
    }).toList();
    var tmpImage = currentImage;
    if (tmpImage == null) {

    }

    List<Widget> tabPages  = OPTIONS.map(getTabForOption).toList();
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: TabBar(
              isScrollable: true,
              indicatorColor: Colors.red,
              labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              tabs: tabs),
          body: TabBarView(children: tabPages),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            tooltip: 'Increment',
            icon: const Icon(Icons.add),
            label: const Text("New Label"),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}

class TabOption {
  String name;
  TabOption({required this.name});
}


class RecordLabelWidget extends StatefulWidget {
  @override
  State<RecordLabelWidget> createState() {
    return _RecordLabelState();
  }

}

class _RecordLabelState extends State<RecordLabelWidget> {
  Uint8List _currentImage = newBlank(300, 100);

  static Uint8List newBlank(width, height) {
    Uint8List blankBytes = const Base64Codec().decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=");
    // final Uint8List bytes = Uint8List.fromList(kTransparentImage);
    final IMG.Image emptyImg = IMG.decodeImage(blankBytes)!;
    var resizeImage = IMG.copyResize(emptyImg, width: 300, height: 100);
    var encodedImage = IMG.encodePng(resizeImage);
    return Uint8List.fromList(encodedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.memory(_currentImage),
        const SizedBox(height: 16),
        ElevatedButton(
            child: const Text("Edit"),
            onPressed: () async {
              await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditorWidget(_currentImage, onUpdate: (Uint8List updated) {
                  setState(() {
                    _currentImage = Uint8List.fromList(updated);
                    Navigator.pop(context);
                  });
                },),
              ));
            }
        ),
        ElevatedButton(
            child: const Text("Print"),
            onPressed: () async {
              var printer = Printer();
              var printInfo = PrinterInfo();
              printInfo.printerModel = Model.PT_P910BT;
              printInfo.printMode = PrintMode.FIT_TO_PAGE;
              printInfo.isAutoCut = true;
              printInfo.port = Port.BLUETOOTH;
              printInfo.labelNameIndex = PT.ordinalFromID(PT.W36.getId());
              await printer.setPrinterInfo(printInfo);

              var printers = await printer.getBluetoothPrinters([Model.PT_P910BT.getName()]);

              if (printers.isEmpty) {
                // Show a message if no printers are found.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("No printers found on your network."),
                  ),
                ));

                return;
              }
              printInfo.macAddress = printers.single.macAddress;
              UI.decodeImageFromList(_currentImage, (result) {
                printer.printImage(result);
              });
            }
        ),
        ElevatedButton(
            child: const Text("Print Bulk..."),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(
                  builder: (BuildContext context) {
                    return HookConsumer(
                      builder: (context, ref, child) {
                        SheetDocument data = ref.watch(sheetsProvider).maybeWhen( data: (value) => value, orElse: () => SheetDocument(headers: [], rows: []));
                        return Scaffold(
                            appBar: AppBar(title: const Text("Google Sheets")),
                            backgroundColor: Colors.amber,
                            body: ListView.builder(
                                itemCount: data.rows.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                      child: Row(
                                          children: data.headers.map((header) {
                                            final tx = data.rows[index];
                                            return SizedBox(
                                                height: 15,
                                                width: 100,
                                                child: Text('${tx[header]}'));
                                          }
                                          ).toList()));
                                }),
                          floatingActionButton: FloatingActionButton(
                              tooltip: "Print Bulk",
                              onPressed: () async {
                                  var printer = Printer();
                                  var printInfo = PrinterInfo();
                                  printInfo.printerModel = Model.PT_P910BT;
                                  printInfo.printMode = PrintMode.FIT_TO_PAGE;
                                  printInfo.isAutoCut = false;
                                  printInfo.isHalfCut = true;
                                  printInfo.port = Port.BLUETOOTH;
                                  printInfo.labelNameIndex = PT.ordinalFromID(PT.W36.getId());
                                  await printer.setPrinterInfo(printInfo);

                                  var printers = await printer.getBluetoothPrinters([Model.PT_P910BT.getName()]);

                                  if (printers.isEmpty) {
                                    return;
                                  }
                                  printInfo.macAddress = printers.single.macAddress;
                                  IMG.Image decodedOriginalImage = IMG.decodePng(_currentImage)!;

                                  List.generate(data.rows.length, (index) {
                                    if (index == data.rows.length - 1) {
                                      printInfo.isAutoCut = true;
                                      printInfo.isHalfCut = false;
                                    }
                                    IMG.Image decodedCopy = IMG.Image.from(decodedOriginalImage);
                                    IMG.Image newResult = IMG.drawStringCentered(decodedCopy, IMG.arial_48, data.rows[index]['firstName'], color: 0xFF000000 );
                                    final pngResult = IMG.encodePng(newResult);

                                    UI.decodeImageFromList(Uint8List.fromList(pngResult), (printImage) async {
                                      await printer.printImage(printImage);
                                    });
                                  });
                              },
                         backgroundColor: Colors.red,
                          child: const Icon(Icons.print),
                        ));
                      },
                    );
                  }

              ));
            }
        ),
      ],
    );
  }

}