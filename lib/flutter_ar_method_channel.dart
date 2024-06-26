import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ar/flutter_ar_node.dart';

import 'flutter_ar_platform_interface.dart';

/// An implementation of [SceneviewFlutterPlatform] that uses method channels.
class MethodChannelFlutterAr extends FlutterArPlatform {
  /// Registers the Android implementation of FlutterArPlatform.
  static void registerWith() {
    FlutterArPlatform.instance = MethodChannelFlutterAr();
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sceneview_flutter');

  MethodChannel? _channel;

  MethodChannel ensureChannelInitialized(int sceneId) {
    MethodChannel? channel = _channel;
    if (channel == null) {
      channel = MethodChannel('scene_view_$sceneId');
      channel.setMethodCallHandler(
          (MethodCall call) => _handleMethodCall(call, sceneId));
      _channel = channel;
    }
    return channel;
  }

  @override
  Future<void> init(int sceneId) async {
    final channel = ensureChannelInitialized(sceneId);
    return channel.invokeMethod<void>('init');
  }

  @override
  void addNode(FlutterARNode node) {
    _channel?.invokeMethod('addNode', node.toMap());
  }

  @override
  Future<void> zoom(int sceneId, double scale) async {
    final channel = ensureChannelInitialized(sceneId);
    await channel.invokeMethod('zoom', {'scale': scale});
  }

  @override
  Future<void> rotate(int sceneId, List<double> rotation) async {
    final channel = ensureChannelInitialized(sceneId);
    await channel.invokeMethod('rotate', {'rotation': rotation});
  }

  @override
  Future<void> move(int sceneId, List<double> position) async {
    final channel = ensureChannelInitialized(sceneId);
    await channel.invokeMethod('move', {'position': position});
  }

  Future<dynamic> _handleMethodCall(MethodCall call, int mapId) async {
    switch (call.method) {
      default:
        throw MissingPluginException();
    }
  }

  @override
  void dispose(int sceneId) {}
}
