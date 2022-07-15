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
    private var path: String? = null
    private var uri: String? = null
    private var linkParams: HashMap<String, String>? = null
    private var installParams: HashMap<String, String>? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "UMeng.link")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getLaunchParams" -> {
                result.success(
                    mapOf(
                        "path" to path,
                        "linkParams" to linkParams,
                        "uri" to uri,
                        "installParams" to installParams
                    )
                )
            }
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
        if (intent != null) MobclickLink.handleUMLinkURI(context, intent.data, umLinkAdapter);
        return true
    }

    private var umLinkAdapter: UMLinkListener = object : UMLinkListener {
        override fun onLink(path: String, params: HashMap<String, String>) {
            this@UMengLinkPlugin.path = path
            this@UMengLinkPlugin.linkParams = params
        }

        override fun onInstall(params: HashMap<String, String>, uri: Uri) {
            this@UMengLinkPlugin.uri = uri.path
            this@UMengLinkPlugin.installParams = params
            channel.invokeMethod(
                "onInstall", mapOf(
                    "uri" to uri.path, "installParams" to params
                )
            )
        }

        override fun onError(error: String) {
            channel.invokeMethod("onError", error)
        }
    }
}
