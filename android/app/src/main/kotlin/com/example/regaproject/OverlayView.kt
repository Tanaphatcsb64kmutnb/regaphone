//overlay
package com.example.regaproject

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.view.View
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult

class OverlayView(context: Context?, attrs: AttributeSet?) : View(context, attrs) {

    private var results: PoseLandmarkerResult? = null

    private var imageWidth: Int = 1
    private var imageHeight: Int = 1

    private var scaleX = 1f
    private var scaleY = 1f

    private val pointPaint = Paint().apply {
        color = Color.YELLOW
        strokeWidth = 12f
        style = Paint.Style.FILL
    }

    private val linePaint = Paint().apply {
        color = Color.RED
        strokeWidth = 8f
        style = Paint.Style.STROKE
    }

    fun setOverlaySettings(pointColor: String, lineColor: String, pointSize: Float) {
        pointPaint.color = Color.parseColor(pointColor)
        linePaint.color = Color.parseColor(lineColor)
        pointPaint.strokeWidth = pointSize
    }

    fun setResults(
        poseLandmarkerResults: PoseLandmarkerResult,
        imageHeight: Int,
        imageWidth: Int
    ) {
        this.results = poseLandmarkerResults
        this.imageHeight = imageHeight
        this.imageWidth = imageWidth

        scaleX = width.toFloat() / this.imageWidth
        scaleY = height.toFloat() / this.imageHeight

        invalidate() // ขอให้ onDraw() เกิดทันที
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val poseResult = results ?: return

        val allPoseLandmarks = poseResult.landmarks()
        allPoseLandmarks.forEach { landmarks ->
            // วาดจุด
            for (lm in landmarks) {
                val x = lm.x() * imageWidth * scaleX
                val y = lm.y() * imageHeight * scaleY
                canvas.drawCircle(x, y, 8f, pointPaint)
            }

            // วาดเส้นเชื่อมโครงกระดูก
            PoseLandmarker.POSE_LANDMARKS.forEach { connection ->
                val start = landmarks[connection!!.start()]
                val end = landmarks[connection.end()]

                val startX = start.x() * imageWidth * scaleX
                val startY = start.y() * imageHeight * scaleY
                val endX = end.x() * imageWidth * scaleX
                val endY = end.y() * imageHeight * scaleY

                canvas.drawLine(startX, startY, endX, endY, linePaint)
            }
        }
    }

    fun clear() {
        results = null
        invalidate()
    }
}