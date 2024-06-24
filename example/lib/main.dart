import 'package:flutter/material.dart';
import 'package:flutter_ar/flutter_ar.dart';
import 'package:flutter_ar/flutter_ar_node.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Flutter AR'),
        ),
        body: FutureBuilder(
          future: _checkPermission(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.data == true) {
              return Stack(
                children: [
                  FlutterAr(
                    onViewCreated: (controller) {
                      debugPrint('flutter: onViewCreated');
                      controller.addNode(FlutterARNode(
                        fileLocation: 'assets/curtain.glb',
                        position: KotlinFloat3(z: -1.0),
                        rotation: KotlinFloat3(x: 15),
                      ));
                    },
                  ),
                ],
              );
            } else if (snapshot.data == false) {
              return const Center(
                child: Text('Permission not Granted'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> _checkPermission() async {
    bool hasPermission = true;
    const cameraPermission = Permission.camera;
    if (await cameraPermission.isDenied) {
      await cameraPermission.request();
      hasPermission = true;
    }
    return hasPermission;
  }
}
