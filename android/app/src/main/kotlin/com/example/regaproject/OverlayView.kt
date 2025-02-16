package com.example.regaproject

import android.content.Context 
import android.graphics.Canvas 
import android.graphics.Color 
import android.graphics.Paint
import android.util.AttributeSet 
import android.view.View 
import androidx.core.content.ContextCompat 
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker 
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import kotlin.math.max

// ในไฟล์ OverlayView.kt
class OverlayView(context: Context?, attrs: AttributeSet?) : View(context, attrs) {
    private var results: PoseLandmarkerResult? = null
    private var imageWidth: Int = 1
    private var imageHeight: Int = 1

    private val pointPaint = Paint().apply {
        color = Color.GREEN // เปลี่ยนเป็นสีเขียวเหมือนในภาพตัวอย่าง
        strokeWidth = LANDMARK_STROKE_WIDTH
        style = Paint.Style.FILL
    }
    
    private val linePaint = Paint().apply {
        color = Color.RED // เปลี่ยนเป็นสีแดงเหมือนในภาพตัวอย่าง
        strokeWidth = LANDMARK_STROKE_WIDTH
        style = Paint.Style.STROKE
    }

    fun setResults(poseLandmarkerResults: PoseLandmarkerResult, imageHeight: Int, imageWidth: Int) {
        results = poseLandmarkerResults
        this.imageHeight = imageHeight
        this.imageWidth = imageWidth
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        results?.let { poseResult ->
            poseResult.landmarks().firstOrNull()?.let { landmarks ->
                // คำนวณสัดส่วนให้พอดีกับขนาดจริงของกล้อง
                val viewAspectRatio = width.toFloat() / height
                val imageAspectRatio = imageWidth.toFloat() / imageHeight
                
                var scaleFactor: Float
                var offsetX = 0f
                var offsetY = 0f
                
                if (viewAspectRatio > imageAspectRatio) {
                    // View กว้างกว่า
                    scaleFactor = height.toFloat() / imageHeight
                    offsetX = (width - imageWidth * scaleFactor) / 2
                } else {
                    // View สูงกว่า
                    scaleFactor = width.toFloat() / imageWidth
                    offsetY = (height - imageHeight * scaleFactor) / 2
                }

                // วาดเส้นเชื่อม landmark
                PoseLandmarker.POSE_LANDMARKS.forEach { connection ->
                    val start = landmarks[connection.start()]
                    val end = landmarks[connection.end()]
                    
                    val startX = (start.x() * imageWidth * scaleFactor) + offsetX
                    val startY = (start.y() * imageHeight * scaleFactor) + offsetY
                    val endX = (end.x() * imageWidth * scaleFactor) + offsetX
                    val endY = (end.y() * imageHeight * scaleFactor) + offsetY
                    
                    canvas.drawLine(startX, startY, endX, endY, linePaint)
                }

                // วาดจุด landmark
                landmarks.forEach { landmark ->
                    val x = (landmark.x() * imageWidth * scaleFactor) + offsetX
                    val y = (landmark.y() * imageHeight * scaleFactor) + offsetY
                    canvas.drawCircle(x, y, LANDMARK_RADIUS, pointPaint)
                }
            }
        }
    }

    companion object {
        private const val LANDMARK_STROKE_WIDTH = 8f  // เพิ่มความหนาของเส้นให้เห็นชัดขึ้น
        private const val LANDMARK_RADIUS = 8f       // เพิ่มขนาดจุดให้เห็นชัดขึ้น
    }
}