import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_info/window_info_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelWindowInfo platform = MethodChannelWindowInfo();
  const MethodChannel channel = MethodChannel('window_info');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
