import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:another_brother/custom_paper.dart';
import 'package:another_brother/label_info.dart';
import 'package:another_brother/printer_info.dart';
import 'package:another_brother/type_b_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final controller = PageController (
      initialPage: 1
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Another Brother Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: PageView(children: [
        PrintPage(title: 'P Touch Cube XP Sample'),
      ]),

    );
  }
}


class PrintPage extends StatefulWidget {
  const PrintPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _PrintPagePageState createState() => _PrintPagePageState();
}

class _PrintPagePageState extends State<PrintPage> {

  void print(BuildContext context) async {

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("No printers found on your network."),
        ),
      ));

      return;
    }
    printInfo.macAddress = printers.single.macAddress;

    TextStyle style = TextStyle(
        color: Colors.black,
        fontSize: 30,
        fontWeight: FontWeight.bold
    );

    ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          fontSize:   style.fontSize,
          fontFamily: style.fontFamily,
          fontStyle:  style.fontStyle,
          fontWeight: style.fontWeight,
          textAlign: TextAlign.center,
          maxLines: 10,
        )
    )
      ..pushStyle(style.getTextStyle())
      ..addText("Hello World");

    ui.Paragraph paragraph = paragraphBuilder.build()..layout(ui.ParagraphConstraints(width: 300));
    PrinterStatus status = await printer.printText(paragraph);

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print(context),
        tooltip: 'Print',
        child: Icon(Icons.print),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}