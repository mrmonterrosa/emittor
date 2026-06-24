import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_uvc_camera/flutter_uvc_camera.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  UVCCameraController? _cameraController;
  bool _isInitialized = false;
  String _statusMessage = 'Presiona Iniciar para conectar la cámara UVC';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameraController = UVCCameraController();
      await _cameraController!.initialize();
      setState(() {
        _isInitialized = true;
        _statusMessage = 'Cámara inicializada correctamente';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al inicializar cámara: $e';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emittor - UVC Camera Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isInitialized && _cameraController != null)
              Expanded(
                child: UVCCameraView(
                  controller: _cameraController!,
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _initCamera,
                child: const Text('Re-inicializar Cámara'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
