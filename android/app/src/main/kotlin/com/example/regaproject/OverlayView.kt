//D:\regaphone - Copy (2)\Rega-Project\regaproject\android\app\src\main\kotlin\com\example\regaproject\OverlayView.kt
package com.example.regaproject

import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.view.SurfaceView
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import android.view.SurfaceHolder
import android.graphics.PorterDuff
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker

class OverlayView(context: Context?, attrs: AttributeSet?) : SurfaceView(context, attrs), SurfaceHolder.Callback {
    private var currentResult: PoseLandmarkerResult? = null

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
        imageHeight: Int,
        imageWidth: Int
    ) {
        if (!holder.surface.isValid) return
        
        currentResult = poseLandmarkerResults
        
        // Post drawing to avoid blocking
        post { drawOverlay() }
    }

    private fun drawOverlay() {
        if (!holder.surface.isValid || currentResult == null) return
        
        val canvas = holder.lockCanvas()
        try {
            // Clear previous drawing
            canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)
            
            currentResult?.let { poseResult ->
                poseResult.landmarks().firstOrNull()?.let { landmarks ->
                    // Draw connections
                    PoseLandmarker.POSE_LANDMARKS.forEach { connection ->
                        if (connection != null) {
                            val start = landmarks[connection.start()]
                            val end = landmarks[connection.end()]
                            
                            canvas.drawLine(
                                start.x() * width,
                                start.y() * height,
                                end.x() * width,
                                end.y() * height,
                                linePaint
                            )
                        }
                    }

                    // Draw points
                    landmarks.forEach { landmark ->
                        canvas.drawCircle(
                            landmark.x() * width,
                            landmark.y() * height,
                            10f,
                            pointPaint
                        )
                    }
                }
            }
        } finally {
            // Always unlock canvas
            holder.unlockCanvasAndPost(canvas)
        }
    }

    override fun surfaceCreated(holder: SurfaceHolder) {
        // Initial setup if needed
    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        // Handle surface changes
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        // Cleanup if needed
        currentResult = null
    }
}