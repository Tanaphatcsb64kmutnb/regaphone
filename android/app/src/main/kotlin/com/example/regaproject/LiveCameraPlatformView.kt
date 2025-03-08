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

    // รับคำสั่งจาก MethodChannel (เช่น internalSetAllowedPoses)
    private fun setupMethodChannelListener() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "internalSetAllowedPoses" -> {
                    val poseNames = call.argument<List<String>>("poseNames")
                    if (poseNames != null) {
                        poseLandmarkerHelper.setAllowedPoses(poseNames)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Invalid pose names", null)
                    }
                }
                "setAllowedPoses" -> {
                    val poseNames = call.argument<List<String>>("poseNames")
                    if (poseNames != null) {
                        poseLandmarkerHelper.setAllowedPoses(poseNames)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Invalid pose names", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    init {
        container = FrameLayout(context)
        setupMethodChannelListener()

        // สร้าง PreviewView สำหรับแสดงภาพกล้อง
        previewView = PreviewView(context).apply {
            scaleType = PreviewView.ScaleType.FILL_CENTER
            implementationMode = PreviewView.ImplementationMode.COMPATIBLE
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        // สร้าง OverlayView สำหรับวาด landmarks, เส้นเชื่อม และค่ามุม
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

        // สร้าง PoseLandmarkerHelper เพื่อประมวลผลภาพ
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
                        // ส่งผลลัพธ์ให้ OverlayView วาด landmarks และเส้นเชื่อม
                        overlayView.setResults(
                            poseResult,
                            resultBundle.inputImageHeight,
                            resultBundle.inputImageWidth
                        )
                        // คำนวณมุมจาก landmarks และส่งไป OverlayView เพื่อแสดงค่าองศา
                        poseResult.landmarks().firstOrNull()?.let { landmarks ->
                            val angleMap = poseLandmarkerHelper.extractJointAngles(landmarks)
                            overlayView.setAngles(angleMap)

                            // รับความแตกต่างของมุมจาก PoseLandmarkerHelper
                            val discrepancies = poseLandmarkerHelper.getAngleDiscrepancies()
                            Log.d("LiveCameraPlatformView", "Setting discrepancies to OverlayView: $discrepancies")
                            
                            // ส่งไปให้ OverlayView วาดวงกลมรอบมุมที่ไม่ถูกต้อง
                            overlayView.setAngleDiscrepancies(discrepancies)
                        }
                        overlayView.bringToFront()
                    }
                    // ส่ง landmarks ไปยัง Flask server
                    poseResult.landmarks().firstOrNull()?.let { landmarks ->
                        poseLandmarkerHelper.sendLandmarksToFlask(landmarks)
                    }
                }
            }
        )

        // ถ้าเป็นกล้องหน้า ให้ flip ภาพให้เหมือนกระจก
        if (isFrontCamera) {
            previewView.scaleX = -1f
            overlayView.scaleX = -1f
        }

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
            .setTargetResolution(Size(1280, 720))
            .build()
            .also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }

        val imageAnalysis = ImageAnalysis.Builder()
            .setTargetResolution(Size(1280, 720))
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

    override fun getView(): View = container

    override fun dispose() {
        cameraExecutor.shutdown()
        poseLandmarkerHelper.clearPoseLandmarker()
    }
}