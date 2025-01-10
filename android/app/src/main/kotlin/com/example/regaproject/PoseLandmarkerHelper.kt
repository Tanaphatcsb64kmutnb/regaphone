//poselandmarkerhelper
package com.example.regaproject

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.SystemClock
import android.util.Log
import androidx.camera.core.ImageProxy
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
class PoseLandmarkerHelper(
    var minPoseDetectionConfidence: Float = DEFAULT_POSE_DETECTION_CONFIDENCE,
    var minPoseTrackingConfidence: Float = DEFAULT_POSE_TRACKING_CONFIDENCE,
    var minPosePresenceConfidence: Float = DEFAULT_POSE_PRESENCE_CONFIDENCE,

    var currentModel: Int = MODEL_POSE_LANDMARKER_LITE,
    // ลองสลับ DELEGATE_CPU หรือ DELEGATE_GPU ตามต้องการ
    var currentDelegate: Int = DELEGATE_GPU,
    var runningMode: RunningMode = RunningMode.LIVE_STREAM,
    val context: Context,
    val poseLandmarkerHelperListener: LandmarkerListener? = null
) {

    private var poseLandmarker: PoseLandmarker? = null
    private var frameCounter = 0

    init {
        setupPoseLandmarker()
    }

    fun clearPoseLandmarker() {
        poseLandmarker?.close()
        poseLandmarker = null
    }

    fun setupPoseLandmarker() {
        val baseOptionBuilder = BaseOptions.builder()

        when (currentDelegate) {
            DELEGATE_CPU -> baseOptionBuilder.setDelegate(Delegate.CPU)
            DELEGATE_GPU -> baseOptionBuilder.setDelegate(Delegate.GPU)
        }

        val modelName = when (currentModel) {
            MODEL_POSE_LANDMARKER_FULL -> "pose_landmarker_full.task"
            MODEL_POSE_LANDMARKER_LITE -> "pose_landmarker_lite.task"
            MODEL_POSE_LANDMARKER_HEAVY -> "pose_landmarker_heavy.task"
            else -> "pose_landmarker_lite.task"
        }

        baseOptionBuilder.setModelAssetPath(modelName)

        try {
            val optionsBuilder = PoseLandmarker.PoseLandmarkerOptions.builder()
                .setBaseOptions(baseOptionBuilder.build())
                .setMinPoseDetectionConfidence(minPoseDetectionConfidence)
                .setMinTrackingConfidence(minPoseTrackingConfidence)
                .setMinPosePresenceConfidence(minPosePresenceConfidence)
                .setRunningMode(runningMode)

            if (runningMode == RunningMode.LIVE_STREAM) {
                optionsBuilder
                    .setResultListener(this::returnLivestreamResult)
                    .setErrorListener(this::returnLivestreamError)
            }

            poseLandmarker = PoseLandmarker.createFromOptions(context, optionsBuilder.build())
            Log.d(TAG, "PoseLandmarker created with model=$modelName, delegate=$currentDelegate")
        } catch (e: Exception) {
            poseLandmarkerHelperListener?.onError("Pose Landmarker init failed: ${e.message}")
            Log.e(TAG, "Pose Landmarker init failed", e)
        }
    }

    fun detectLiveStream(imageProxy: ImageProxy, isFrontCamera: Boolean) {
        frameCounter++
        val frameTime = SystemClock.uptimeMillis()

        try {
            val bitmap = convertImageProxyToBitmap(imageProxy, isFrontCamera)
            Log.d(TAG, "detectLiveStream() frame=$frameCounter width=${bitmap.width} height=${bitmap.height}")

            val mpImage: MPImage = BitmapImageBuilder(bitmap).build()
            poseLandmarker?.detectAsync(mpImage, frameTime)
            Log.d(TAG, "detectAsync() invoked (frame=$frameCounter).")
        } catch (e: Exception) {
            Log.e(TAG, "detectLiveStream() error: ${e.message}")
        } finally {
            // close เฟรมทุกครั้งที่ประมวลผลเสร็จ
            imageProxy.close()
        }
    }

    private fun convertImageProxyToBitmap(imageProxy: ImageProxy, isFrontCamera: Boolean): Bitmap {
        val yuvToRgbConverter = YuvToRgbConverter(context)
        val bitmap = Bitmap.createBitmap(
            imageProxy.width, imageProxy.height, Bitmap.Config.ARGB_8888
        )
        yuvToRgbConverter.yuvToRgb(imageProxy, bitmap)

        val matrix = Matrix().apply {
            postRotate(imageProxy.imageInfo.rotationDegrees.toFloat())
            if (isFrontCamera) {
                postScale(-1f, 1f, bitmap.width / 2f, bitmap.height / 2f)
            }
        }
        val rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
        Log.d(TAG, "convertImageProxyToBitmap() done. Rotated size=${rotatedBitmap.width}x${rotatedBitmap.height}")
        return rotatedBitmap
    }

    private fun returnLivestreamResult(result: PoseLandmarkerResult, input: MPImage) {
        val finishTimeMs = SystemClock.uptimeMillis()
        val inferenceTime = finishTimeMs - result.timestampMs()

        Log.d(TAG, "returnLivestreamResult() called. inferenceTime=${inferenceTime}ms")
        poseLandmarkerHelperListener?.onResults(
            ResultBundle(
                listOf(result),
                inferenceTime,
                input.height,
                input.width
            )
        )
    }

    private fun returnLivestreamError(error: RuntimeException) {
        poseLandmarkerHelperListener?.onError("Error: ${error.message}")
        Log.e(TAG, "returnLivestreamError(): ${error.message}")
    }

    companion object {
        const val TAG = "PoseLandmarkerHelper"

        const val DELEGATE_CPU = 0
        const val DELEGATE_GPU = 1

        const val DEFAULT_POSE_DETECTION_CONFIDENCE = 0.5F
        const val DEFAULT_POSE_TRACKING_CONFIDENCE = 0.5F
        const val DEFAULT_POSE_PRESENCE_CONFIDENCE = 0.5F

        const val MODEL_POSE_LANDMARKER_FULL = 0
        const val MODEL_POSE_LANDMARKER_LITE = 1
        const val MODEL_POSE_LANDMARKER_HEAVY = 2
    }

    data class ResultBundle(
        val results: List<PoseLandmarkerResult>,
        val inferenceTime: Long,
        val inputImageHeight: Int,
        val inputImageWidth: Int,
    )

    interface LandmarkerListener {
        fun onError(error: String)
        fun onResults(resultBundle: ResultBundle)
    }
}
