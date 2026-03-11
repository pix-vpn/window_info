import 'window_info_platform_interface.dart';

export 'window_info_platform_interface.dart' show WindowRect;

class WindowInfo {
  Future<String?> getPlatformVersion() {
    return WindowInfoPlatform.instance.getPlatformVersion();
  }

  Future<WindowRect?> getWindowRect(String windowTitle) {
    return WindowInfoPlatform.instance.getWindowRect(windowTitle);
  }

  Future<List<String>> getWindowTitles() {
    return WindowInfoPlatform.instance.getWindowTitles();
  }

  Future<bool> setWindowPosition(String windowTitle, int x, int y) {
    return WindowInfoPlatform.instance.setWindowPosition(windowTitle, x, y);
  }

  Future<bool> setWindowSize(String windowTitle, int width, int height) {
    return WindowInfoPlatform.instance.setWindowSize(windowTitle, width, height);
  }
}
