package com.example.flutter_ar

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.lifecycle.Lifecycle
import com.google.ar.core.Anchor
import com.google.ar.core.Config
import com.google.ar.core.Plane
import com.google.ar.core.TrackingFailureReason
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.ar.arcore.getUpdatedPlanes
import io.github.sceneview.ar.node.AnchorNode
import io.github.sceneview.math.Position
import io.github.sceneview.node.ModelNode
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class FlutterArWrapper(
    context: Context,
    private val activity: Activity,
    lifecycle: Lifecycle,
    messenger: BinaryMessenger,
    id: Int,
) : PlatformView, MethodCallHandler {
    private val TAG = "SceneViewWrapper"
    private var sceneView: ARSceneView
    private val mainScope = CoroutineScope(Dispatchers.Main)
    private val channel = MethodChannel(messenger, "scene_view_$id")

    private var anchorNode: AnchorNode? = null
    private var currentTrackingFailureReason: TrackingFailureReason? = null

    override fun getView(): View {
        return sceneView
    }

    override fun dispose() {
        Log.i(TAG, "dispose")
    }

    init {
        Log.i(TAG, "init")
        sceneView = ARSceneView(context, sharedLifecycle = lifecycle)
        sceneView.apply {
            planeRenderer.isEnabled = true
            configureSession { session, config ->
                config.lightEstimationMode = Config.LightEstimationMode.ENVIRONMENTAL_HDR
                config.depthMode = when (session.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) {
                    true -> Config.DepthMode.AUTOMATIC
                    else -> Config.DepthMode.DISABLED
                }
                config.instantPlacementMode = Config.InstantPlacementMode.DISABLED
            }
            onSessionUpdated = { _, frame ->
                if (anchorNode == null) {
                    frame.getUpdatedPlanes()
                        .firstOrNull { it.type == Plane.Type.HORIZONTAL_UPWARD_FACING }
                        ?.let { plane ->
                            addAnchorNode(plane.createAnchor(plane.centerPose))
                        }
                }
            }
            onTrackingFailureChanged = { reason ->
                if (currentTrackingFailureReason != reason) {
                    currentTrackingFailureReason = reason
                    channel.invokeMethod("onTrackingFailureChanged", reason?.name)
                }
            }

        }
        sceneView.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        sceneView.keepScreenOn = true
        channel.setMethodCallHandler(this)
    }

    private fun addAnchorNode(anchor: Anchor) {
        sceneView.addChildNode(
            AnchorNode(sceneView.engine, anchor).apply {
                isEditable = true
                mainScope.launch {
                    buildModelNode()?.let { addChildNode(it) }
                }
                anchorNode = this
            }
        )
    }

    private suspend fun buildModelNode(): ModelNode? {
        sceneView.modelLoader.loadModelInstance(
            "https://sceneview.github.io/assets/models/DamagedHelmet.glb"
        )?.let { modelInstance ->
            return ModelNode(
                modelInstance = modelInstance,
                scaleToUnits = 0.5f,
                centerOrigin = Position(y = -0.5f)
            ).apply {
                isEditable = true
            }
        }
        return null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                result.success(null)
            }
            "addNode" -> {
                Log.i(TAG, "addNode")
                // This method is no longer needed as we're automatically placing the model
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}