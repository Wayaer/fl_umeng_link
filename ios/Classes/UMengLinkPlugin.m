#import "UMengLinkPlugin.h"
#import <UMLink/UMLink.h>

@interface UMengLinkPlugin () <MobClickLinkDelegate>
@end

@implementation UMengLinkPlugin

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:@"UMeng.link"
                                     binaryMessenger:registrar.messenger];
    UMengLinkPlugin *instance = [[UMengLinkPlugin alloc] init];
    instance.channel = channel;
    
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
    self = [super init];
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"getInstallParams" isEqualToString:call.method]) {
        BOOL clipBoardEnabled = [call.arguments boolValue];
        if (clipBoardEnabled) {
            [MobClickLink getInstallParams:^(NSDictionary *params, NSURL *URL, NSError *error) {
                [self invokeMethodInstall:params :URL :error];
            }];
        } else {
            [MobClickLink getInstallParams:^(NSDictionary *params, NSURL *URL, NSError *error) {
                [self invokeMethodInstall:params :URL :error];
            }
                          enablePasteboard:NO];
        }
        result(@(YES));
    } else {
        result(FlutterMethodNotImplemented);
    }
}



//Universal link的回调
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nonnull))restorationHandler{
    [MobClickLink handleUniversalLink:userActivity delegate:self];
    return YES;
}

//URL Scheme回调，iOS9以上，走这个方法
- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [MobClickLink handleLinkURL:url delegate:self];
    return YES;
}

- (void)getLinkPath:(NSString *)path params:(NSDictionary *)params {
    [self.channel invokeMethod:@"onLink" arguments:@{
        @"params": params,
        @"path": path,
    }];
}

- (void)invokeMethodInstall:(NSDictionary *)params :(NSURL *)url :(NSError *)error {
    if (error) {
        [self.channel invokeMethod:@"onError" arguments:error.description];
    } else {
        [self.channel invokeMethod:@"onInstall" arguments:@{
            @"params": params,
            @"uri": url.absoluteString,
        }];
    }
}
@end
