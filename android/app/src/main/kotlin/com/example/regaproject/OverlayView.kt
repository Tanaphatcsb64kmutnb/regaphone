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
import com.google.mediapipe.tasks.components.containers.NormalizedLandmark

class OverlayView(context: Context?, attrs: AttributeSet?) : SurfaceView(context, attrs), SurfaceHolder.Callback {

    private var currentResult: PoseLandmarkerResult? = null
    private var angleMap: Map<String, Double>? = null
    private var angleDiscrepancies: Map<String, Map<String, Double>>? = null
    private var isPoseCorrect: Boolean? = null // null = ยังไม่ทราบ, true = ถูกต้อง, false = ไม่ถูกต้อง

    // ตัวแปรควบคุมเอฟเฟกต์กระพริบ
    private var pulseValue = 0f
    private var pulseIncreasing = true
    private var lastPulseUpdateTime = 0L
    private var topErrorJoints = mutableListOf<Pair<String, Map<String, Double>>>() // เก็บเฉพาะจุดที่มีปัญหามากที่สุด

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

    // ฟังก์ชันรับค่าความแตกต่างของมุม - ปรับปรุงใหม่
    fun setAngleDiscrepancies(discrepancies: Map<String, Map<String, Double>>?) {
        Log.d("OverlayView", "setAngleDiscrepancies called with ${discrepancies?.size ?: 0} items")
        angleDiscrepancies = discrepancies
        
        // เตรียมข้อมูลจุดที่มีปัญหาทั้งหมด (ไม่จำกัดจำนวน)
        topErrorJoints.clear()
        discrepancies?.forEach { (angleName, discrepancy) ->
            val refAngle = discrepancy["reference_angle"] ?: 0.0
            val userAngle = discrepancy["user_angle"] ?: 0.0
            val difference = Math.abs(refAngle - userAngle)
            if (difference > 20.0) { // แสดงเฉพาะจุดที่มีความแตกต่างมากกว่า 20 องศา
                topErrorJoints.add(Pair(angleName, discrepancy))
            }
        }
        
        // เรียงลำดับจากมากไปน้อย (เพื่อให้จุดที่มีปัญหามากที่สุดทับซ้อนอยู่ด้านบนสุด)
        topErrorJoints.sortByDescending { 
            Math.abs((it.second["reference_angle"] ?: 0.0) - (it.second["user_angle"] ?: 0.0)) 
        }
        
        post { drawOverlay() }
    }

    // ฟังก์ชันตั้งค่าความถูกต้องของท่า
    fun setPoseCorrectness(isCorrect: Boolean) {
        isPoseCorrect = isCorrect
        post { drawOverlay() }
    }

    // ฟังก์ชันหลักสำหรับวาดจุดที่มีปัญหา
    private fun drawErrorIndicator(canvas: Canvas, landmarks: List<NormalizedLandmark>, angleName: String, discrepancy: Map<String, Double>, isFlipped: Boolean) {
        // ค้นหา index ของจุดที่มีปัญหา
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
        } ?: return

        if (midIndex >= landmarks.size) return

        // คำนวณตำแหน่งของจุดบนหน้าจอ
        val viewWidth = width.toFloat()
        val viewHeight = height.toFloat()
        val lm = landmarks[midIndex]
        val cx = if (isFlipped) (1 - lm.x()) * viewWidth else lm.x() * viewWidth
        val cy = lm.y() * viewHeight

        // คำนวณค่าความแตกต่าง
        val refAngle = discrepancy["reference_angle"] ?: 0.0
        val userAngle = discrepancy["user_angle"] ?: 0.0
        val difference = refAngle - userAngle

        // อัปเดตค่า pulse สำหรับเอฟเฟกต์กระพริบ
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastPulseUpdateTime > 30) { // อัพเดททุก 30ms
            if (pulseIncreasing) {
                pulseValue += 0.05f
                if (pulseValue >= 1.0f) {
                    pulseValue = 1.0f
                    pulseIncreasing = false
                }
            } else {
                pulseValue -= 0.05f
                if (pulseValue <= 0.2f) {
                    pulseValue = 0.2f
                    pulseIncreasing = true
                }
            }
            lastPulseUpdateTime = currentTime
        }

        // 1. วาดวงแหวนเรืองแสงสีเหลือง (เพื่อให้เด่นชัดกว่าเส้นสีแดง)
        val glowPaint = Paint().apply {
            color = Color.YELLOW
            strokeWidth = 10f * (0.7f + (pulseValue * 0.3f))
            style = Paint.Style.STROKE
            isAntiAlias = true
            
            // เพิ่มเอฟเฟกต์เรืองแสง (ถ้าอุปกรณ์รองรับ)
            try {
                maskFilter = BlurMaskFilter(15f * pulseValue, BlurMaskFilter.Blur.NORMAL)
            } catch (e: Exception) {
                // บางอุปกรณ์อาจไม่รองรับ BlurMaskFilter
                Log.e("OverlayView", "Error setting blur: ${e.message}")
            }
        }
        
        // วาดวงแหวนชั้นแรก
        canvas.drawCircle(cx, cy, 35f + (pulseValue * 10f), glowPaint)
        
        // 2. วาดวงแหวนสีเหลืองสด (ตัดกับสีแดงชัดเจน)
        val outerPaint = Paint().apply {
            color = Color.YELLOW
            strokeWidth = 5f
            style = Paint.Style.STROKE
            isAntiAlias = true
        }
        canvas.drawCircle(cx, cy, 45f + (pulseValue * 10f), outerPaint)

        // 3. คำนวณทิศทางการแก้ไข (ดัดมากขึ้นหรือน้อยลง)
        val absValue = Math.abs(difference).toInt()
        
        // วาดพื้นหลังสีดำโปร่งใสเพื่อให้มองเห็นตัวเลขชัดเจน
        val bgPaint = Paint().apply {
            color = Color.BLACK
            alpha = 150
            style = Paint.Style.FILL
            isAntiAlias = true
        }
        
        canvas.drawCircle(cx, cy, 25f, bgPaint)
        
        // 4. วาดข้อความแสดงค่ามุมที่ถูกต้อง
        val textPaint = Paint().apply {
            color = Color.YELLOW
            textSize = 40f
            style = Paint.Style.FILL
            isAntiAlias = true
            textAlign = Paint.Align.CENTER
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        
        // วาดลูกศรบอกทิศทาง
        val arrowStr = if (difference > 0) "↑" else "↓"
        canvas.drawText("$arrowStr$absValue°", cx, cy + 15f, textPaint)
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
                
                // วาดจุดที่มีปัญหาทั้งหมดด้วยเทคนิคใหม่ (เฉพาะเมื่อ isPoseCorrect เป็น false)
                // เมื่อทำท่าถูกต้อง (isPoseCorrect == true) จะไม่แสดงวงกลมใดๆ
                if (isPoseCorrect == false && topErrorJoints.isNotEmpty()) {
                    topErrorJoints.forEach { (angleName, discrepancy) ->
                        drawErrorIndicator(canvas, landmarks, angleName, discrepancy, isFlipped)
                    }
                }
                // เมื่อทำท่าถูกต้อง (isPoseCorrect == true) ไม่ต้องวาดวงกลมแสดงจุดที่ผิด
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