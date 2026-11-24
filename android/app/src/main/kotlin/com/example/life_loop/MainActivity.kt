package com.example.life_loop

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var sprintTwoBridge: SprintTwoBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sprintTwoBridge = SprintTwoBridge(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        sprintTwoBridge?.close()
        sprintTwoBridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
