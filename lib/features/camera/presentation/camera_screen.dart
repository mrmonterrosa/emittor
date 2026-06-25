import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera_usb/camera_usb.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:emittor/features/camera/domain/pose_landmark.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  late UVCCameraController _cameraController;
  bool _permissionGranted = false;
  bool _isLoading = true;

  static const EventChannel _poseChannel = EventChannel('emittor/pose_stream');
  StreamSubscription? _poseSubscription;
  List<PoseLandmark> _poseLandmarks = [];

  @override
  void initState() {
    super.initState();
    _cameraController = UVCCameraController();
    _cameraController.msgCallback = (state) {
      debugPrint('Camera state: $state');
    };
    _checkPermission();
    _startPoseListener();
  }

  void _startPoseListener() {
    _poseSubscription = _poseChannel.receiveBroadcastStream().listen((event) {
      if (event is List) {
        final landmarks = event.map((e) => PoseLandmark.fromMap(e as Map)).toList();
        setState(() {
          _poseLandmarks = landmarks;
        });
      }
    }, onError: (err) {
      debugPrint('Pose stream error: $err');
    });
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
    _poseSubscription?.cancel();
    _cameraController.closeCamera();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emittor - UVC Camera & Pose Detection'),
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
                            return Stack(
                              children: [
                                Transform.scale(
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
                                ),
                                // Overlay coordinates panel
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Articulaciones detectadas (ML Kit): ${_poseLandmarks.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (_poseLandmarks.isNotEmpty) ...[
                                          Builder(
                                            builder: (context) {
                                              final nose = _poseLandmarks.firstWhere(
                                                (l) => l.type == PoseLandmarkType.nose,
                                                orElse: () => PoseLandmark(type: PoseLandmarkType.unknown, x: 0, y: 0, z: 0, likelihood: 0),
                                              );
                                              final leftShoulder = _poseLandmarks.firstWhere(
                                                (l) => l.type == PoseLandmarkType.leftShoulder,
                                                orElse: () => PoseLandmark(type: PoseLandmarkType.unknown, x: 0, y: 0, z: 0, likelihood: 0),
                                              );
                                              final rightShoulder = _poseLandmarks.firstWhere(
                                                (l) => l.type == PoseLandmarkType.rightShoulder,
                                                orElse: () => PoseLandmark(type: PoseLandmarkType.unknown, x: 0, y: 0, z: 0, likelihood: 0),
                                              );
                                              return Text(
                                                'Nariz: (${nose.x.toStringAsFixed(1)}, ${nose.y.toStringAsFixed(1)}) | Confianza: ${(nose.likelihood * 100).toStringAsFixed(0)}%\n'
                                                'Hombro Izq: (${leftShoulder.x.toStringAsFixed(1)}, ${leftShoulder.y.toStringAsFixed(1)}) | Confianza: ${(leftShoulder.likelihood * 100).toStringAsFixed(0)}%\n'
                                                'Hombro Der: (${rightShoulder.x.toStringAsFixed(1)}, ${rightShoulder.y.toStringAsFixed(1)}) | Confianza: ${(rightShoulder.likelihood * 100).toStringAsFixed(0)}%',
                                                style: const TextStyle(
                                                  color: Colors.greenAccent,
                                                  fontSize: 14,
                                                  fontFamily: 'monospace',
                                                ),
                                              );
                                            },
                                          ),
                                        ] else ...[
                                          const Text(
                                            'Esperando detección de pose...',
                                            style: TextStyle(
                                              color: Colors.amberAccent,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
