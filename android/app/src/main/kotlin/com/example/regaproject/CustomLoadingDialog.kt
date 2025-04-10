package com.example.regaproject

import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.Window
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import android.widget.ImageView
import android.widget.TextView

class CustomLoadingDialog(context: Context, private val poseName: String? = null) : Dialog(context) {
    
    private lateinit var ivLotus: ImageView
    private lateinit var tvMessage: TextView
    private lateinit var tvTitle: TextView
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        setCancelable(false)
        
        // Inflate custom layout
        val view = LayoutInflater.from(context).inflate(R.layout.dialog_loading, null)
        setContentView(view)
        
        // Initialize views
        ivLotus = findViewById(R.id.iv_lotus)
        tvMessage = findViewById(R.id.tv_message)
        tvTitle = findViewById(R.id.tv_title)
        
        // Set text
        tvTitle.text = "พร้อมหรือยัง? "
        
        // ถ้ามีชื่อท่า ให้แสดงข้อความที่มีชื่อท่า แต่ถ้าไม่มีให้แสดงข้อความทั่วไป
        tvMessage.text = if (poseName != null && poseName.isNotEmpty()) {
            "ท้าโยคะกำลังเริ่มขึ้น!"
        } else {
            "ท้าโยคะกำลังเริ่มขึ้น!"
        }
        
        // Start animation
        val rotateAnimation = AnimationUtils.loadAnimation(context, R.anim.rotate)
        ivLotus.startAnimation(rotateAnimation)
    }
}