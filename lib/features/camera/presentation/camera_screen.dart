import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera_usb/camera_usb.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  late UVCCameraController _cameraController;
  bool _permissionGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cameraController = UVCCameraController();
    _cameraController.msgCallback = (state) {
      debugPrint('Camera state: $state');
    };
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    debugPrint('Checking permissions...');
    final cameraStatus = await Permission.camera.status;
    debugPrint('Camera permission: $cameraStatus');
    
    if (cameraStatus.isGranted) {
      debugPrint('Camera permission granted. Rendering camera view...');
      setState(() {
        _permissionGranted = true;
        _isLoading = false;
      });
    } else {
      debugPrint('Camera permission not granted. Requesting...');
      final result = await Permission.camera.request();
      debugPrint('Request result -> Camera: ${result.isGranted}');
      
      setState(() {
        _permissionGranted = result.isGranted;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController.closeCamera();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emittor - UVC Camera Test'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _permissionGranted
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Transform.scale(
                              scaleX: -1, // Espejar horizontalmente
                              child: UVCCameraView(
                                cameraController: _cameraController,
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                params: const UVCCameraViewParamsEntity(
                                  previewWidth: 1280, // 720p HD
                                  previewHeight: 720,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      const Text(
                        'Se requiere permiso de cámara para continuar',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _checkPermission,
                        child: const Text('Otorgar Permiso'),
                      ),
                    ],
                  ),
      ),
    );
  }
}
