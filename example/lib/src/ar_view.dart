import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                if (_showArView && _hasPermission)
                  FlutterAr(
                    onViewCreated: (controller) {
                      controller.addNode(FlutterARNode(
                        fileLocation: 'assets/curtain.glb',
                        position: KotlinFloat3(z: -1.0),
                        rotation: KotlinFloat3(x: 15),
                      ));
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
                      onPressed: _hasPermission
                          ? () {
                              setState(() {
                                _showArView = !_showArView;
                              });
                            }
                          : null,
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
