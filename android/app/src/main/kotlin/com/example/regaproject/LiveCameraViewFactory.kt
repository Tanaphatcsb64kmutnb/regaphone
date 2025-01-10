//LiveCameraViewFactory
package com.example.regaproject

import android.content.Context
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class LiveCameraViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
   override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    val params = args as? Map<String, Any>
    val isFrontCamera = params?.get("camera") == "front"
    return LiveCameraPlatformView(context, isFrontCamera)
}

}
