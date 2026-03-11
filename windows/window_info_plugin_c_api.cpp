#include "include/window_info/window_info_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "window_info_plugin.h"

void WindowInfoPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  window_info::WindowInfoPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
