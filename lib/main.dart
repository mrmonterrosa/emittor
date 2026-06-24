import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emittor/features/camera/presentation/camera_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: EmittorApp(),
    ),
  );
}

class EmittorApp extends StatelessWidget {
  const EmittorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emittor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CameraScreen(),
    );
  }
}
