package com.example.regaproject

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.camera.core.ImageProxy
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class PoseLandmarkerHelper(
    private val context: Context,
    private val runningMode: RunningMode = RunningMode.LIVE_STREAM,
    private val poseLandmarkerHelperListener: LandmarkerListener? = null
) {
    private var poseLandmarker: PoseLandmarker? = null
    private var frameCount = 0
    private val mainThreadHandler = Handler(Looper.getMainLooper())
    private val backgroundExecutor: Executor = Executors.newSingleThreadExecutor()
    private val isProcessing = AtomicBoolean(false)

    init {
        setupPoseLandmarker()
    }

    private fun setupPoseLandmarker() {
        try {
            val baseOptionBuilder = BaseOptions.builder()
                .setDelegate(Delegate.GPU)
                .setModelAssetPath("pose_landmarker_lite.task")

            val optionsBuilder = PoseLandmarker.PoseLandmarkerOptions.builder()
                .setBaseOptions(baseOptionBuilder.build())
                .setMinPoseDetectionConfidence(0.5f)
                .setMinTrackingConfidence(0.5f)
                .setMinPosePresenceConfidence(0.5f)
                .setRunningMode(runningMode)

            if (runningMode == RunningMode.LIVE_STREAM) {
                optionsBuilder
                    .setResultListener { result, input ->
                        mainThreadHandler.post {
                            poseLandmarkerHelperListener?.onResults(
                                ResultBundle(
                                    listOf(result),
                                    System.currentTimeMillis(),
                                    input.height,
                                    input.width
                                )
                            )
                        }
                    }
                    .setErrorListener { error ->
                        mainThreadHandler.post {
                            poseLandmarkerHelperListener?.onError(
                                error.message ?: "Unknown error"
                            )
                        }
                    }
            }

            poseLandmarker = PoseLandmarker.createFromOptions(context, optionsBuilder.build())
        } catch (e: Exception) {
            poseLandmarkerHelperListener?.onError(
                "Pose Landmarker initialization error: ${e.message}"
            )
        }
    }

    fun detectLiveStream(imageProxy: ImageProxy, isFrontCamera: Boolean) {
        // Quick exit conditions
        if (isProcessing.get() || poseLandmarker == null) {
            imageProxy.close()
            return
        }

        backgroundExecutor.execute {
            try {
                isProcessing.set(true)
                
                // Ensure ARGB_8888 bitmap
                val bitmap = convertImageProxyToBitmap(imageProxy, isFrontCamera)
                
                // Resize for performance
                val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 640, 480, true)
                bitmap.recycle()

                // Convert to MediaPipe image
                val mpImage = BitmapImageBuilder(resizedBitmap).build()
                
                // Detect asynchronously
                poseLandmarker?.detectAsync(mpImage, System.currentTimeMillis())
                
                // Clean up
                resizedBitmap.recycle()
            } catch (e: Exception) {
                Log.e("PoseLandmarkerHelper", "Detection error", e)
                poseLandmarkerHelperListener?.onError(
                    "Detection failed: ${e.message}"
                )
            } finally {
                isProcessing.set(false)
                imageProxy.close()
            }
        }
    }

    private fun convertImageProxyToBitmap(
        imageProxy: ImageProxy,
        isFrontCamera: Boolean
    ): Bitmap {
        // Always use ARGB_8888
        val bitmap = Bitmap.createBitmap(
            imageProxy.width, 
            imageProxy.height, 
            Bitmap.Config.ARGB_8888
        )

        val yuvToRgbConverter = YuvToRgbConverter(context)
        yuvToRgbConverter.yuvToRgb(imageProxy, bitmap)

        val matrix = Matrix().apply {
            postRotate(imageProxy.imageInfo.rotationDegrees.toFloat())
            if (isFrontCamera) {
                postScale(-1f, 1f, bitmap.width / 2f, bitmap.height / 2f)
            }
        }

        return Bitmap.createBitmap(
            bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true
        )
    }

    fun clearPoseLandmarker() {
        backgroundExecutor.execute {
            poseLandmarker?.close()
            poseLandmarker = null
        }
    }

    // Result bundle for passing detection results
    data class ResultBundle(
        val results: List<PoseLandmarkerResult>,
        val inferenceTime: Long,
        val inputImageHeight: Int,
        val inputImageWidth: Int
    )

    // Listener interface for pose detection results
    interface LandmarkerListener {
        fun onError(error: String)
        fun onResults(resultBundle: ResultBundle)
    }
}