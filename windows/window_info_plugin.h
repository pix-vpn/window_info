#ifndef FLUTTER_PLUGIN_WINDOW_INFO_PLUGIN_H_
#define FLUTTER_PLUGIN_WINDOW_INFO_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace window_info {

class WindowInfoPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WindowInfoPlugin();

  virtual ~WindowInfoPlugin();

  // Disallow copy and assign.
  WindowInfoPlugin(const WindowInfoPlugin&) = delete;
  WindowInfoPlugin& operator=(const WindowInfoPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace window_info

#endif  // FLUTTER_PLUGIN_WINDOW_INFO_PLUGIN_H_
