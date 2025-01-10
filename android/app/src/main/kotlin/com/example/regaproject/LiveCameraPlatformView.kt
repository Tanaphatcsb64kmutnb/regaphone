//LiveCameraPlatformView.kt
package com.example.regaproject 

import android.content.Context
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ProcessLifecycleOwner
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import android.util.Size
import com.google.mediapipe.tasks.vision.core.RunningMode


class LiveCameraPlatformView(
    private val context: Context,
    private var isFrontCamera: Boolean
) : PlatformView {

    private val container: FrameLayout
    private val cameraExecutor: ExecutorService

    private lateinit var previewView: PreviewView
    private lateinit var overlayView: OverlayView
    private lateinit var poseLandmarkerHelper: PoseLandmarkerHelper

    init {
        container = FrameLayout(context)

        previewView = PreviewView(context).apply {
            this.implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        }

        overlayView = OverlayView(context, null)
        overlayView.setBackgroundColor(android.graphics.Color.TRANSPARENT)

        container.addView(
            previewView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )
        container.addView(
            overlayView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        cameraExecutor = Executors.newSingleThreadExecutor()

        poseLandmarkerHelper = PoseLandmarkerHelper(
            context = context,
            runningMode = RunningMode.LIVE_STREAM,
            currentModel = PoseLandmarkerHelper.MODEL_POSE_LANDMARKER_LITE,
            currentDelegate = PoseLandmarkerHelper.DELEGATE_GPU,
            poseLandmarkerHelperListener = object : PoseLandmarkerHelper.LandmarkerListener {
                override fun onError(error: String) {
                    Log.e("LiveCameraPlatformView", "Mediapipe Error: $error")
                }

                override fun onResults(resultBundle: PoseLandmarkerHelper.ResultBundle) {
                    val poseResult = resultBundle.results.firstOrNull() ?: return
                    container.post {
                        overlayView.setResults(
                            poseResult,
                            resultBundle.inputImageHeight,
                            resultBundle.inputImageWidth
                        )
                        overlayView.invalidate()
                    }
                }
            }
        )

        startCamera()
    }

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()
            bindCameraUseCases(cameraProvider)
        }, ContextCompat.getMainExecutor(context))
    }

    private fun bindCameraUseCases(cameraProvider: ProcessCameraProvider) {
        cameraProvider.unbindAll()

        val preview = Preview.Builder()
            .build()
            .also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }

        val imageAnalysis = ImageAnalysis.Builder()
            // ลด resolution เพื่อให้ Mediapipe ทำงานเร็วขึ้น
            .setTargetResolution(Size(640, 480))
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()

        imageAnalysis.setAnalyzer(cameraExecutor) { imageProxy ->
            Log.d("LiveCamera", "Analyzer received a frame. width=${imageProxy.width}, height=${imageProxy.height}")
            try {
                poseLandmarkerHelper.detectLiveStream(imageProxy, isFrontCamera)
            } catch (e: Exception) {
                Log.e("LiveCamera", "Error analyzing frame: ${e.message}")
            }
        }

        val cameraSelector = if (isFrontCamera) {
            CameraSelector.DEFAULT_FRONT_CAMERA
        } else {
            CameraSelector.DEFAULT_BACK_CAMERA
        }

        try {
            cameraProvider.bindToLifecycle(
                ProcessLifecycleOwner.get(),
                cameraSelector,
                preview,
                imageAnalysis
            )
        } catch (exc: Exception) {
            Log.e("LiveCamera", "Use case binding failed", exc)
        }

        overlayView.post { overlayView.bringToFront() }
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        cameraExecutor.shutdown()
        poseLandmarkerHelper.clearPoseLandmarker()
    }
}