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
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.Callback
import okhttp3.Call
import okhttp3.Response
import org.json.JSONObject
import org.json.JSONArray
import java.io.IOException
import java.util.concurrent.TimeUnit
import io.flutter.plugin.common.MethodChannel

class PoseLandmarkerHelper(
    private val context: Context,
    private val methodChannel: MethodChannel,
    private val runningMode: RunningMode = RunningMode.LIVE_STREAM,
    private val poseLandmarkerHelperListener: LandmarkerListener? = null
) {
    private var poseLandmarker: PoseLandmarker? = null
    private val mainThreadHandler = Handler(Looper.getMainLooper())
    private val backgroundExecutor: Executor = Executors.newSingleThreadExecutor()
    private val isProcessing = AtomicBoolean(false)
    // เก็บรายชื่อท่าที่อนุญาต
    private var allowedPoseNames: List<String> = listOf()

    // สำหรับส่ง landmarks ไป Server (ถ้าต้องการ)
    private var lastProcessedTime = 0L
    private val PROCESS_INTERVAL = 1000L
    private val isProcessingHttp = AtomicBoolean(false)
    private val client = OkHttpClient.Builder()
        .connectTimeout(1, TimeUnit.SECONDS)
        .readTimeout(1, TimeUnit.SECONDS)
        .build()
        
    // ประกาศตัวแปรเพื่อเก็บข้อมูลความแตกต่างของมุม
    private var angleDiscrepancies = mutableMapOf<String, Map<String, Double>>()

    init {
        setupPoseLandmarker()
    }

    private fun setupPoseLandmarker() {
        try {
            val baseOptionBuilder = BaseOptions.builder()
                .setDelegate(Delegate.GPU)
                .setModelAssetPath("pose_landmarker_lite.task")

            // ตั้งค่าความมั่นใจและ tracking
            val optionsBuilder = PoseLandmarker.PoseLandmarkerOptions.builder()
                .setBaseOptions(baseOptionBuilder.build())
                .setMinPoseDetectionConfidence(0.7f)
                .setMinTrackingConfidence(0.7f)
                .setMinPosePresenceConfidence(0.7f)
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

    /**
     * เรียกจาก ImageAnalysis เพื่อตรวจจับ Pose แบบ Live Stream
     */
    fun detectLiveStream(imageProxy: ImageProxy, isFrontCamera: Boolean) {
        if (isProcessing.get() || poseLandmarker == null) {
            imageProxy.close()
            return
        }

        backgroundExecutor.execute {
            try {
                isProcessing.set(true)

                // แปลง ImageProxy -> Bitmap
                val bitmap = convertImageProxyToBitmap(imageProxy, isFrontCamera)

                // ย่อขนาดก่อนส่งเข้า MediaPipe (ปรับได้ตามต้องการ)
                val resizedBitmap = Bitmap.createScaledBitmap(bitmap, 640, 480, true)
                bitmap.recycle()

                val mpImage = BitmapImageBuilder(resizedBitmap).build()
                poseLandmarker?.detectAsync(mpImage, System.currentTimeMillis())

                resizedBitmap.recycle()
            } catch (e: Exception) {
                Log.e("PoseLandmarkerHelper", "Detection error", e)
                poseLandmarkerHelperListener?.onError("Detection failed: ${e.message}")
            } finally {
                isProcessing.set(false)
                imageProxy.close()
            }
        }
    }

    /**
     * แปลง ImageProxy เป็น Bitmap โดยไม่ทำการ flip (ให้ MediaPipe รับภาพ "ปกติ")
     */
    private fun convertImageProxyToBitmap(
        imageProxy: ImageProxy,
        isFrontCamera: Boolean
    ): Bitmap {
        val bitmap = Bitmap.createBitmap(
            imageProxy.width,
            imageProxy.height,
            Bitmap.Config.ARGB_8888
        )

        val yuvToRgbConverter = YuvToRgbConverter(context)
        yuvToRgbConverter.yuvToRgb(imageProxy, bitmap)

        val matrix = Matrix().apply {
            postRotate(imageProxy.imageInfo.rotationDegrees.toFloat())
        }

        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }

    // ฟังก์ชันสำหรับตั้งค่ารายชื่อท่าที่อนุญาต
    fun setAllowedPoses(poseNames: List<String>) {
        allowedPoseNames = poseNames
        Log.d("PoseLandmarker", "Set allowed poses: $allowedPoseNames")
    }

    // ฟังก์ชันคำนวณมุม (รับค่า NormalizedLandmark ทั้งสามจุด)
    // ฟังก์ชันคำนวณมุม (รับค่า NormalizedLandmark ทั้งสามจุด)
private fun calculateAngle(
    firstPoint: NormalizedLandmark, 
    midPoint: NormalizedLandmark, 
    lastPoint: NormalizedLandmark
): Double {
    val vectorA = floatArrayOf(
        firstPoint.x() - midPoint.x(),
        firstPoint.y() - midPoint.y(),
        firstPoint.z() - midPoint.z()
    )
    
    val vectorB = floatArrayOf(
        lastPoint.x() - midPoint.x(),
        lastPoint.y() - midPoint.y(),
        lastPoint.z() - midPoint.z()
    )
    
    val dotProduct = vectorA[0] * vectorB[0] + vectorA[1] * vectorB[1] + vectorA[2] * vectorB[2]
    val magnitudeA = Math.sqrt((vectorA[0] * vectorA[0] + vectorA[1] * vectorA[1] + vectorA[2] * vectorA[2]).toDouble())
    val magnitudeB = Math.sqrt((vectorB[0] * vectorB[0] + vectorB[1] * vectorB[1] + vectorB[2] * vectorB[2]).toDouble())
    
    if (magnitudeA == 0.0 || magnitudeB == 0.0) {
        return 0.0
    }
    
    val cosAngle = (dotProduct / (magnitudeA * magnitudeB)).toDouble()
    val clampedCosAngle = cosAngle.coerceIn(-1.0, 1.0)
    return Math.toDegrees(Math.acos(clampedCosAngle))
}

// ฟังก์ชันสกัดมุมจาก landmarks (เก็บค่าใน Map)
fun extractJointAngles(landmarks: List<NormalizedLandmark>): Map<String, Double> {
    val angles = mutableMapOf<String, Double>()
    
    // ดัชนี landmark ตาม MediaPipe
    val NOSE = 0
    val LEFT_SHOULDER = 11
    val RIGHT_SHOULDER = 12
    val LEFT_ELBOW = 13
    val RIGHT_ELBOW = 14
    val LEFT_WRIST = 15
    val RIGHT_WRIST = 16
    val LEFT_HIP = 23
    val RIGHT_HIP = 24
    val LEFT_KNEE = 25
    val RIGHT_KNEE = 26
    val LEFT_ANKLE = 27
    val RIGHT_ANKLE = 28
    
    angles["left_shoulder_angle"] = calculateAngle(
        landmarks[LEFT_HIP], 
        landmarks[LEFT_SHOULDER], 
        landmarks[LEFT_ELBOW]
    )
    angles["right_shoulder_angle"] = calculateAngle(
        landmarks[RIGHT_HIP], 
        landmarks[RIGHT_SHOULDER], 
        landmarks[RIGHT_ELBOW]
    )
    angles["left_elbow_angle"] = calculateAngle(
        landmarks[LEFT_SHOULDER], 
        landmarks[LEFT_ELBOW], 
        landmarks[LEFT_WRIST]
    )
    angles["right_elbow_angle"] = calculateAngle(
        landmarks[RIGHT_SHOULDER], 
        landmarks[RIGHT_ELBOW], 
        landmarks[RIGHT_WRIST]
    )
    angles["left_hip_angle"] = calculateAngle(
        landmarks[LEFT_SHOULDER], 
        landmarks[LEFT_HIP], 
        landmarks[LEFT_KNEE]
    )
    angles["right_hip_angle"] = calculateAngle(
        landmarks[RIGHT_SHOULDER], 
        landmarks[RIGHT_HIP], 
        landmarks[RIGHT_KNEE]
    )
    angles["left_knee_angle"] = calculateAngle(
        landmarks[LEFT_HIP], 
        landmarks[LEFT_KNEE], 
        landmarks[LEFT_ANKLE]
    )
    angles["right_knee_angle"] = calculateAngle(
        landmarks[RIGHT_HIP], 
        landmarks[RIGHT_KNEE], 
        landmarks[RIGHT_ANKLE]
    )
    
    return angles
}
    
    // เมธอดสำหรับรับค่าความแตกต่างของมุม
    fun getAngleDiscrepancies(): Map<String, Map<String, Double>> {
        return angleDiscrepancies
    }

    // ส่ง landmarks (พร้อมมุม) ไปยัง Flask server
    fun sendLandmarksToFlask(landmarks: List<NormalizedLandmark>) {
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastProcessedTime < PROCESS_INTERVAL) return
        lastProcessedTime = currentTime

        if (isProcessingHttp.get()) return
        isProcessingHttp.set(true)

        try {
            val jointAngles = extractJointAngles(landmarks)
            
            val keypointsArray = JSONArray()
            landmarks.forEach { lm ->
                keypointsArray.put(lm.x().toDouble())
                keypointsArray.put(lm.y().toDouble())
                keypointsArray.put(lm.z().toDouble())
            }
            
            val anglesObject = JSONObject()
            jointAngles.forEach { (name, value) ->
                anglesObject.put(name, value)
            }
            
            val json = JSONObject().apply {
                put("keypoints", keypointsArray)
                put("joint_angles", anglesObject)
                
                val allowedPosesArray = JSONArray()
                allowedPoseNames.forEach { poseName ->
                    allowedPosesArray.put(poseName)
                }
                put("allowedPoses", allowedPosesArray)
            }

            val mediaType = "application/json".toMediaType()
            val requestBody = RequestBody.create(mediaType, json.toString())
            val request = Request.Builder()
                .url("http://192.168.117.17:5000/predict")
                .post(requestBody)
                .build()

            client.newCall(request).enqueue(object : Callback {
                override fun onResponse(call: Call, response: Response) {
                    try {
                        val responseBody = response.body?.string() ?: "{}"
                        Log.d("PoseLandmarker", "Response from server: $responseBody")
                        
                        val responseData = JSONObject(responseBody)
                        val angleSimilarity = responseData.optDouble("angle_similarity", 0.0)
                        val expectedPose = responseData.optString("expected_pose", "")
                        
                        // แยกวิเคราะห์ความแตกต่างของมุม
                        val discrepancies = mutableMapOf<String, Map<String, Double>>()
                        if (responseData.has("angle_discrepancies")) {
                            val discrepanciesObj = responseData.getJSONObject("angle_discrepancies")
                            Log.d("PoseLandmarker", "Discrepancies from server: ${discrepanciesObj}")
                            
                            val iterator = discrepanciesObj.keys()
                            while (iterator.hasNext()) {
                                val angleName = iterator.next()
                                val discrepancyObj = discrepanciesObj.getJSONObject(angleName)
                                discrepancies[angleName] = mapOf(
                                    "user_angle" to discrepancyObj.getDouble("user_angle"),
                                    "reference_angle" to discrepancyObj.getDouble("reference_angle"),
                                    "difference" to discrepancyObj.getDouble("difference")
                                )
                            }
                        }
                        
                        // บันทึกข้อมูลความแตกต่างของมุม
                        angleDiscrepancies = discrepancies
                        Log.d("PoseLandmarker", "Set angleDiscrepancies: $angleDiscrepancies")
                        
                        val prediction = mapOf(
                            "pose" to responseData.getString("predicted_pose"),
                            "expected_pose" to expectedPose,
                            "score" to responseData.optDouble("angle_similarity", 0.0), // ตรวจสอบให้แน่ใจว่าชื่อฟิลด์ตรงกัน
                            "confidence" to responseData.optDouble("confidence", 0.0),
                            "angle_discrepancies" to discrepancies
                        )
                        
                        Log.d("PoseLandmarker", "Sending to Flutter: predicted_pose=${prediction["pose"]}, expected_pose=${prediction["expected_pose"]}, score=${prediction["score"]}")
                        
                        mainThreadHandler.post {
                            methodChannel.invokeMethod("onPosePredicted", prediction)
                        }
                    } catch (e: Exception) {
                        Log.e("PoseLandmarker", "Error parsing response: ${e.message}", e)
                    } finally {
                        isProcessingHttp.set(false)
                    }
                }
                
                override fun onFailure(call: Call, e: IOException) {
                    Log.e("PoseLandmarker", "Request failed: ${e.message}")
                    isProcessingHttp.set(false)
                }
            })
        } catch (e: Exception) {
            Log.e("PoseLandmarker", "Error sending landmarks: ${e.message}")
            isProcessingHttp.set(false)
        }
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