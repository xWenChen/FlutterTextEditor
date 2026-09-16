package com.example.flutter_text_editor

import android.app.Application

class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        appContext = this
    }

    companion object {
        lateinit var appContext: MainApplication
            private set
    }
}