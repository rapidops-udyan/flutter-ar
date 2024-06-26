import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ar/flutter_ar.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    enterFullScreen();
  }

  @override
  void dispose() {
    exitFullScreen();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    const cameraPermission = Permission.camera;
    if (await cameraPermission.isDenied) {
      final status = await cameraPermission.request();
      _hasPermission = status.isGranted;
    } else {
      _hasPermission = true;
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _toggleArView() {
    setState(() {
      _showArView = !_showArView;
    });
  }

  void enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                if (_showArView && _hasPermission)
                  FlutterAr(
                    onViewCreated: (controller) {
                      controller.addNode(
                        FlutterARNode(fileLocation: 'assets/curtain.glb'),
                      );
                    },
                  )
                else if (!_hasPermission)
                  const Center(
                    child: Text('Camera permission not granted'),
                  ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _hasPermission ? _toggleArView : null,
                      child:
                          Text(_showArView ? 'Close AR View' : 'Open AR View'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
