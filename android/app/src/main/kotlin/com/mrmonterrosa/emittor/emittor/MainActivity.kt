package com.mrmonterrosa.emittor.emittor

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.hardware.usb.UsbManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.chenyeju.FlutterUVCCameraPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(FlutterUVCCameraPlugin())
        requestUsbPermissions()
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
