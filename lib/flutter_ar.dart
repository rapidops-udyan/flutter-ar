import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ar/flutter_ar_controller.dart';

class FlutterAr extends StatefulWidget {
  const FlutterAr({
    super.key,
    this.onViewCreated,
  });

  final Function(FlutterARController)? onViewCreated;

  @override
  State<FlutterAr> createState() => _FlutterArState();
}

class _FlutterArState extends State<FlutterAr> {
  final Completer<FlutterARController> _controller =
      Completer<FlutterARController>();

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'SceneView';
    // Pass parameters to the platform side.
    const Map<String, dynamic> creationParams = <String, dynamic>{};

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: onPlatformViewCreated,
    );
  }

  Future<void> onPlatformViewCreated(int id) async {
    final controller = await FlutterARController.init(id);
    _controller.complete(controller);
    widget.onViewCreated?.call(controller);
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _disposeController() async {
    final FlutterARController controller = await _controller.future;
    controller.dispose();
  }
}
