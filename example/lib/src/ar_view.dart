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
  double _rotationY = 0.0;
  double _positionX = 0.0;
  double _positionY = 0.0;
  double _positionZ = 0.0;
  String _currentColor = '#FFFFFF'; // White

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

  void _scaleModel(double scale) {
    setState(() {
      _scale = scale;
    });
    _flutterARController?.scaleModel(_scale);
  }

  void _moveModel(double x, double y, double z) {
    setState(() {
      _positionX = x;
      _positionY = y;
      _positionZ = z;
    });
    _flutterARController?.moveModel(_positionX, _positionY, _positionZ);
  }

  void _rotateModel(double angle) {
    setState(() {
      _rotationY = angle;
    });
    _flutterARController?.rotateModelAroundAxis(_rotationY);
  }

  void _changeModelColor(String color) {
    setState(() {
      _currentColor = color;
    });
    _flutterARController?.changeModelColor(_currentColor);
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
                const Center(
                    child: Text(
                  'Flutter AR',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                )),
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
                      child: Text(_showArView ? 'Close' : 'Start'),
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
      right: 10,
      left: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () =>
                    _moveModel(_positionX, _positionY + 0.1, _positionZ),
                icon: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Colors.black,
                ),
                style: IconButton.styleFrom(backgroundColor: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () =>
                        _moveModel(_positionX - 0.1, _positionY, _positionZ),
                    icon: const Icon(
                      Icons.keyboard_arrow_left_rounded,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () =>
                        _moveModel(_positionX + 0.1, _positionY, _positionZ),
                    icon: const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () =>
                    _moveModel(_positionX, _positionY - 0.1, _positionZ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                onPressed: _addNode,
                icon: const Icon(
                  Icons.add_location_alt_rounded,
                  color: Colors.black,
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => _scaleModel(_scale + 0.1),
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.black,
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => _scaleModel(_scale - 0.1),
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Colors.black,
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => _rotateModel(_rotationY + 5),
                icon: const Icon(
                  Icons.rotate_right_rounded,
                  color: Colors.black,
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => _rotateModel(_rotationY - 5),
                icon: const Icon(
                  Icons.rotate_left_rounded,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
