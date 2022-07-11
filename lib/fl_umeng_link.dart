import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

export 'package:fl_umeng/fl_umeng.dart';

class FlUMengLink {
  factory FlUMengLink() => _singleton ??= FlUMengLink._();

  FlUMengLink._();

  static FlUMengLink? _singleton;

  final MethodChannel _channel = const MethodChannel('UMeng.link');
}

bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isIOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
