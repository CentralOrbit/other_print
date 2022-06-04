import 'package:flutter/material.dart';
import 'package:other_print/provider/sheet_document.dart';

class SheetWidget extends StatefulWidget {
  SheetDocument data;
  SheetWidget({Key? key, required this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SheetState();
  }

}

class _SheetState extends State<SheetWidget> {

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(title: const Text("Google Sheets")),
        backgroundColor: Colors.amber,
        body: ListView.builder(
            itemCount: widget.data.rows.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                    color: Colors.black12,
                    child: Row( children: widget.data.headers.map((header) {
                  return SizedBox(
                      height: 30,
                      width: 100,
                      child: Text('${header}'));
                }).toList()));
              }
              final Color color = Colors.primaries[index % Colors.primaries.length];
              return Container(
                  color: color,
                  child: Row(
                    children: widget.data.headers.map((header) {
                      final tx = widget.data.rows[index - 1];
                      return SizedBox(
                          height: 15,
                          width: 100,
                          child: Text('${tx[header]}'));
                    }
                  ).toList()));
            })
    );
  }
}


