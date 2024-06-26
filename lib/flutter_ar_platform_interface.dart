import 'package:flutter_ar/flutter_ar_method_channel.dart';
import 'package:flutter_ar/flutter_ar_node.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterArPlatform extends PlatformInterface {
  FlutterArPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterArPlatform _instance = MethodChannelFlutterAr();

  static FlutterArPlatform get instance => _instance;

  static set instance(FlutterArPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init(int sceneId) async {
    throw UnimplementedError('init() has not been implemented.');
  }

  void addNode(int sceneId, FlutterARNode node) {
    throw UnimplementedError('addNode() has not been implemented.');
  }

  Future<void> scaleModel(int sceneId, double scale) async {
    throw UnimplementedError('scaleModel() has not been implemented.');
  }

  Future<void> moveModel(int sceneId, double x, double y, double z) async {
    throw UnimplementedError('moveModel() has not been implemented.');
  }

  Future<void> rotateModel(int sceneId, double x, double y, double z) async {
    throw UnimplementedError('rotateModel() has not been implemented.');
  }

  Future<void> rotateModelAroundAxis(int sceneId, double angle) async {
    throw UnimplementedError(
        'rotateModelAroundAxis() has not been implemented.');
  }

  Future<void> changeModelColor(int sceneId, String color) async {
    throw UnimplementedError('changeModelColor() has not been implemented.');
  }

  void dispose(int sceneId) {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
