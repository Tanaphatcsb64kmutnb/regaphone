package com.example.regaproject

import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.VideoView
import android.app.Activity
import android.widget.MediaController
import android.view.ViewGroup
import android.widget.RelativeLayout
import android.util.Log

class VideoActivity : Activity() {
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

        // รับชื่อไฟล์วิดีโอจาก intent
        val videoFileName = intent.getStringExtra("videoFileName") ?: "rest_video"
        
        // ตัดนามสกุลไฟล์ออกถ้ามี
        val bareFileName = if (videoFileName.contains(".")) {
            videoFileName.substring(0, videoFileName.lastIndexOf("."))
        } else {
            videoFileName
        }
        
        Log.d("VideoActivity", "Attempting to play video: $bareFileName")
        
        // ดึง resource ID จากชื่อไฟล์
        val resourceId = resources.getIdentifier(bareFileName, "raw", packageName)
        
        if (resourceId != 0) {
            // พบไฟล์ในโฟลเดอร์ raw
            Log.d("VideoActivity", "Found video resource with id: $resourceId")
            val videoUri = Uri.parse("android.resource://${packageName}/raw/${bareFileName}")
            videoView.setVideoURI(videoUri)
        } else {
            // ไม่พบไฟล์ ใช้ rest_video เป็นค่าเริ่มต้น
            Log.e("VideoActivity", "Video resource not found: $bareFileName, using default")
            val defaultUri = Uri.parse("android.resource://${packageName}/raw/rest_video")
            videoView.setVideoURI(defaultUri)
        }

        // Set video scaling
        videoView.setOnPreparedListener { mediaPlayer ->
            mediaPlayer.setVideoScalingMode(android.media.MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING)
            mediaPlayer.start()
            Log.d("VideoActivity", "Video playback started")
        }

        // Handle video completion
        videoView.setOnCompletionListener {
            Log.d("VideoActivity", "Video playback completed")
            setResult(Activity.RESULT_OK)
            finish()
        }
        
        // Handle errors
        videoView.setOnErrorListener { mediaPlayer, what, extra ->
            Log.e("VideoActivity", "Error playing video: what=$what, extra=$extra")
            setResult(Activity.RESULT_OK) // Return OK anyway to continue the flow
            finish()
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