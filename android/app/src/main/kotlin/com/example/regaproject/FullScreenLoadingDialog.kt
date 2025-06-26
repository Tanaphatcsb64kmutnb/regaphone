//package com.csbkmutnb64.regaproject
package com.csbkmutnb64v3.regaproject

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.os.Bundle
import android.util.DisplayMetrics
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.Window
import android.view.WindowInsets
import android.view.WindowManager
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout

class FullScreenLoadingDialog(context: Context) : Dialog(context, android.R.style.Theme_Black_NoTitleBar_Fullscreen) {
    
    private lateinit var messageView: TextView
    private lateinit var titleView: TextView
    private lateinit var breatheInView: View
    private lateinit var breatheOutView: View
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // ใช้ theme เต็มจอตั้งแต่ต้น และไม่จำเป็นต้อง requestWindowFeature(Window.FEATURE_NO_TITLE)
        
        // ตั้งค่าให้ Dialog เต็มจอ
        window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        
        // ตั้งค่า flag เหมือนกับใน VideoActivity
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // API 30+ (Android 11+)
            window?.setDecorFitsSystemWindows(false)
            window?.insetsController?.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
            window?.insetsController?.systemBarsBehavior = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
        } else {
            @Suppress("DEPRECATION")
            window?.decorView?.systemUiVisibility = (View.SYSTEM_UI_FLAG_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)
        }
                
        // ใช้ FLAG ทั้งหมดที่จำเป็นสำหรับเต็มจอ
        window?.addFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
        
        // ตั้งค่าขนาดให้เท่ากับขนาดจอจริงๆ ไม่ใช่แค่ MATCH_PARENT
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val metrics = windowManager.currentWindowMetrics
            val width = metrics.bounds.width()
            val height = metrics.bounds.height()
            window?.setLayout(width, height)
        } else {
            val displayMetrics = DisplayMetrics()
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.getRealMetrics(displayMetrics)
            window?.setLayout(displayMetrics.widthPixels, displayMetrics.heightPixels)
        }
        
        window?.setGravity(Gravity.CENTER)
        
        // ตั้งค่าให้ไม่สามารถยกเลิก Dialog ได้
        setCancelable(false)
        
        // Inflate custom layout
        val view = LayoutInflater.from(context).inflate(R.layout.dialog_fullscreen_loading, null)
        setContentView(view)
        
        // Initialize views
        titleView = findViewById(R.id.tv_title)
        messageView = findViewById(R.id.tv_message)
        breatheInView = findViewById(R.id.breathe_in_circle)
        breatheOutView = findViewById(R.id.breathe_out_circle)
        
        // Set text
        titleView.text = "เตรียมพร้อม"
        messageView.text = "ท่าโยคะกำลังจะเริ่มขึ้น ผ่อนคลายและหายใจลึกๆ"
        
        // Start breathing animation
        startBreathingAnimation()
    }
    
    private fun startBreathingAnimation() {
        // Breathing animation for inner circle (breathe in)
        val breatheInScaleX = ObjectAnimator.ofFloat(breatheInView, "scaleX", 0.8f, 1.0f)
        breatheInScaleX.duration = 4000
        breatheInScaleX.repeatCount = ObjectAnimator.INFINITE
        breatheInScaleX.repeatMode = ObjectAnimator.REVERSE
        
        val breatheInScaleY = ObjectAnimator.ofFloat(breatheInView, "scaleY", 0.8f, 1.0f)
        breatheInScaleY.duration = 4000
        breatheInScaleY.repeatCount = ObjectAnimator.INFINITE
        breatheInScaleY.repeatMode = ObjectAnimator.REVERSE
        
        val breatheInAlpha = ObjectAnimator.ofFloat(breatheInView, "alpha", 0.5f, 0.9f)
        breatheInAlpha.duration = 4000
        breatheInAlpha.repeatCount = ObjectAnimator.INFINITE
        breatheInAlpha.repeatMode = ObjectAnimator.REVERSE
        
        // Breathing animation for outer circle (breathe out)
        val breatheOutScaleX = ObjectAnimator.ofFloat(breatheOutView, "scaleX", 1.0f, 1.2f)
        breatheOutScaleX.duration = 4000
        breatheOutScaleX.repeatCount = ObjectAnimator.INFINITE
        breatheOutScaleX.repeatMode = ObjectAnimator.REVERSE
        
        val breatheOutScaleY = ObjectAnimator.ofFloat(breatheOutView, "scaleY", 1.0f, 1.2f)
        breatheOutScaleY.duration = 4000
        breatheOutScaleY.repeatCount = ObjectAnimator.INFINITE
        breatheOutScaleY.repeatMode = ObjectAnimator.REVERSE
        
        val breatheOutAlpha = ObjectAnimator.ofFloat(breatheOutView, "alpha", 0.9f, 0.3f)
        breatheOutAlpha.duration = 4000
        breatheOutAlpha.repeatCount = ObjectAnimator.INFINITE
        breatheOutAlpha.repeatMode = ObjectAnimator.REVERSE
        
        // Create animator sets and start animation
        val breatheInSet = AnimatorSet()
        breatheInSet.playTogether(breatheInScaleX, breatheInScaleY, breatheInAlpha)
        
        val breatheOutSet = AnimatorSet()
        breatheOutSet.playTogether(breatheOutScaleX, breatheOutScaleY, breatheOutAlpha)
        
        val completeSet = AnimatorSet()
        completeSet.playTogether(breatheInSet, breatheOutSet)
        completeSet.start()
    }
    
    // รักษาสถานะเต็มจอเมื่อมีการเปลี่ยนแปลง focus
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                window?.setDecorFitsSystemWindows(false)
                window?.insetsController?.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
                window?.insetsController?.systemBarsBehavior = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
            } else {
                @Suppress("DEPRECATION")
                window?.decorView?.systemUiVisibility = (View.SYSTEM_UI_FLAG_FULLSCREEN
                        or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                        or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)
            }
        }
    }
}