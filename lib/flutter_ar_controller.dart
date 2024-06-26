import 'package:flutter_ar/flutter_ar_node.dart';
import 'package:flutter_ar/flutter_ar_platform_interface.dart';

class FlutterARController {
  FlutterARController._({
    required this.sceneId,
    required this.onTrackingFailureChanged,
  });

  final int sceneId;
  final Function(String?)? onTrackingFailureChanged;

  static Future<FlutterARController> init(
    int sceneId, {
    Function(String?)? onTrackingFailureChanged,
  }) async {
    await FlutterArPlatform.instance.init(sceneId);
    return FlutterARController._(
      sceneId: sceneId,
      onTrackingFailureChanged: onTrackingFailureChanged,
    );
  }

  void addNode(FlutterARNode node) {
    FlutterArPlatform.instance.addNode(sceneId, node);
  }

  Future<void> scaleModel(double scale) async {
    await FlutterArPlatform.instance.scaleModel(sceneId, scale);
  }

  Future<void> moveModel(double x, double y, double z) async {
    await FlutterArPlatform.instance.moveModel(sceneId, x, y, z);
  }

  Future<void> rotateModel(double x, double y, double z) async {
    await FlutterArPlatform.instance.rotateModel(sceneId, x, y, z);
  }

  Future<void> rotateModelAroundAxis(double angle) async {
    await FlutterArPlatform.instance.rotateModelAroundAxis(sceneId, angle);
  }

  Future<void> changeModelColor(String color) async {
    await FlutterArPlatform.instance.changeModelColor(sceneId, color);
  }

  void dispose() {
    FlutterArPlatform.instance.dispose(sceneId);
  }
}
