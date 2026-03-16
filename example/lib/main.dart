import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_info/window_info.dart';

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

  final _xController = TextEditingController();
  final _yController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
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

  Future<void> _getWindowRect() async {
    if (_selectedWindow == null) return;

    try {
      final rect = await _windowInfoPlugin.getWindowRect(_selectedWindow!);
      setState(() {
        _windowRect = rect;
        if (rect != null) {
          _xController.text = rect.x.toString();
          _yController.text = rect.y.toString();
          _widthController.text = rect.width.toString();
          _heightController.text = rect.height.toString();
        }
      });
    } catch (e) {
      debugPrint('Error getting window rect: $e');
    }
  }

  Future<void> _setWindowPosition() async {
    if (_selectedWindow == null) return;

    final x = int.tryParse(_xController.text);
    final y = int.tryParse(_yController.text);

    if (x == null || y == null) {
      _showMessage('请输入有效的坐标值');
      return;
    }

    try {
      final success = await _windowInfoPlugin.setWindowPosition(_selectedWindow!, x, y);
      if (success) {
        _showMessage('位置已设置');
        _getWindowRect();
      } else {
        _showMessage('设置位置失败');
      }
    } catch (e) {
      debugPrint('Error setting window position: $e');
    }
  }

  Future<void> _setWindowSize() async {
    if (_selectedWindow == null) return;

    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);

    if (width == null || height == null) {
      _showMessage('请输入有效的尺寸值');
      return;
    }

    try {
      final success = await _windowInfoPlugin.setWindowSize(_selectedWindow!, width, height);
      if (success) {
        _showMessage('尺寸已设置');
        _getWindowRect();
      } else {
        _showMessage('设置尺寸失败');
      }
    } catch (e) {
      debugPrint('Error setting window size: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Window Info')),
        body: SingleChildScrollView(
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
                  height: 120,
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
                const SizedBox(height: 20),
                const Divider(),
                const Text('调整位置:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _xController,
                        decoration: const InputDecoration(
                          labelText: 'X',
                          border: OutlineInputBorder(),
                          hintText: 'X坐标',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _yController,
                        decoration: const InputDecoration(
                          labelText: 'Y',
                          border: OutlineInputBorder(),
                          hintText: 'Y坐标',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _setWindowPosition,
                      child: const Text('移动'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('调整大小:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _widthController,
                        decoration: const InputDecoration(
                          labelText: 'Width',
                          border: OutlineInputBorder(),
                          hintText: '宽度',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          border: OutlineInputBorder(),
                          hintText: '高度',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _setWindowSize,
                      child: const Text('调整大小'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
