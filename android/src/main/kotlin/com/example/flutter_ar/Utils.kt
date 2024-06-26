package com.example.flutter_ar

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.loader.FlutterLoader
import android.app.Activity
import android.view.View
import android.view.WindowManager
import androidx.core.graphics.Insets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.core.view.doOnAttach
import androidx.fragment.app.Fragment


class Utils {
    companion object {
        fun getFlutterAssetKey(context: Context, flutterAsset: String): String {
            Log.d("Utils", flutterAsset)
            //val assetManager: AssetManager = context.assets
            val loader = FlutterLoader()
            loader.startInitialization(context)
            return loader.getLookupKeyForAsset(flutterAsset)
            //val fd = assetManager.openFd(key)

        }
    }
}