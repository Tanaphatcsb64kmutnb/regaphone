package com.example.regaproject

import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.VideoView
import android.app.Activity
import android.view.ViewGroup
import android.widget.RelativeLayout
import android.util.Log
import android.widget.MediaController
import java.io.File

class SingleVideoActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set full screen flags
        window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)

        // Create RelativeLayout as root container
        val layout = RelativeLayout(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }

        // Create and setup VideoView
        val videoView = VideoView(this).apply {
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            ).apply {
                addRule(RelativeLayout.CENTER_IN_PARENT)
            }
        }

        // Add VideoView to layout
        layout.addView(videoView)
        setContentView(layout)

        // เพิ่ม Media Controller สำหรับควบคุมการเล่นวิดีโอ
        val mediaController = MediaController(this)
        mediaController.setAnchorView(videoView)
        videoView.setMediaController(mediaController)

        // ดูว่าเรารับ path จาก local storage หรือไม่
        val videoPath = intent.getStringExtra("videoPath")
        
        if (videoPath != null && videoPath.isNotEmpty()) {
            // กรณีเล่นจาก local storage path
            Log.d("SingleVideoActivity", "Attempting to play video from path: $videoPath")
            try {
                val file = File(videoPath)
                if (file.exists()) {
                    val uri = Uri.fromFile(file)
                    videoView.setVideoURI(uri)
                    Log.d("SingleVideoActivity", "Video file exists at: $videoPath")
                } else {
                    Log.e("SingleVideoActivity", "Video file does not exist: $videoPath")
                    finish()
                    return
                }
            } catch (e: Exception) {
                Log.e("SingleVideoActivity", "Error setting video from path: ${e.message}")
                finish()
                return
            }
        } else {
            // กรณีเล่นจาก raw resources (แบบเดิม)
            val videoFileName = intent.getStringExtra("videoFileName") ?: "rest_video"
            
            // ตัดนามสกุลไฟล์ออกถ้ามี
            val bareFileName = if (videoFileName.contains(".")) {
                videoFileName.substring(0, videoFileName.lastIndexOf("."))
            } else {
                videoFileName
            }
            
            Log.d("SingleVideoActivity", "Attempting to play video from raw: $bareFileName")
            
            // ดึง resource ID จากชื่อไฟล์
            val resourceId = resources.getIdentifier(bareFileName, "raw", packageName)
            
            if (resourceId != 0) {
                // พบไฟล์ในโฟลเดอร์ raw
                Log.d("SingleVideoActivity", "Found video resource with id: $resourceId")
                val videoUri = Uri.parse("android.resource://${packageName}/raw/${bareFileName}")
                videoView.setVideoURI(videoUri)
            } else {
                // ไม่พบไฟล์ แจ้งข้อผิดพลาด
                Log.e("SingleVideoActivity", "Video resource not found: $bareFileName")
                finish() // ปิดกิจกรรมถ้าไม่พบไฟล์
                return
            }
        }

        // Set video scaling
        videoView.setOnPreparedListener { mediaPlayer ->
            mediaPlayer.setVideoScalingMode(android.media.MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT)
            mediaPlayer.start()
            Log.d("SingleVideoActivity", "Video playback started")
        }

        // Handle video completion
        videoView.setOnCompletionListener {
            Log.d("SingleVideoActivity", "Video playback completed")
            finish() // ปิดกิจกรรมเมื่อเล่นวิดีโอเสร็จ
        }
        
        // Handle errors
        videoView.setOnErrorListener { mediaPlayer, what, extra ->
            Log.e("SingleVideoActivity", "Error playing video: what=$what, extra=$extra")
            finish() // ปิดกิจกรรมเมื่อเกิดข้อผิดพลาด
            true
        }
    }

    // Prevent accidental exit from fullscreen
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)
        }
    }
}