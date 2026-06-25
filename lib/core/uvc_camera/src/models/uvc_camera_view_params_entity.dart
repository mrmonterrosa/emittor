part of flutter_uvc_camera;

/// 自定义参数 可空  Custom parameters can be empty
class UVCCameraViewParamsEntity {
  /**
   *  if give custom minFps or maxFps or unsupported preview size
   *  set preview possible will fail
   *  **/
  /// camera preview min fps  10
  final int? minFps;

  /// camera preview max fps  60
  final int? maxFps;

  /// camera preview frame format 1 (MJPEG) or 0 (YUV)
  /// DEFAULT 1(MJPEG)  If preview fails and the screen goes black, please try switching to 0
  final int? frameFormat;

  ///  DEFAULT_BANDWIDTH = 1
  final double? bandwidthFactor;

  /// Custom preview width (e.g. 1280 or 1920)
  final int? previewWidth;

  /// Custom preview height (e.g. 720 or 1080)
  final int? previewHeight;

  const UVCCameraViewParamsEntity({
    this.minFps = 10,
    this.maxFps = 60,
    this.bandwidthFactor = 1.0,
    this.frameFormat = 1,
    this.previewWidth = 1280, // Default to 720p for better quality on TV
    this.previewHeight = 720,
  });

  Map<String, dynamic> toMap() {
    return {
      "minFps": minFps,
      "maxFps": maxFps,
      "frameFormat": frameFormat,
      "bandwidthFactor": bandwidthFactor,
      "previewWidth": previewWidth,
      "previewHeight": previewHeight,
    };
  }
}
