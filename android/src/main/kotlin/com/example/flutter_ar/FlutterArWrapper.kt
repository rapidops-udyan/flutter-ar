@file:Suppress("UNREACHABLE_CODE")

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
import io.flutter.plugin.platform.PlatformView
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.ar.node.AnchorNode
import io.github.sceneview.math.Position
import io.github.sceneview.math.Rotation
import io.github.sceneview.math.Scale
import io.github.sceneview.node.ModelNode
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class FlutterArWrapper(
    context: Context,
    private val activity: Activity,
    lifecycle: Lifecycle,
    messenger: BinaryMessenger,
    id: Int,
) : PlatformView, MethodChannel.MethodCallHandler {
    private val TAG = "FlutterArWrapper"
    private val sceneView: ARSceneView
    private val mainScope = CoroutineScope(Dispatchers.Main)
    private val channel = MethodChannel(messenger, "scene_view_$id")

    private var anchorNode: AnchorNode? = null
    private var currentTrackingFailureReason: TrackingFailureReason? = null

    init {
        Log.i(TAG, "init")
        sceneView = ARSceneView(context, sharedLifecycle = lifecycle)
        setupSceneView()
        channel.setMethodCallHandler(this)
    }

    private fun setupSceneView() {
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
                config.focusMode = Config.FocusMode.AUTO
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
    }

    override fun getView(): View = sceneView

    override fun dispose() {
        Log.i(TAG, "dispose")
        sceneView.destroy()
    }

    private suspend fun loadModelInstance(path: String) = withContext(Dispatchers.IO) {
        sceneView.modelLoader.loadModelInstance(path)
    }

    private fun applyDefaultColor(node: ModelNode) {
        node.modelInstance.materialInstances.forEach { materialInstance ->
            materialInstance.setParameter(
                "baseColorFactor",
                com.google.android.filament.Colors.RgbaType.SRGB,
                1f, 1f, 1f, 1f  // White color with full opacity
            )
        }
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
        when (flutterNode) {
            is FlutterReferenceNode -> {
                mainScope.launch {
                    val path = getFileLocation(flutterNode.fileLocation)
                    val pose = getPoseInFrontOfCamera()
                    createAnchorNode(path, pose)?.let { newAnchorNode ->
                        anchorNode?.let { sceneView.removeChildNode(it) }
                        anchorNode = newAnchorNode
                        sceneView.addChildNode(newAnchorNode)
                    }
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> result.success(null)
            "addNode" -> {
                Log.i(TAG, "addNode")
                val flutterNode = FlutterSceneViewNode.from(call.arguments as Map<String, *>)
                loadModel(flutterNode)
                result.success(null)
            }

            "scaleModel" -> scaleModel(call, result)
            "moveModel" -> moveModel(call, result)
            "rotateModel" -> rotateModel(call, result)
            "rotateModelAroundAxis" -> rotateModelAroundAxis(call, result)
            "changeModelColor" -> changeModelColor(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getPoseInFrontOfCamera(): Pose {
        val camera = sceneView.cameraNode
        val forward = camera.forwardDirection
        val position = camera.position

        // Place the object 2 meters in front of the camera and 0.5 meters below
        val newPosition = position + forward * 2f - camera.upDirection * 0.5f

        return Pose.makeTranslation(newPosition.x, newPosition.y, newPosition.z)
    }

    private suspend fun createAnchorNode(path: String, pose: Pose): AnchorNode? {
        val modelInstance = loadModelInstance(path) ?: return null

        return withContext(Dispatchers.Main) {
            sceneView.session?.let { session ->
                val anchor = session.createAnchor(pose)

                AnchorNode(sceneView.engine, anchor).apply {
                    addChildNode(
                        ModelNode(
                            modelInstance = modelInstance,
                            scaleToUnits = 0.75f
                        ).apply {
                            isEditable = true
                            isTouchable = false
                            isPositionEditable = true
                            isRotationEditable = true
                            isScaleEditable = true
                            isSmoothTransformEnabled = true
                            smoothTransformSpeed = 0.5f
                            applyDefaultColor(this)
                        }
                    )
                }
            }
        }
    }

    private fun moveModel(call: MethodCall, result: MethodChannel.Result) {
        val x = call.argument<Double>("x")?.toFloat() ?: 0f
        val y = call.argument<Double>("y")?.toFloat() ?: 0f
        val z = call.argument<Double>("z")?.toFloat() ?: 0f

        (anchorNode?.childNodes?.firstOrNull() as? ModelNode)?.let { modelNode ->
            val camera = sceneView.cameraNode
            val up = camera.upDirection
            val forward = camera.forwardDirection
            val right = up.times(forward)

            val movement = (right * x) + (up * y) + (forward * -z)
            modelNode.position += Position(movement.x, movement.y, movement.z)
            result.success(null)
        } ?: result.error("MODEL_NOT_LOADED", "Model is not loaded", null)
    }

    private fun scaleModel(call: MethodCall, result: MethodChannel.Result) {
        val scaleFactor = call.argument<Double>("scale")?.toFloat() ?: 1.0f
        (anchorNode?.childNodes?.firstOrNull() as? ModelNode)?.let { modelNode ->
            val currentScale = modelNode.scale
            modelNode.scale = Scale(
                currentScale.x * scaleFactor,
                currentScale.y * scaleFactor,
                currentScale.z * scaleFactor
            )
            result.success(null)
        } ?: result.error("MODEL_NOT_LOADED", "Model is not loaded", null)
    }

    private fun rotateModel(call: MethodCall, result: MethodChannel.Result) {
        val x = call.argument<Double>("x")?.toFloat() ?: 0f
        val y = call.argument<Double>("y")?.toFloat() ?: 0f
        val z = call.argument<Double>("z")?.toFloat() ?: 0f
        anchorNode?.rotation = Rotation(x, y, z)
        result.success(null)
    }

    private fun rotateModelAroundAxis(call: MethodCall, result: MethodChannel.Result) {
        val angle = call.argument<Double>("angle")?.toFloat() ?: 0f
        anchorNode?.let { node ->
            val currentRotation = node.rotation
            val newRotation =
                Rotation(currentRotation.x, currentRotation.y + angle, currentRotation.z)
            node.rotation = newRotation
            result.success(null)
        } ?: result.error("MODEL_NOT_LOADED", "Model is not loaded", null)
    }

    private fun changeModelColor(call: MethodCall, result: MethodChannel.Result) {
        val color = call.argument<String>("color")
        color?.let {
            try {
                val colorInt = android.graphics.Color.parseColor(it)
                (anchorNode?.childNodes?.firstOrNull() as? ModelNode)?.modelInstance?.materialInstances?.forEach { materialInstance ->
                    materialInstance.setParameter(
                        "baseColorFactor",
                        com.google.android.filament.Colors.RgbaType.SRGB,
                        android.graphics.Color.red(colorInt) / 255f,
                        android.graphics.Color.green(colorInt) / 255f,
                        android.graphics.Color.blue(colorInt) / 255f,
                        1f  // Full opacity
                    )
                }
                result.success(true)
            } catch (e: Exception) {
                result.error("COLOR_CHANGE_ERROR", "Error changing color: ${e.message}", null)
            }
        } ?: result.error("INVALID_COLOR", "Invalid color value", null)
    }
}