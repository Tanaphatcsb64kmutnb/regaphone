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
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import android.util.Size
import android.view.ViewGroup
import com.google.mediapipe.tasks.vision.core.RunningMode

class LiveCameraPlatformView(
    private val context: Context,
    private val methodChannel: MethodChannel,
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
            implementationMode = PreviewView.ImplementationMode.COMPATIBLE 
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        overlayView = OverlayView(context, null).apply {
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(android.graphics.Color.TRANSPARENT)
        }

        container.addView(previewView)
        container.addView(overlayView)
        overlayView.bringToFront()
        container.invalidate()

        cameraExecutor = Executors.newSingleThreadExecutor()

        poseLandmarkerHelper = PoseLandmarkerHelper(
            context = context,
            methodChannel = methodChannel,
            poseLandmarkerHelperListener = object : PoseLandmarkerHelper.LandmarkerListener {
                override fun onError(error: String) {
                    Log.e("LiveCameraPlatformView", error)
                }

                override fun onResults(resultBundle: PoseLandmarkerHelper.ResultBundle) {
                    val poseResult = resultBundle.results.firstOrNull() ?: return
                    container.post {
                        overlayView.setResults(
                            poseResult,
                            resultBundle.inputImageHeight,
                            resultBundle.inputImageWidth
                        )
                        overlayView.bringToFront()
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
            .setTargetResolution(Size(360, 240))//480*360
            .build()
            .also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }

        val imageAnalysis = ImageAnalysis.Builder()
            .setTargetResolution(Size(640, 480))//640*480
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()
            .also {
                it.setAnalyzer(cameraExecutor) { imageProxy ->
                    poseLandmarkerHelper.detectLiveStream(imageProxy, isFrontCamera)
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
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        cameraExecutor.shutdown()
        poseLandmarkerHelper.clearPoseLandmarker()
    }
}