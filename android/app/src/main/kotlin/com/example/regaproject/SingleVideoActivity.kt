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
import android.app.ProgressDialog
import com.google.firebase.storage.FirebaseStorage
import android.widget.Toast

class SingleVideoActivity : Activity() {
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
            setMessage("กำลังโหลดวิดีโอ...")
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

        Log.d("SingleVideoActivity", "Loading video from Firebase Storage: Yogavideo/$videoFileName")

        // ดึง URL สำหรับสตรีมวิดีโอ
        videoRef.downloadUrl.addOnSuccessListener { uri ->
            Log.d("SingleVideoActivity", "Video URL retrieved: $uri")
            
            // ตั้งค่า VideoView
            videoView.setVideoURI(uri)
            
            // เพิ่ม Media Controller สำหรับควบคุมการเล่นวิดีโอ
            val mediaController = MediaController(this)
            mediaController.setAnchorView(videoView)
            videoView.setMediaController(mediaController)

            // เล่นวิดีโอเมื่อพร้อม
            videoView.setOnPreparedListener { mediaPlayer ->
                progressDialog.dismiss()
                mediaPlayer.setVideoScalingMode(android.media.MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT)
                mediaPlayer.start()
                Log.d("SingleVideoActivity", "Video playback started")
            }

            // จัดการเมื่อเล่นวิดีโอเสร็จ
            videoView.setOnCompletionListener {
                Log.d("SingleVideoActivity", "Video playback completed")
                finish() // ปิดกิจกรรมเมื่อเล่นวิดีโอเสร็จ
            }
            
            // จัดการเมื่อเกิดข้อผิดพลาด
            videoView.setOnErrorListener { mediaPlayer, what, extra ->
                progressDialog.dismiss()
                Log.e("SingleVideoActivity", "Error playing video: what=$what, extra=$extra")
                Toast.makeText(this, "ไม่สามารถเล่นวิดีโอได้", Toast.LENGTH_SHORT).show()
                finish() // ปิดกิจกรรมเมื่อเกิดข้อผิดพลาด
                true
            }
        }.addOnFailureListener { exception ->
            progressDialog.dismiss()
            Log.e("SingleVideoActivity", "Failed to get video URL: ${exception.message}")
            Toast.makeText(this, "ไม่พบวิดีโอที่ต้องการ", Toast.LENGTH_SHORT).show()
            
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
                Log.d("SingleVideoActivity", "Using backup video from raw resource: $bareFileName")
                val videoUri = Uri.parse("android.resource://${packageName}/raw/${bareFileName}")
                videoView.setVideoURI(videoUri)
                
                videoView.setOnPreparedListener { mediaPlayer ->
                    mediaPlayer.setVideoScalingMode(android.media.MediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT)
                    mediaPlayer.start()
                }
                
                videoView.setOnCompletionListener {
                    finish()
                }
            } else {
                // ไม่พบไฟล์ ปิดกิจกรรม
                finish()
            }
        } catch (e: Exception) {
            Log.e("SingleVideoActivity", "Error playing backup video: ${e.message}")
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