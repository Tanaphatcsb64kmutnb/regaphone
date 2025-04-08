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
import android.app.ProgressDialog
import com.google.firebase.storage.FirebaseStorage
import android.widget.Toast

class VideoActivity : Activity() {
    private lateinit var videoView: VideoView
    private lateinit var progressDialog: ProgressDialog

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
        videoView = VideoView(this).apply {
            layoutParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            ).apply {
                addRule(RelativeLayout.CENTER_IN_PARENT)
            }
        }

        // Create progress dialog
        progressDialog = ProgressDialog(this).apply {
            setMessage("กำลังโหลดวิดีโอสอนท่า...")
            setCancelable(false)
            setProgressStyle(ProgressDialog.STYLE_SPINNER)
        }

        // Add VideoView to layout
        layout.addView(videoView)
        setContentView(layout)

        // รับชื่อไฟล์วิดีโอจาก intent
        val videoFileName = intent.getStringExtra("videoFileName") ?: "rest_video.mp4"
        
        // เริ่มโหลดและเล่นวิดีโอจาก Firebase Storage
        loadVideoFromFirebaseStorage(videoFileName)
    }

    private fun loadVideoFromFirebaseStorage(videoFileName: String) {
        progressDialog.show()

        // สร้าง path ให้ถูกต้อง
        val storageRef = FirebaseStorage.getInstance().reference
        val videoRef = storageRef.child("Yogavideo/$videoFileName")

        Log.d("VideoActivity", "Loading video from Firebase Storage: Yogavideo/$videoFileName")

        // ดึง URL สำหรับสตรีมวิดีโอ
        videoRef.downloadUrl.addOnSuccessListener { uri ->
            Log.d("VideoActivity", "Video URL retrieved: $uri")
            
            // ตั้งค่า VideoView
            videoView.setVideoURI(uri)

            // เล่นวิดีโอเมื่อพร้อม
            videoView.setOnPreparedListener { mediaPlayer ->
                progressDialog.dismiss()
                mediaPlayer.setVideoScalingMode(android.media.MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING)
                mediaPlayer.start()
                Log.d("VideoActivity", "Video playback started")
            }

            // จัดการเมื่อเล่นวิดีโอเสร็จ
            videoView.setOnCompletionListener {
                Log.d("VideoActivity", "Video playback completed")
                setResult(Activity.RESULT_OK)
                finish()
            }
            
            // จัดการเมื่อเกิดข้อผิดพลาด
            videoView.setOnErrorListener { mediaPlayer, what, extra ->
                progressDialog.dismiss()
                Log.e("VideoActivity", "Error playing video: what=$what, extra=$extra")
                Toast.makeText(this, "ไม่สามารถเล่นวิดีโอได้", Toast.LENGTH_SHORT).show()
                setResult(Activity.RESULT_OK) // Return OK anyway to continue the flow
                finish()
                true
            }
        }.addOnFailureListener { exception ->
            progressDialog.dismiss()
            Log.e("VideoActivity", "Failed to get video URL: ${exception.message}")
            Toast.makeText(this, "ไม่พบวิดีโอสอนท่า กำลังใช้วิดีโอสำรอง", Toast.LENGTH_SHORT).show()
            
            // ลองใช้วิดีโอในแอปเป็นตัวสำรอง
            tryPlayBackupVideo(videoFileName)
        }
    }

    private fun tryPlayBackupVideo(videoFileName: String) {
        try {
            // ตัดนามสกุลไฟล์ออกถ้ามี
            val bareFileName = if (videoFileName.contains(".")) {
                videoFileName.substring(0, videoFileName.lastIndexOf("."))
            } else {
                videoFileName
            }
            
            // ลองหาไฟล์ในโฟลเดอร์ raw เป็นตัวสำรอง
            val resourceId = resources.getIdentifier(bareFileName, "raw", packageName)
            
            if (resourceId != 0) {
                // พบไฟล์ในโฟลเดอร์ raw
                Log.d("VideoActivity", "Using backup video from raw resource: $bareFileName")
                val videoUri = Uri.parse("android.resource://${packageName}/raw/${bareFileName}")
                videoView.setVideoURI(videoUri)
                
                videoView.setOnPreparedListener { mediaPlayer ->
                    mediaPlayer.setVideoScalingMode(android.media.MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING)
                    mediaPlayer.start()
                }
                
                videoView.setOnCompletionListener {
                    setResult(Activity.RESULT_OK)
                    finish()
                }
            } else {
                // ใช้ rest_video เป็นค่าเริ่มต้น
                Log.d("VideoActivity", "Video resource not found: $bareFileName, using default")
                val defaultUri = Uri.parse("android.resource://${packageName}/raw/rest_video")
                videoView.setVideoURI(defaultUri)
                
                videoView.setOnPreparedListener { mediaPlayer ->
                    mediaPlayer.setVideoScalingMode(android.media.MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING)
                    mediaPlayer.start()
                }
                
                videoView.setOnCompletionListener {
                    setResult(Activity.RESULT_OK)
                    finish()
                }
            }
        } catch (e: Exception) {
            Log.e("VideoActivity", "Error playing backup video: ${e.message}")
            setResult(Activity.RESULT_OK)
            finish()
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
    
    override fun onDestroy() {
        super.onDestroy()
        if (progressDialog.isShowing) {
            progressDialog.dismiss()
        }
    }
}