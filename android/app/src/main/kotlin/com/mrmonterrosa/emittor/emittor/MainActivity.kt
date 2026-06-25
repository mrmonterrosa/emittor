package com.mrmonterrosa.emittor.emittor

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import com.mrmonterrosa.camera_usb.camera_usb.CameraUsbPluginRegistrar

class MainActivity : FlutterActivity() {
    private var eventSink: EventChannel.EventSink? = null
    private var appPoseDetector: AppPoseDetector? = null

    private val poseStreamHandler = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
            startPoseDetection()
        }

        override fun onCancel(arguments: Any?) {
            stopPoseDetection()
            eventSink = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the EventChannel in the app's binary messenger
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "emittor/pose_stream")
            .setStreamHandler(poseStreamHandler)

        requestUsbPermissions()
    }

    private fun startPoseDetection() {
        if (appPoseDetector == null) {
            appPoseDetector = AppPoseDetector(object : AppPoseDetectionListener {
                override fun onPoseDetected(poseLandmarks: List<Map<String, Any>>) {
                    runOnUiThread {
                        eventSink?.success(poseLandmarks)
                    }
                }
            })
        }
        CameraUsbPluginRegistrar.frameListener = appPoseDetector
    }

    private fun stopPoseDetection() {
        CameraUsbPluginRegistrar.frameListener = null
        appPoseDetector?.release()
        appPoseDetector = null
    }

    override fun onDestroy() {
        stopPoseDetection()
        super.onDestroy()
    }

    private fun requestUsbPermissions() {
        val usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
        val deviceList = usbManager.deviceList
        for (device in deviceList.values) {
            if (!usbManager.hasPermission(device)) {
                var isVideo = false
                for (i in 0 until device.interfaceCount) {
                    val usbInterface = device.getInterface(i)
                    if (usbInterface.interfaceClass == 14) { // 14 is USB_CLASS_VIDEO
                        isVideo = true
                        break
                    }
                }
                if (isVideo) {
                    val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        PendingIntent.FLAG_MUTABLE
                    } else {
                        0
                    }
                    val permissionIntent = PendingIntent.getBroadcast(
                        this,
                        0,
                        Intent("com.mrmonterrosa.emittor.USB_PERMISSION"),
                        flags
                    )
                    usbManager.requestPermission(device, permissionIntent)
                }
            }
        }
    }
}
