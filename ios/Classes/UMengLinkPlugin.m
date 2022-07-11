#import "UMengLinkPlugin.h"

@implementation UMengLinkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
 FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"UMeng.link"
                  binaryMessenger:registrar.messenger];

    [channel setMethodCallHandler:^(FlutterMethodCall *_Nonnull call, FlutterResult _Nonnull result) {
        if ([@"init" isEqualToString:call.method]) {

        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}
@end
