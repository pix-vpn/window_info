import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'window_info_platform_interface.dart';

class MethodChannelWindowInfo extends WindowInfoPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('window_info');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<WindowRect?> getWindowRect(String windowTitle) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getWindowRect',
      {'windowTitle': windowTitle},
    );
    if (result != null) {
      return WindowRect.fromMap(result);
    }
    return null;
  }

  @override
  Future<List<String>> getWindowTitles() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'getWindowTitles',
    );
    if (result != null) {
      return result.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  Future<bool> setWindowPosition(String windowTitle, int x, int y) async {
    final result = await methodChannel.invokeMethod<bool>(
      'setWindowPosition',
      {'windowTitle': windowTitle, 'x': x, 'y': y},
    );
    return result ?? false;
  }

  @override
  Future<bool> setWindowSize(String windowTitle, int width, int height) async {
    final result = await methodChannel.invokeMethod<bool>(
      'setWindowSize',
      {'windowTitle': windowTitle, 'width': width, 'height': height},
    );
    return result ?? false;
  }
}
