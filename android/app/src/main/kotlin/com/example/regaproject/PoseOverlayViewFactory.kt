//PoseOverlayViewFactory.kt
package com.example.regaproject

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class PoseOverlayViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        // อ่านค่า creationParams จาก Flutter
        val params = args as? Map<String, Any>
        val pointColor = params?.get("pointColor") as? String ?: "#FFFF00" // ค่าเริ่มต้นเป็นสีเหลือง
        val lineColor = params?.get("lineColor") as? String ?: "#FF0000" // ค่าเริ่มต้นเป็นสีแดง
        val pointSize = (params?.get("pointSize") as? Double ?: 8.0).toFloat()

        return PoseOverlayPlatformView(context, pointColor, lineColor, pointSize)
    }
}

class PoseOverlayPlatformView(
    context: Context,
    pointColor: String,
    lineColor: String,
    pointSize: Float
) : PlatformView {
    private val overlayView = OverlayView(context, null).apply {
        setOverlaySettings(pointColor, lineColor, pointSize)
    }

    override fun getView(): View {
        return overlayView
    }

    override fun dispose() {}
}