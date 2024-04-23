package com.avocadotech.tacttik.tact_tik

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

import android.os.Bundle

import com.avocadotech.tacttik.tact_tik.CountdownService


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.avocadotech.tacttik.tact_tik/countdown_service"

   override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    flutterEngine?.let { CountdownService.setFlutterEngine(it) }
}

override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    CountdownService.setFlutterEngine(flutterEngine)

}
}
