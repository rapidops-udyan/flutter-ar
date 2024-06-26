import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ar/flutter_ar_node.dart';

import 'flutter_ar_platform_interface.dart';

class MethodChannelFlutterAr extends FlutterArPlatform {
  static void registerWith() {
    FlutterArPlatform.instance = MethodChannelFlutterAr();
  }

  @visibleForTesting
  final methodChannel = const MethodChannel('sceneview_flutter');

  final Map<int, MethodChannel> _channels = {};

  MethodChannel _ensureChannelInitialized(int sceneId) {
    return _channels.putIfAbsent(sceneId, () {
      final channel = MethodChannel('scene_view_$sceneId');
      channel.setMethodCallHandler(
          (MethodCall call) => _handleMethodCall(call, sceneId));
      return channel;
    });
  }

  @override
  Future<void> init(int sceneId) async {
    final channel = _ensureChannelInitialized(sceneId);
    return channel.invokeMethod<void>('init');
  }

  @override
  void addNode(int sceneId, FlutterARNode node) {
    _channels[sceneId]?.invokeMethod('addNode', node.toMap());
  }

  @override
  Future<void> scaleModel(int sceneId, double scale) async {
    await _channels[sceneId]?.invokeMethod('scaleModel', {'scale': scale});
  }

  @override
  Future<void> moveModel(int sceneId, double x, double y, double z) async {
    await _channels[sceneId]
        ?.invokeMethod('moveModel', {'x': x, 'y': y, 'z': z});
  }

  @override
  Future<void> rotateModel(int sceneId, double x, double y, double z) async {
    await _channels[sceneId]
        ?.invokeMethod('rotateModel', {'x': x, 'y': y, 'z': z});
  }

  @override
  Future<void> rotateModelAroundAxis(int sceneId, double angle) async {
    await _channels[sceneId]
        ?.invokeMethod('rotateModelAroundAxis', {'angle': angle});
  }

  @override
  Future<void> changeModelColor(int sceneId, String color) async {
    await _channels[sceneId]
        ?.invokeMethod('changeModelColor', {'color': color});
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int sceneId) async {
    switch (call.method) {
      case 'onTrackingFailureChanged':
        // Handle tracking failure reason changes
        break;
      default:
        throw MissingPluginException();
    }
  }

  @override
  void dispose(int sceneId) {
    _channels.remove(sceneId);
  }
}
