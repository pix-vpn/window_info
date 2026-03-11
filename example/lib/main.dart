import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_info/window_info.dart';
import 'package:flutter_screen_capture/flutter_screen_capture.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<String> _windowTitles = [];
  String? _selectedWindow;
  WindowRect? _windowRect;
  final _windowInfoPlugin = WindowInfo();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _windowInfoPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _loadWindowTitles() async {
    try {
      final titles = await _windowInfoPlugin.getWindowTitles();
      setState(() {
        _windowTitles = titles;
      });
    } catch (e) {
      debugPrint('Error loading window titles: $e');
    }
  }
  final _plugin = ScreenCapture();
  CapturedScreenArea? _fullScreenArea;
  Future<void> _getWindowRect() async {
    if (_selectedWindow == null) return;
    try {
      final rect = await _windowInfoPlugin.getWindowRect(_selectedWindow!);
      setState(() {
        _windowRect = rect;
      });
      Rect rect1 = Rect.fromLTWH(rect!.x.toDouble(), rect.y.toDouble(), rect.width.toDouble(), rect.height.toDouble());

      final area = await _plugin.captureScreenArea(rect1);
      setState(() {
        _fullScreenArea = area;
      });

    } catch (e) {
      debugPrint('Error getting window rect: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Window Info')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Platform: $_platformVersion'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadWindowTitles,
                child: const Text('Load Window Titles'),
              ),
              const SizedBox(height: 10),
              if (_windowTitles.isNotEmpty) ...[
                const Text('Select a window:'),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: _windowTitles.length,
                    itemBuilder: (context, index) {
                      final title = _windowTitles[index];
                      return ListTile(
                        title: Text(title, overflow: TextOverflow.ellipsis),
                        selected: _selectedWindow == title,
                        onTap: () {
                          setState(() {
                            _selectedWindow = title;
                            _windowRect = null;
                          });
                          _getWindowRect();
                        },
                      );
                    },
                  ),
                ),
              ],
              if (_windowRect != null) ...[
                const SizedBox(height: 20),
                const Text('Window Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Position: (${_windowRect!.x}, ${_windowRect!.y})'),
                Text('Size: ${_windowRect!.width} x ${_windowRect!.height}'),
                Text('Left: ${_windowRect!.left}, Top: ${_windowRect!.top}'),
                Text('Right: ${_windowRect!.right}, Bottom: ${_windowRect!.bottom}'),
                if (_fullScreenArea != null)
                  CapturedScreenAreaView(area: _fullScreenArea!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
