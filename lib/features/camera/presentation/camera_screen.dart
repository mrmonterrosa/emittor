import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';
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
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _permissionGranted = true;
        _isLoading = false;
      });
    } else {
      final result = await Permission.camera.request();
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
                            return UVCCameraView(
                              cameraController: _cameraController,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
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
