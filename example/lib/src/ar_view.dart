import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ar/flutter_ar.dart';
import 'package:flutter_ar/flutter_ar_controller.dart';
import 'package:flutter_ar/flutter_ar_node.dart';
import 'package:permission_handler/permission_handler.dart';

class ArView extends StatefulWidget {
  const ArView({super.key});

  @override
  State<ArView> createState() => _ArViewState();
}

class _ArViewState extends State<ArView> {
  bool _showArView = false;
  bool _hasPermission = false;
  FlutterARController? _flutterARController;
  double _scale = 1.0;
  double _rotation = 0.0;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _enterFullScreen();
  }

  @override
  void dispose() {
    _exitFullScreen();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    const cameraPermission = Permission.camera;
    if (await cameraPermission.isDenied) {
      final status = await cameraPermission.request();
      setState(() {
        _hasPermission = status.isGranted;
      });
    } else {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  void _toggleArView() {
    setState(() {
      _showArView = !_showArView;
    });
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  void _zoomIn() {
    setState(() {
      if (_scale < 1.0) {
        _scale += 0.1;
      }
    });
    _flutterARController!.zoom(_flutterARController!.sceneId, _scale);
  }

  void _zoomOut() {
    setState(() {
      if (_scale >= 0.2) {
        _scale -= 0.1;
      }
    });
    _flutterARController!.zoom(_flutterARController!.sceneId, _scale);
  }

  void _rotateLeft() {
    setState(() {
      _rotation -= 10;
    });
    _flutterARController!
        .rotate(_flutterARController!.sceneId, [_rotation, 0, 0]);
  }

  void _rotateRight() {
    setState(() {
      _rotation += 10;
    });
    _flutterARController!
        .rotate(_flutterARController!.sceneId, [_rotation, 0, 0]);
  }

  void _addNode() {
    if (_flutterARController != null) {
      _flutterARController!.addNode(
        FlutterARNode(fileLocation: 'assets/curtain.glb'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _hasPermission
          ? Stack(
              children: [
                if (_showArView)
                  FlutterAr(
                    onViewCreated: (controller) {
                      _flutterARController ??= controller;
                    },
                  ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _toggleArView,
                      child:
                          Text(_showArView ? 'Close AR View' : 'Open AR View'),
                    ),
                  ),
                ),
                if (_showArView) _buildControls(),
              ],
            )
          : const Center(
              child: Text('Camera permission not granted'),
            ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      right: 0,
      child: Column(
        children: [
          IconButton(
            onPressed: _addNode,
            icon: const Icon(
              Icons.place_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _zoomIn,
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _zoomOut,
            icon: const Icon(
              Icons.remove_circle_outline_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _rotateLeft,
            icon: const Icon(
              Icons.rotate_left_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _rotateRight,
            icon: const Icon(
              Icons.rotate_right_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
