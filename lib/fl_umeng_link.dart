import 'package:fl_umeng/fl_umeng.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

export 'package:fl_umeng/fl_umeng.dart';

typedef FlUMLinkHandlerError = void Function(String? error);
typedef FlUMLinkHandlerLink = void Function(UMLinkResult? result);

class FlUMengLink {
  factory FlUMengLink() => _singleton ??= FlUMengLink._();

  FlUMengLink._();

  static FlUMengLink? _singleton;

  static const MethodChannel _channel = MethodChannel('UMeng.link');

  /// 安装后 获取的参数
  static Future<bool> getInstallParams({bool clipBoardEnabled = true}) async {
    final bool? state =
        await _channel.invokeMethod('getInstallParams', clipBoardEnabled);
    return state ?? false;
  }

  /// 监听回调参数
  static bool addMethodCallHandler({
    FlUMLinkHandlerError? onError,

    /// h5 直接启动app
    FlUMLinkHandlerLink? onLink,

    /// h5 引导安装app 后启动app
    FlUMLinkHandlerLink? onInstall,
  }) {
    final isInit = FlUMeng().isInit;
    if (isInit) {
      _channel.setMethodCallHandler(null);
      _channel.setMethodCallHandler((call) async {
        print(call.arguments);
        switch (call.method) {
          case 'onLink':
            onLink?.call(UMLinkResult.fromMap(call.arguments));
            break;
          case 'onInstall':
            onInstall?.call(UMLinkResult.fromMap(call.arguments));
            break;
          case 'onError':
            onError?.call(call.arguments);
            break;
        }
      });
    }
    return isInit;
  }
}

class UMLinkResult {
  UMLinkResult.fromMap(Map<dynamic, dynamic> map)
      : params = map['params'] as Map<dynamic, dynamic>?,
        path = map['path'] as String?,
        uri = map['uri'] as String?;

  Map<dynamic, dynamic>? params;
  String? path;
  String? uri;

  Map<String, dynamic> toMap() => {'path': path, 'uri': uri, 'params': params};
}

bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isIOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
