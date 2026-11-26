package com.example.life_loop

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.AtomicFile
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.Executors

/** Only Android-specific work: app-private local storage and the share chooser. */
class SprintTwoBridge(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "life_loop/sprint_two")
    private val mainThread = Handler(Looper.getMainLooper())
    private val disk = Executors.newSingleThreadExecutor()
    private val postsFile = AtomicFile(File(activity.filesDir, "lifeloop_sprint_two_posts_v1.json"))
    @Volatile private var closed = false

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "readPosts" -> onDisk(result) {
                val base = postsFile.baseFile
                if (!base.exists()) {
                    return@onDisk null
                }
                try {
                    val bytes = postsFile.readFully()
                    if (bytes.isEmpty()) null else bytes.toString(Charsets.UTF_8)
                } catch (_: Exception) {
                    null
                }
            }
            "writePosts" -> {
                val contents = call.argument<String>("contents")
                if (contents == null) {
                    result.error("INVALID_ARGUMENT", "Post data is required.", null)
                    return
                }
                onDisk(result) {
                    // Reject malformed input before touching the existing file.
                    val document = JSONObject(contents)
                    require(document.getInt("version") == 1) { "Unsupported data version." }
                    document.getJSONArray("posts")
                    val bytes = contents.toByteArray(Charsets.UTF_8)
                    require(bytes.size <= 5 * 1024 * 1024) { "Local preview storage is full." }
                    var stream: FileOutputStream? = null
                    try {
                        stream = postsFile.startWrite()
                        stream.write(bytes)
                        postsFile.finishWrite(stream)
                    } catch (error: Exception) {
                        postsFile.failWrite(stream)
                        throw error
                    }
                    null
                }
            }
            "sharePost" -> sharePost(call, result)
            else -> result.notImplemented()
        }
    }

    private fun onDisk(result: MethodChannel.Result, action: () -> Any?) {
        disk.execute {
            try {
                val value = action()
                mainThread.post { if (!closed) result.success(value) }
            } catch (_: Exception) {
                // Do not leak post text or filesystem paths into error messages.
                mainThread.post {
                    if (!closed) result.error("STORAGE_ERROR", "Could not access saved posts.", null)
                }
            }
        }
    }

    private fun sharePost(call: MethodCall, result: MethodChannel.Result) {
        val text = call.argument<String>("text")
        if (text.isNullOrBlank()) {
            result.error("INVALID_ARGUMENT", "Post text is required.", null)
            return
        }
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
            putExtra(Intent.EXTRA_SUBJECT, call.argument<String>("subject") ?: "LifeLoop post")
        }
        try {
            activity.startActivity(Intent.createChooser(send, "Share post"))
            // Only confirms the chooser opened. The user may cancel it.
            result.success(null)
        } catch (_: ActivityNotFoundException) {
            result.error("SHARE_UNAVAILABLE", "No sharing app is available.", null)
        } catch (_: SecurityException) {
            result.error("SHARE_UNAVAILABLE", "Android could not open sharing.", null)
        }
    }

    fun close() {
        closed = true
        channel.setMethodCallHandler(null)
        disk.shutdown()
    }
}
