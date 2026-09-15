package com.wellcherish.flutter_text_editor

import com.example.flutter_text_editor.datasync.DataSyncMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 注册MethodChannel
        DataSyncMethodChannel.register(flutterEngine)
    }
}
