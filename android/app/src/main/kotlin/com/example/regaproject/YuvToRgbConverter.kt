//D:\regaphone - Copy (2)\Rega-Project\regaproject\android\app\src\main\kotlin\com\example\regaproject\YuvToRgbConverter.kt
package com.example.regaproject

import android.content.Context
import android.graphics.Bitmap
import androidx.camera.core.ImageProxy
import android.renderscript.*

class YuvToRgbConverter(context: Context) {
    private val rs: RenderScript = RenderScript.create(context)
    private val scriptYuvToRgb: ScriptIntrinsicYuvToRGB =
        ScriptIntrinsicYuvToRGB.create(rs, Element.U8_4(rs))

    private var allocationYuv: Allocation? = null
    private var allocationRgb: Allocation? = null

    fun yuvToRgb(imageProxy: ImageProxy, bitmap: Bitmap) {
        val yuvBytes = imageProxy.planes.flatMap { plane ->
            val buffer = plane.buffer
            val bytes = ByteArray(buffer.remaining())
            buffer.get(bytes)
            bytes.toList()
        }.toByteArray()

        allocationYuv = Allocation.createSized(rs, Element.U8(rs), yuvBytes.size)
        allocationYuv?.copyFrom(yuvBytes)

        allocationRgb = Allocation.createFromBitmap(rs, bitmap)
        scriptYuvToRgb.setInput(allocationYuv)
        scriptYuvToRgb.forEach(allocationRgb)
        allocationRgb?.copyTo(bitmap)
    }

    fun release() {
        scriptYuvToRgb.destroy()
        allocationYuv?.destroy()
        allocationRgb?.destroy()
        rs.destroy()
    }
}