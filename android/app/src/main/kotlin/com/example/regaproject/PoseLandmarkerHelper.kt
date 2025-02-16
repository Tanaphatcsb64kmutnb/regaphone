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
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import android.util.Size
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.create
import okhttp3.Callback
import okhttp3.Call
import okhttp3.Response
import org.json.JSONObject
import java.io.IOException
import java.util.concurrent.TimeUnit
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class PoseLandmarkerHelper(
    private val context: Context,
    private val methodChannel: MethodChannel,
    private val runningMode: RunningMode = RunningMode.LIVE_STREAM,
    private val poseLandmarkerHelperListener: LandmarkerListener? = null
) {
    private var poseLandmarker: PoseLandmarker? = null
    private var frameCount = 0
    private val mainThreadHandler = Handler(Looper.getMainLooper())
    private val backgroundExecutor: Executor = Executors.newSingleThreadExecutor()
    private val isProcessing = AtomicBoolean(false)
    private var lastProcessedTime = 0L
    private val PROCESS_INTERVAL = 500L // 500ms interval between predictions
    private val isProcessingHttp = AtomicBoolean(false)

    // เพิ่ม OkHttpClient สำหรับการส่ง HTTP requests
    private val client = OkHttpClient.Builder()
        .connectTimeout(1, TimeUnit.SECONDS)
        .readTimeout(1, TimeUnit.SECONDS)
        .build()

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
                            // Send landmarks to Flask after processing
                            result.landmarks().firstOrNull()?.let { landmarks ->
                                val currentTime = System.currentTimeMillis()
                                if (currentTime - lastProcessedTime >= PROCESS_INTERVAL) {
                                    sendLandmarksToFlask(landmarks)
                                    lastProcessedTime = currentTime
                                }
                            }
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

 // PoseLandmarkerHelper.kt

private fun sendLandmarksToFlask(landmarks: List<NormalizedLandmark>) {
    if (isProcessingHttp.get()) return
    isProcessingHttp.set(true)

    try {
        // แก้วิธีการสร้าง JSONArray
        val keypointsArray = JSONArray()
        landmarks.forEach { landmark ->
            // แปลง float เป็น double ก่อนใส่ใน JSONArray
            keypointsArray.put(landmark.x().toDouble())
            keypointsArray.put(landmark.y().toDouble())
            keypointsArray.put(landmark.z().toDouble())
        }

        val json = JSONObject()
        json.put("keypoints", keypointsArray)

        val mediaType = "application/json; charset=utf-8".toMediaType()
        val requestBody = RequestBody.create(mediaType, json.toString())

        val request = Request.Builder()
            .url("http://192.168.8.104:5000/predict")  // ตรวจสอบ IP address ให้ถูกต้อง
            .post(requestBody)
            .addHeader("Accept", "application/json; charset=utf-8")
            .addHeader("Content-Type", "application/json; charset=utf-8")
            .build()

        val client = OkHttpClient.Builder()
            .connectTimeout(5, TimeUnit.SECONDS)
            .readTimeout(5, TimeUnit.SECONDS)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onResponse(call: Call, response: Response) {
                try {
                    val responseData = response.body?.string()
                    if (responseData != null) {
                        val jsonResponse = JSONObject(responseData)
                        Log.d("PoseLandmarker", "Response: $jsonResponse")
                        
                        val prediction = mapOf(
                            "pose" to jsonResponse.getString("predicted_pose"),
                            "confidence" to jsonResponse.getDouble("confidence")
                        )

                        mainThreadHandler.post {
                            methodChannel.invokeMethod("onPosePredicted", prediction)
                        }
                    }
                } catch (e: Exception) {
                    Log.e("PoseLandmarker", "Error parsing response: ${e.message}")
                } finally {
                    isProcessingHttp.set(false)
                }
            }

            override fun onFailure(call: Call, e: IOException) {
                Log.e("PoseLandmarker", "Request failed: ${e.message}")
                mainThreadHandler.post {
                    methodChannel.invokeMethod("onPredictionError", "การเชื่อมต่อล้มเหลว")
                }
                isProcessingHttp.set(false)
            }
        })
    } catch (e: Exception) {
        Log.e("PoseLandmarker", "Error sending landmarks: ${e.message}")
        mainThreadHandler.post {
            methodChannel.invokeMethod("onPredictionError", "เกิดข้อผิดพลาดในการส่งข้อมูล")
        }
        isProcessingHttp.set(false)
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

    data class ResultBundle(
        val results: List<PoseLandmarkerResult>,
        val inferenceTime: Long,
        val inputImageHeight: Int,
        val inputImageWidth: Int
    )

    interface LandmarkerListener {
        fun onError(error: String)
        fun onResults(resultBundle: ResultBundle)
    }
}