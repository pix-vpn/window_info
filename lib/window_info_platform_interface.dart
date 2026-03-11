import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'window_info_method_channel.dart';

abstract class WindowInfoPlatform extends PlatformInterface {
  WindowInfoPlatform() : super(token: _token);

  static final Object _token = Object();

  static WindowInfoPlatform _instance = MethodChannelWindowInfo();

  static WindowInfoPlatform get instance => _instance;

  static set instance(WindowInfoPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<WindowRect?> getWindowRect(String windowTitle) {
    throw UnimplementedError('getWindowRect() has not been implemented.');
  }

  Future<List<String>> getWindowTitles() {
    throw UnimplementedError('getWindowTitles() has not been implemented.');
  }

  Future<bool> setWindowPosition(String windowTitle, int x, int y) {
    throw UnimplementedError('setWindowPosition() has not been implemented.');
  }

  Future<bool> setWindowSize(String windowTitle, int width, int height) {
    throw UnimplementedError('setWindowSize() has not been implemented.');
  }
}

class WindowRect {
  final int left;
  final int top;
  final int right;
  final int bottom;

  WindowRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  int get width => right - left;
  int get height => bottom - top;
  int get x => left;
  int get y => top;

  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
    };
  }

  factory WindowRect.fromMap(Map<dynamic, dynamic> map) {
    return WindowRect(
      left: map['left'] as int,
      top: map['top'] as int,
      right: map['right'] as int,
      bottom: map['bottom'] as int,
    );
  }
}
