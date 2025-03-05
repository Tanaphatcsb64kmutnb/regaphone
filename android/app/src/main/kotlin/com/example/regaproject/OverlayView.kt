package com.example.regaproject

import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.view.SurfaceView
import android.view.SurfaceHolder
import android.graphics.PorterDuff
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker

class OverlayView(context: Context?, attrs: AttributeSet?) : SurfaceView(context, attrs), SurfaceHolder.Callback {

    private var currentResult: PoseLandmarkerResult? = null
    private var angleMap: Map<String, Double>? = null

    // ขนาดต้นฉบับของภาพที่ MediaPipe วิเคราะห์
    private var imageWidth = 1280
    private var imageHeight = 720

    private val pointPaint = Paint().apply {
        color = Color.YELLOW
        strokeWidth = 12f
        style = Paint.Style.FILL
        isAntiAlias = true
    }

    private val linePaint = Paint().apply {
        color = Color.RED
        strokeWidth = 8f
        style = Paint.Style.STROKE
        isAntiAlias = true
        strokeCap = Paint.Cap.ROUND
    }

    init {
        setZOrderOnTop(true)
        holder.setFormat(PixelFormat.TRANSPARENT)
        holder.addCallback(this)
        setWillNotDraw(false)
    }

    @Synchronized
    fun setResults(
        poseLandmarkerResults: PoseLandmarkerResult,
        inputImageHeight: Int,
        inputImageWidth: Int
    ) {
        if (!holder.surface.isValid) return

        currentResult = poseLandmarkerResults
        imageHeight = inputImageHeight
        imageWidth = inputImageWidth

        post { drawOverlay() }
    }

    // ฟังก์ชันรับค่ามุม (angles) ที่คำนวณได้จาก PoseLandmarkerHelper
    fun setAngles(angles: Map<String, Double>) {
        angleMap = angles
        post { drawOverlay() }
    }

    private fun drawOverlay() {
        if (!holder.surface.isValid || currentResult == null) return

        val canvas = holder.lockCanvas()
        try {
            // เคลียร์ canvas
            canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)

            currentResult?.landmarks()?.firstOrNull()?.let { landmarks ->
                // คำนวณ scale และ offset สำหรับการวาดให้พอดีกับหน้าจอ
                val overlayW = width.toFloat()
                val overlayH = height.toFloat()
                val cameraAspect = imageWidth.toFloat() / imageHeight.toFloat()
                val overlayAspect = overlayW / overlayH
                var scale = 1f
                var offsetX = 0f
                var offsetY = 0f

                if (overlayAspect > cameraAspect) {
                    scale = overlayW / imageWidth
                    val scaledH = imageHeight * scale
                    offsetY = (overlayH - scaledH) / 2f
                } else {
                    scale = overlayH / imageHeight
                    val scaledW = imageWidth * scale
                    offsetX = (overlayW - scaledW) / 2f
                }

                // วาดเส้นเชื่อมระหว่าง landmarks
                PoseLandmarker.POSE_LANDMARKS.forEach { connection ->
                    if (connection != null) {
                        val start = landmarks[connection.start()]
                        val end = landmarks[connection.end()]

                        val startX = offsetX + (start.x() * imageWidth) * scale
                        val startY = offsetY + (start.y() * imageHeight) * scale
                        val endX = offsetX + (end.x() * imageWidth) * scale
                        val endY = offsetY + (end.y() * imageHeight) * scale

                        canvas.drawLine(startX, startY, endX, endY, linePaint)
                    }
                }

                // วาดจุด landmarks
                landmarks.forEach { lm ->
                    val cx = offsetX + (lm.x() * imageWidth) * scale
                    val cy = offsetY + (lm.y() * imageHeight) * scale
                    canvas.drawCircle(cx, cy, 10f, pointPaint)
                }

                // วาดตัวเลขแสดงค่ามุม (Angle) ที่คำนวณได้
                val angleTextPaint = Paint().apply {
                    color = Color.WHITE
                    textSize = 100f
                    style = Paint.Style.FILL
                    isAntiAlias = true
                }

                // mapping ชื่อมุมไปยัง index ของ landmark ที่ใช้แสดงค่า
                // ตัวอย่าง: "left_elbow_angle" -> index 13, "right_elbow_angle" -> index 14 เป็นต้น
                angleMap?.forEach { (angleName, angleValue) ->
                    val midIndex = when(angleName) {
                        "left_elbow_angle" -> 13
                        "right_elbow_angle" -> 14
                        "left_shoulder_angle" -> 11
                        "right_shoulder_angle" -> 12
                        "left_hip_angle" -> 23
                        "right_hip_angle" -> 24
                        "left_knee_angle" -> 25
                        "right_knee_angle" -> 26
                        else -> null
                    }

                    midIndex?.let { idx ->
                        if (idx < landmarks.size) {
                            val lm = landmarks[idx]
                            val cx = offsetX + (lm.x() * imageWidth) * scale
                            val cy = offsetY + (lm.y() * imageHeight) * scale
                            canvas.drawText("${angleValue.toInt()}°", cx, cy - 10f, angleTextPaint)
                        }
                    }
                }
            }
        } finally {
            holder.unlockCanvasAndPost(canvas)
        }
    }

    override fun surfaceCreated(holder: SurfaceHolder) {}
    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {}
    override fun surfaceDestroyed(holder: SurfaceHolder) {
        currentResult = null
    }
}
