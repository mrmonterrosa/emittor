package com.mrmonterrosa.emittor.emittor

import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import com.mrmonterrosa.camera_usb.camera_usb.CameraUsbPluginRegistrar
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.pose.Pose
import com.google.mlkit.vision.pose.PoseDetection
import com.google.mlkit.vision.pose.PoseDetector
import com.google.mlkit.vision.pose.defaults.PoseDetectorOptions
import java.util.concurrent.atomic.AtomicBoolean

interface AppPoseDetectionListener {
    fun onPoseDetected(poseLandmarks: List<Map<String, Any>>)
}

class AppPoseDetector(private val listener: AppPoseDetectionListener) : CameraUsbPluginRegistrar.FrameListener {
    companion object {
        private const val TAG = "AppPoseDetector"
    }

    private var detector: PoseDetector? = null
    private var handlerThread: HandlerThread? = null
    private var backgroundHandler: Handler? = null
    private val isProcessing = AtomicBoolean(false)

    init {
        // Use STREAM_MODE for live video feeds
        val options = PoseDetectorOptions.Builder()
            .setDetectorMode(PoseDetectorOptions.STREAM_MODE)
            .build()
        detector = PoseDetection.getClient(options)

        // Run ML Kit inference on a dedicated background thread
        handlerThread = HandlerThread("AppPoseDetectionThread").apply {
            start()
            backgroundHandler = Handler(looper)
        }
        Log.i(TAG, "AppPoseDetector initialized with ML Kit")
    }

    override fun onFrame(data: ByteArray, width: Int, height: Int) {
        if (detector == null) return
        if (isProcessing.get()) {
            return // Drop frame if still processing the previous one
        }

        if (isProcessing.compareAndSet(false, true)) {
            backgroundHandler?.post {
                try {
                    // NV21 is standard for camera preview callbacks
                    val image = InputImage.fromByteArray(
                        data,
                        width,
                        height,
                        0, // Assuming 0 rotation for Android TV USB Camera
                        InputImage.IMAGE_FORMAT_NV21
                    )

                    detector?.process(image)
                        ?.addOnSuccessListener { pose ->
                            val landmarksList = mutableListOf<Map<String, Any>>()
                            for (landmark in pose.allPoseLandmarks) {
                                val map = HashMap<String, Any>()
                                map["type"] = landmark.landmarkType
                                map["x"] = landmark.position.x
                                map["y"] = landmark.position.y
                                map["z"] = landmark.position3D.z
                                map["likelihood"] = landmark.inFrameLikelihood
                                landmarksList.add(map)
                            }
                            listener.onPoseDetected(landmarksList)
                            isProcessing.set(false)
                        }
                        ?.addOnFailureListener { e ->
                            Log.e(TAG, "Pose detection failed: ${e.localizedMessage}")
                            isProcessing.set(false)
                        }
                } catch (e: Exception) {
                    Log.e(TAG, "Error in pose detection", e)
                    isProcessing.set(false)
                }
            }
        }
    }

    fun release() {
        try {
            detector?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Error closing pose detector", e)
        }
        detector = null

        handlerThread?.quitSafely()
        handlerThread = null
        backgroundHandler = null
        isProcessing.set(false)
        Log.i(TAG, "AppPoseDetector released")
    }
}
