package com.example.regaproject

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class PoseOverlayViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
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