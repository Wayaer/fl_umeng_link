package fl.umeng.link.example

import android.content.Intent
import fl.umeng.link.UMengLinkPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        UMengLinkPlugin.handleUMLinkURI(this, intent)
    }
}
