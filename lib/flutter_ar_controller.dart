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

  Future<void> zoom(int sceneId, double scale) async {
    await FlutterArPlatform.instance.zoom(sceneId, scale);
  }

  Future<void> rotate(int sceneId, List<double> rotation) async {
    await FlutterArPlatform.instance.rotate(sceneId, rotation);
  }

  Future<void> move(int sceneId, List<double> position) async {
    await FlutterArPlatform.instance.move(sceneId, position);
  }

  void dispose() {
    FlutterArPlatform.instance.dispose(sceneId);
  }
}
