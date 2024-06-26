package com.example.flutter_ar

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.lifecycle.Lifecycle
import com.google.ar.core.Config
import com.google.ar.core.Pose
import com.google.ar.core.TrackingFailureReason
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.ar.node.AnchorNode
import io.github.sceneview.math.Position
import io.github.sceneview.math.Scale
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
    private val TAG = "FlutterArWrapper"
    private val sceneView: ARSceneView
    private val mainScope = CoroutineScope(Dispatchers.Main)
    private val channel = MethodChannel(messenger, "scene_view_$id")

    private var anchorNode: AnchorNode? = null
    private var currentTrackingFailureReason: TrackingFailureReason? = null

    init {
        Log.i(TAG, "init")
        sceneView = ARSceneView(context, sharedLifecycle = lifecycle)
        sceneView.apply {
            planeRenderer.isEnabled = true
            configureSession { session, config ->
                config.lightEstimationMode = Config.LightEstimationMode.ENVIRONMENTAL_HDR
                config.planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL
                config.depthMode = when (session.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) {
                    true -> Config.DepthMode.AUTOMATIC
                    else -> Config.DepthMode.DISABLED
                }
                config.instantPlacementMode = Config.InstantPlacementMode.DISABLED
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

    override fun getView(): View {
        return sceneView
    }

    override fun dispose() {
        Log.i(TAG, "dispose")
    }


    private fun addAnchorNode(path: String) {
        anchorNode?.let { sceneView.removeChildNode(it) }
        anchorNode = null
        sceneView.session?.let { session ->
            session.createAnchor(session.frame?.androidSensorPose ?: Pose.IDENTITY).let { anchor ->
                sceneView.addChildNode(
                    AnchorNode(sceneView.engine, anchor).apply {
                        isEditable = true
                        mainScope.launch {
                            Log.i(TAG, "Building Model Node...")
                            buildModelNode(path)?.let { addChildNode(it) }
                        }
                        anchorNode = this
                    }
                )
            }
        }
    }

    private suspend fun buildModelNode(path: String): ModelNode? {
        sceneView.modelLoader.loadModelInstance(path)?.let { modelInstance ->
            return ModelNode(
                modelInstance = modelInstance,
                centerOrigin = Position(z = -0.5f)
            ).apply {
                isEditable = true
                isTouchable = false
                isSmoothTransformEnabled = true
                isVisible = true
                smoothTransformSpeed = 0.1f
            }
        }
        return null
    }

    private fun getFileLocation(fileLocation: String): String {
        return if (fileLocation.startsWith("http://") || fileLocation.startsWith("https://")) {
            fileLocation // It's already a URL, return as is
        } else {
            Utils.getFlutterAssetKey(
                activity,
                fileLocation
            ) // It's a Flutter asset, get the correct path
        }
    }

    private fun loadModel(flutterNode: FlutterSceneViewNode) {
        sceneView.session?.let { session ->
            when (flutterNode) {
                is FlutterReferenceNode -> {
                    addAnchorNode(getFileLocation(flutterNode.fileLocation))
                }

            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                result.success(null)
            }

            "addNode" -> {
                Log.i(TAG, "addNode")
                var flutterNode = FlutterSceneViewNode.from(call.arguments as Map<String, *>)
                mainScope.launch {
                    loadModel(flutterNode)
                }
                result.success(null)
            }

            "zoom" -> {
                val scale = call.argument<Double>("scale")
                anchorNode?.scale = Scale(scale?.toFloat() ?: 1.0f)
                result.success(null)
            }

            "rotate" -> {
                val (x, y, z) = call.argument<List<Double>>("rotation") ?: listOf(0.0, 0.0, 0.0)
                anchorNode?.transform(Position(x.toFloat(), y.toFloat(), z.toFloat()))
                result.success(null)
            }

            "move" -> {
                val (x, y, z) = call.argument<List<Double>>("position") ?: listOf(0.0, 0.0, 0.0)
                anchorNode?.position = Position(x.toFloat(), y.toFloat(), z.toFloat())
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }
}