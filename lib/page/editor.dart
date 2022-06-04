import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_sketcher/image_sketcher.dart';

class EditorWidget extends StatefulWidget {
  final Uint8List image;
  final void Function(Uint8List updated) onUpdate;
  const EditorWidget(this.image, {Key? key, required this.onUpdate}) : super(key: key);

  @override
  _EditorWidgetState createState() => _EditorWidgetState();

}

class _EditorWidgetState extends State<EditorWidget> {
  final _imageKey = GlobalKey<ImageSketcherState>();
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text("Editor"),
      ),
      backgroundColor: Colors.grey,
      body: Stack(
        children: [
          ImageSketcher.memory(
            widget.image,
            key: _imageKey,
            scalable: true,
            initialStrokeWidth: 2,
            initialColor: Colors.black,
            initialPaintMode: PaintMode.freeStyle,
            controlPosition: Alignment.topCenter,
            isControllerOverlay: true,
            controllerAxis: ControllerAxis.vertical,
            controllerDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            controllerMargin: EdgeInsets.all(10),
            toolbarBGColor: Colors.white,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              margin: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      _imageKey.currentState?.clearAll();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  IconButton(
                    onPressed: () {
                      _imageKey.currentState?.undo();
                    },
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
                    onPressed: () {
                      _imageKey.currentState?.changePaintMode(PaintMode.line);
                    },
                    icon: const Icon(Icons.mode_edit),
                  ),
                  IconButton(
                    onPressed: () {
                      _imageKey.currentState?.changeBrushWidth(20);
                    },
                    icon: const Icon(Icons.brush),
                  ),
                  IconButton(
                    onPressed: () {
                      _imageKey.currentState?.addText('Abcd');
                    },
                    icon: const Icon(Icons.text_fields),
                  ),
                  IconButton(
                      onPressed: () async {
                        final image = await _imageKey.currentState?.exportImage();
                        widget.onUpdate(image!.buffer.asUint8List(0));

                      },
                      icon: const Icon(Icons.check)
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}