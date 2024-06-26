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

  Future<void> init(int sceneId) async {
    await instance.init(sceneId);
  }

  void addNode(FlutterARNode node) {
    instance.addNode(node);
  }

  Future<void> zoom(int sceneId, double scale) async {
    await instance.zoom(sceneId, scale);
  }

  Future<void> rotate(int sceneId, List<double> rotation) async {
    await instance.rotate(sceneId, rotation);
  }

  Future<void> move(int sceneId, List<double> position) async {
    await instance.move(sceneId, position);
  }

  void dispose(int sceneId) {
    instance.dispose(sceneId);
  }
}
