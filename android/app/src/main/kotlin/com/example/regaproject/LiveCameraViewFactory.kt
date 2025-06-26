//package com.csbkmutnb64.regaproject
package com.csbkmutnb64v3.regaproject

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class LiveCameraViewFactory(
    private val activity: MainActivity,
    private val methodChannel: MethodChannel
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<String, Any>
        val isFrontCamera = params?.get("camera") == "front"
        // ส่ง MainActivity ไปให้ LiveCameraPlatformView แทน context ที่ได้จากระบบ
        return LiveCameraPlatformView(activity, methodChannel, isFrontCamera)
    }
}