enum PoseLandmarkType {
  nose,
  leftEyeInner,
  leftEye,
  leftEyeOuter,
  rightEyeInner,
  rightEye,
  rightEyeOuter,
  leftEar,
  rightEar,
  mouthLeft,
  mouthRight,
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftPinky,
  rightPinky,
  leftIndex,
  rightIndex,
  leftThumb,
  rightThumb,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
  leftHeel,
  rightHeel,
  leftFootIndex,
  rightFootIndex,
  unknown
}

class PoseLandmark {
  final PoseLandmarkType type;
  final double x;
  final double y;
  final double z;
  final double likelihood;

  PoseLandmark({
    required this.type,
    required this.x,
    required this.y,
    required this.z,
    required this.likelihood,
  });

  factory PoseLandmark.fromMap(Map<dynamic, dynamic> map) {
    final int typeInt = map['type'] as int? ?? -1;
    final PoseLandmarkType landmarkType = typeInt >= 0 && typeInt < PoseLandmarkType.values.length - 1
        ? PoseLandmarkType.values[typeInt]
        : PoseLandmarkType.unknown;

    return PoseLandmark(
      type: landmarkType,
      x: (map['x'] as num? ?? 0.0).toDouble(),
      y: (map['y'] as num? ?? 0.0).toDouble(),
      z: (map['z'] as num? ?? 0.0).toDouble(),
      likelihood: (map['likelihood'] as num? ?? 0.0).toDouble(),
    );
  }
}
