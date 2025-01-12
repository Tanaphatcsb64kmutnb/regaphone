//D:\regaphone - Copy (2)\Rega-Project\regaproject\android\app\src\main\kotlin\com\example\regaproject\PoseOverlayViewFactory.kt
package com.example.regaproject

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class PoseOverlayViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return PoseOverlayPlatformView(context)
    }
}

class PoseOverlayPlatformView(
    context: Context
) : PlatformView {
    private val overlayView = OverlayView(context, null)

    override fun getView(): View {
        return overlayView
    }

    override fun dispose() {}
}