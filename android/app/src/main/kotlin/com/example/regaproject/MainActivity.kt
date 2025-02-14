// MainActivity.kt

package com.example.regaproject

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.Activity

class MainActivity : FlutterActivity() {
    private val CHANNEL = "live_camera_view"
    private val VIDEO_REQUEST_CODE = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "live_camera_view",
                LiveCameraViewFactory()
            )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "switchCamera" -> {
                    val isFrontCamera = call.argument<Boolean>("camera") ?: true
                    result.success(null)
                }
                "playRestVideo" -> {
                    playRestVideo()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playRestVideo() {
        val intent = Intent(this, VideoActivity::class.java)
        startActivityForResult(intent, VIDEO_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == VIDEO_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            val channel = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
            channel.invokeMethod("videoCompleted", null)
        }
    }
}