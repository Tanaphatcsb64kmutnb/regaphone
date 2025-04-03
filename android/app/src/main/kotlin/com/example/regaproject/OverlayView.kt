package com.example.regaproject

import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.util.Log
import android.view.SurfaceView
import android.view.SurfaceHolder
import android.graphics.PorterDuff
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker

class OverlayView(context: Context?, attrs: AttributeSet?) : SurfaceView(context, attrs), SurfaceHolder.Callback {

    private var currentResult: PoseLandmarkerResult? = null
    private var angleMap: Map<String, Double>? = null
    private var angleDiscrepancies: Map<String, Map<String, Double>>? = null
    private var isPoseCorrect: Boolean? = null // null = ยังไม่ทราบ, true = ถูกต้อง, false = ไม่ถูกต้อง

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
        color = Color.BLUE
        strokeWidth = 10f
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

    // ฟังก์ชันรับค่าความแตกต่างของมุม
    fun setAngleDiscrepancies(discrepancies: Map<String, Map<String, Double>>?) {
        Log.d("OverlayView", "setAngleDiscrepancies called with ${discrepancies?.size ?: 0} items")
        angleDiscrepancies = discrepancies
        post { drawOverlay() }
    }

    // 2. เพิ่มฟังก์ชันใหม่สำหรับตั้งค่า isPoseCorrect
fun setPoseCorrectness(isCorrect: Boolean) {
    isPoseCorrect = isCorrect
    post { drawOverlay() }
}


    private fun drawOverlay() {
        if (!holder.surface.isValid || currentResult == null) return
        
        Log.d("OverlayView", "drawOverlay called with discrepancies: ${angleDiscrepancies?.size}")

        val canvas = holder.lockCanvas()
        try {
            // เคลียร์ canvas
            canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)

            // กำหนดสีของเส้นตามความถูกต้องของท่า
        when (isPoseCorrect) {
            true -> linePaint.color = Color.GREEN // สีเขียวเมื่อท่าถูกต้อง
            false -> linePaint.color = Color.RED // สีแดงเมื่อท่าไม่ถูกต้อง
            null -> linePaint.color = Color.BLUE // สีน้ำเงิน (ค่าเริ่มต้น) เมื่อยังไม่ทราบสถานะ
        }

        currentResult?.landmarks()?.firstOrNull()?.let { landmarks ->
            // ส่วนวาด landmarks และเส้นเชื่อมยังคงเดิม...
            // ใช้วิธีการคำนวณที่ง่ายและแม่นยำขึ้น
            val viewWidth = width.toFloat()
            val viewHeight = height.toFloat()
            
            // ตรวจสอบว่า view มีการ flip หรือไม่ (กล้องหน้า)
            val isFlipped = scaleX < 0
            Log.d("OverlayView", "View is flipped: $isFlipped, scaleX: $scaleX")
            
            // วาดเส้นเชื่อมระหว่าง landmarks
            PoseLandmarker.POSE_LANDMARKS.forEach { connection ->
                if (connection != null) {
                    val start = landmarks[connection.start()]
                    val end = landmarks[connection.end()]

                    // ถ้า view ถูก flip ให้กลับค่า x เพื่อให้การวาดถูกต้อง
                    val startX = if (isFlipped) (1 - start.x()) * viewWidth else start.x() * viewWidth
                    val startY = start.y() * viewHeight
                    val endX = if (isFlipped) (1 - end.x()) * viewWidth else end.x() * viewWidth
                    val endY = end.y() * viewHeight

                    canvas.drawLine(startX, startY, endX, endY, linePaint)
                }
            }

                // วาดจุด landmarks
                landmarks.forEach { lm ->
                    // ถ้า view ถูก flip ให้กลับค่า x เพื่อให้การวาดถูกต้อง
                    val cx = if (isFlipped) (1 - lm.x()) * viewWidth else lm.x() * viewWidth
                    val cy = lm.y() * viewHeight
                    canvas.drawCircle(cx, cy, 10f, pointPaint)
                }

                // วาดตัวเลขแสดงค่ามุม (Angle) ที่คำนวณได้
                val angleTextPaint = Paint().apply {
                    color = Color.WHITE
                    textSize = 50f  // ลดขนาดตัวอักษรลงเพื่อให้ดูได้ชัดเจนขึ้น
                    style = Paint.Style.FILL
                    isAntiAlias = true
                }

                // mapping ชื่อมุมไปยัง index ของ landmark ที่ใช้แสดงค่า
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
                            // ถ้า view ถูก flip ให้กลับค่า x เพื่อให้การวาดถูกต้อง
                            val cx = if (isFlipped) (1 - lm.x()) * viewWidth else lm.x() * viewWidth
                            val cy = lm.y() * viewHeight
                            canvas.drawText("${angleValue.toInt()}°", cx, cy - 10f, angleTextPaint)
                        }
                    }
                }
                
                // วาดวงกลมรอบมุมที่ไม่ถูกต้อง
                angleDiscrepancies?.let { discrepancies ->
                    Log.d("OverlayView", "Drawing ${discrepancies.size} discrepancies")
                    
                    discrepancies.forEach { (angleName, discrepancy) ->
                        // ตรวจสอบความแตกต่างของมุม
                        val refAngle = discrepancy["reference_angle"] ?: 0.0
                        val userAngle = discrepancy["user_angle"] ?: 0.0
                        val difference = Math.abs(refAngle - userAngle)
                        
                        // แสดงเฉพาะความแตกต่างที่มากกว่า 30 องศา
                        if (difference > 30.0) {
                            Log.d("OverlayView", "Drawing discrepancy for $angleName (diff: $difference)")
                            
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
                                    // ถ้า view ถูก flip ให้กลับค่า x เพื่อให้การวาดถูกต้อง
                                    val cx = if (isFlipped) (1 - lm.x()) * viewWidth else lm.x() * viewWidth
                                    val cy = lm.y() * viewHeight
                                    
                                    // วาดวงกลมสีแดงเพื่อไฮไลต์มุมที่ไม่ถูกต้อง
                                    val highlightPaint = Paint().apply {
                                        color = Color.RED
                                        strokeWidth = 8f
                                        style = Paint.Style.STROKE
                                        isAntiAlias = true
                                    }
                                    
                                    // วาดวงกลมรอบข้อต่อ - ทำให้ใหญ่ขึ้นเพื่อให้เห็นชัดเจน
                                    canvas.drawCircle(cx, cy, 40f, highlightPaint)
                                    
                                    // วาดข้อความแก้ไข
                                    val correctionPaint = Paint().apply {
                                        color = Color.RED
                                        textSize = 60f
                                        style = Paint.Style.FILL
                                        isAntiAlias = true
                                    }
                                    
                                    // ปรับตำแหน่งข้อความตามการ flip
                                    val textX = if (isFlipped) cx - 40f - (refAngle.toInt().toString().length * 40f) else cx + 40f
                                    canvas.drawText("→ ${refAngle.toInt()}° (${(refAngle - userAngle).toInt()}°)", textX, cy, correctionPaint)
                                    
                                    Log.d("OverlayView", "Drew circle at $cx,$cy for $angleName")
                                }
                            }
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