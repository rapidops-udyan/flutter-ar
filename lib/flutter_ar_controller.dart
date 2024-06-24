import 'package:flutter_ar/flutter_ar_node.dart';
import 'package:flutter_ar/flutter_ar_platform_interface.dart';

class FlutterARController {
  FlutterARController._({
    required this.sceneId,
  });

  final int sceneId;

  static Future<FlutterARController> init(
    int sceneId,
  ) async {
    await FlutterArPlatform.instance.init(sceneId);
    return FlutterARController._(sceneId: sceneId);
  }

  void addNode(FlutterARNode node) {
    FlutterArPlatform.instance.addNode(node);
  }

  void dispose() {
    FlutterArPlatform.instance.dispose(sceneId);
  }
}
