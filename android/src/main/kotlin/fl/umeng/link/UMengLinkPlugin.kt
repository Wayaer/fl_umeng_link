package fl.umeng.link


import android.content.Context
import android.content.Intent
import android.net.Uri
import com.umeng.umlink.MobclickLink
import com.umeng.umlink.UMLinkListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.NewIntentListener

/** UMengLinkPlugin */
class UMengLinkPlugin : FlutterPlugin, MethodCallHandler, NewIntentListener {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "UMeng.link")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getInstallParams" -> {
                val clipBoardEnabled = call.arguments as Boolean
                if (!clipBoardEnabled) {
                    MobclickLink.getInstallParams(context, umLinkAdapter)
                } else {
                    MobclickLink.getInstallParams(context, false, umLinkAdapter)
                }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    override fun onNewIntent(intent: Intent?): Boolean {
        if (intent != null) MobclickLink.handleUMLinkURI(context, intent.data, umLinkAdapter)
        return true
    }

    private var umLinkAdapter: UMLinkListener = object : UMLinkListener {
        override fun onLink(path: String, params: HashMap<String, String>) {
            channel.invokeMethod(
                "onLink", mapOf(
                    "path" to path, "params" to params
                )
            )
        }

        override fun onInstall(params: HashMap<String, String>, uri: Uri) {
            channel.invokeMethod(
                "onInstall", mapOf(
                    "uri" to uri.path, "params" to params
                )
            )
        }

        override fun onError(error: String) {
            channel.invokeMethod("onError", error)
        }
    }
}
