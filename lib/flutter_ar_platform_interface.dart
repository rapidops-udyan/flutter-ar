import 'package:flutter_ar/flutter_ar_method_channel.dart';
import 'package:flutter_ar/flutter_ar_node.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterArPlatform extends PlatformInterface {
  /// Constructs a SceneviewFlutterPlatform.
  FlutterArPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterArPlatform _instance = MethodChannelFlutterAr();

  /// The default instance of [SceneviewFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelSceneViewFlutter].
  static FlutterArPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SceneviewFlutterPlatform] when
  /// they register themselves.
  static set instance(FlutterArPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init(int sceneId) {
    throw UnimplementedError('init() has not been implemented.');
  }

  void addNode(FlutterARNode node) {
    throw UnimplementedError('addNode() has not been implemented.');
  }

  void dispose(int sceneId) {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
