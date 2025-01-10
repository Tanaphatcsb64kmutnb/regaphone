//MainActivity
package com.example.regaproject

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "live_camera_view",
                LiveCameraViewFactory()
            )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "live_camera_view")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "switchCamera" -> {
                        val isFrontCamera = call.argument<Boolean>("camera") ?: true
                       // LiveCameraPlatformView.switchCamera(isFrontCamera) // เรียกใช้ผ่าน companion object
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}