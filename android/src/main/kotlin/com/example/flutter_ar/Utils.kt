package com.example.flutter_ar

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.loader.FlutterLoader


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