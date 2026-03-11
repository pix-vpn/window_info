import 'package:flutter_test/flutter_test.dart';
import 'package:window_info/window_info.dart';
import 'package:window_info/window_info_platform_interface.dart';
import 'package:window_info/window_info_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWindowInfoPlatform
    with MockPlatformInterfaceMixin
    implements WindowInfoPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<WindowRect?> getWindowRect(String windowTitle) async {
    return WindowRect(left: 0, top: 0, right: 800, bottom: 600);
  }

  @override
  Future<List<String>> getWindowTitles() async {
    return ['Test Window'];
  }

  @override
  Future<bool> setWindowPosition(String windowTitle, int x, int y) async {
    return true;
  }

  @override
  Future<bool> setWindowSize(String windowTitle, int width, int height) async {
    return true;
  }
}

void main() {
  final WindowInfoPlatform initialPlatform = WindowInfoPlatform.instance;

  test('$MethodChannelWindowInfo is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWindowInfo>());
  });

  test('getPlatformVersion', () async {
    WindowInfo windowInfoPlugin = WindowInfo();
    MockWindowInfoPlatform fakePlatform = MockWindowInfoPlatform();
    WindowInfoPlatform.instance = fakePlatform;

    expect(await windowInfoPlugin.getPlatformVersion(), '42');
  });

  test('getWindowRect returns window rect', () async {
    WindowInfo windowInfoPlugin = WindowInfo();
    MockWindowInfoPlatform fakePlatform = MockWindowInfoPlatform();
    WindowInfoPlatform.instance = fakePlatform;

    final rect = await windowInfoPlugin.getWindowRect('Test');
    expect(rect?.width, 800);
    expect(rect?.height, 600);
  });
}
