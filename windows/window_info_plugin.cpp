#include "window_info_plugin.h"

#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>
#include <vector>
#include <iostream>
#include <fstream>

namespace window_info {

namespace {

struct WindowData {
    std::vector<HWND> hwnds;
};

BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam) {
  WindowData* data = reinterpret_cast<WindowData*>(lParam);
  
  if (IsWindowVisible(hwnd)) {
    int length = GetWindowTextLengthW(hwnd);
    if (length > 0) {
      data->hwnds.push_back(hwnd);
    }
  }
  return TRUE;
}

std::string WStringToUTF8(const std::wstring& wstr) {
  if (wstr.empty()) return std::string();
  
  int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
  std::string strTo(size_needed, 0);
  WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
  return strTo;
}

BOOL GetWindowTitleW(HWND hwnd, std::string& title) {
  int length = GetWindowTextLengthW(hwnd);
  if (length > 0) {
    wchar_t* buffer = new wchar_t[length + 1];
    int result = GetWindowTextW(hwnd, buffer, length + 1);
    if (result > 0) {
      std::wstring wtitle(buffer);
      title = WStringToUTF8(wtitle);
    }
    delete[] buffer;
    return result > 0;
  }
  return FALSE;
}

HWND FindWindowByPartialTitle(const std::string& partialTitleUTF8) {
  WindowData data;
  EnumWindows(EnumWindowsProc, reinterpret_cast<LPARAM>(&data));
  
  std::wstring partialTitle;
  if (!partialTitleUTF8.empty()) {
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, &partialTitleUTF8[0], (int)partialTitleUTF8.size(), NULL, 0);
    partialTitle.resize(size_needed);
    MultiByteToWideChar(CP_UTF8, 0, &partialTitleUTF8[0], (int)partialTitleUTF8.size(), &partialTitle[0], size_needed);
  }
  
  for (size_t i = 0; i < data.hwnds.size(); i++) {
    HWND hwnd = data.hwnds[i];
    std::string title;
    if (GetWindowTitleW(hwnd, title)) {
      std::wstring wtitle;
      int size_needed = MultiByteToWideChar(CP_UTF8, 0, &title[0], (int)title.size(), NULL, 0);
      wtitle.resize(size_needed);
      MultiByteToWideChar(CP_UTF8, 0, &title[0], (int)title.size(), &wtitle[0], size_needed);
      
      if (wtitle.find(partialTitle) != std::wstring::npos) {
        return hwnd;
      }
    }
  }
  
  return NULL;
}

}

void WindowInfoPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "window_info",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<WindowInfoPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

WindowInfoPlugin::WindowInfoPlugin() {}

WindowInfoPlugin::~WindowInfoPlugin() {}

void WindowInfoPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    result->Success(flutter::EncodableValue(std::string("Windows")));
  } else if (method_call.method_name().compare("getWindowRect") == 0) {
    auto args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (args) {
      auto title_iter = args->find(flutter::EncodableValue("windowTitle"));
      if (title_iter != args->end()) {
        std::string title = std::get<std::string>(title_iter->second);
        
        HWND hwnd = FindWindowByPartialTitle(title);
        
        if (hwnd) {
          RECT rect;
          if (GetWindowRect(hwnd, &rect)) {
            flutter::EncodableMap rectMap;
            rectMap[flutter::EncodableValue("left")] = flutter::EncodableValue(static_cast<int>(rect.left));
            rectMap[flutter::EncodableValue("top")] = flutter::EncodableValue(static_cast<int>(rect.top));
            rectMap[flutter::EncodableValue("right")] = flutter::EncodableValue(static_cast<int>(rect.right));
            rectMap[flutter::EncodableValue("bottom")] = flutter::EncodableValue(static_cast<int>(rect.bottom));
            result->Success(flutter::EncodableValue(rectMap));
            return;
          }
        }
      }
    }
    result->Success(flutter::EncodableValue(nullptr));
  } else if (method_call.method_name().compare("getWindowTitles") == 0) {
    WindowData data;
    EnumWindows(EnumWindowsProc, reinterpret_cast<LPARAM>(&data));
    
    std::vector<flutter::EncodableValue> titleList;
    for (size_t i = 0; i < data.hwnds.size(); i++) {
      std::string title;
      if (GetWindowTitleW(data.hwnds[i], title)) {
        if (!title.empty()) {
          titleList.push_back(flutter::EncodableValue(title));
        }
      }
    }
    
    result->Success(flutter::EncodableValue(titleList));
  } else if (method_call.method_name().compare("setWindowPosition") == 0) {
    auto args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (args) {
      auto title_iter = args->find(flutter::EncodableValue("windowTitle"));
      auto x_iter = args->find(flutter::EncodableValue("x"));
      auto y_iter = args->find(flutter::EncodableValue("y"));
      
      if (title_iter != args->end() && x_iter != args->end() && y_iter != args->end()) {
        std::string title = std::get<std::string>(title_iter->second);
        int x = std::get<int>(x_iter->second);
        int y = std::get<int>(y_iter->second);
        
        HWND hwnd = FindWindowByPartialTitle(title);
        
        if (hwnd) {
          if (!IsWindow(hwnd)) {
            result->Success(flutter::EncodableValue(false));
            return;
          }
          
          if (!IsWindowVisible(hwnd)) {
            ShowWindow(hwnd, SW_SHOW);
          }
          
          SetForegroundWindow(hwnd);
          
          BOOL success = SetWindowPos(hwnd, HWND_TOP, x, y, 0, 0, SWP_NOSIZE | SWP_NOACTIVATE);
          
          result->Success(flutter::EncodableValue(success != 0));
          return;
        }
      }
    }
    result->Success(flutter::EncodableValue(false));
  } else if (method_call.method_name().compare("setWindowSize") == 0) {
    auto args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (args) {
      auto title_iter = args->find(flutter::EncodableValue("windowTitle"));
      auto width_iter = args->find(flutter::EncodableValue("width"));
      auto height_iter = args->find(flutter::EncodableValue("height"));
      
      if (title_iter != args->end() && width_iter != args->end() && height_iter != args->end()) {
        std::string title = std::get<std::string>(title_iter->second);
        int width = std::get<int>(width_iter->second);
        int height = std::get<int>(height_iter->second);
        
        HWND hwnd = FindWindowByPartialTitle(title);
        
        if (hwnd) {
          if (!IsWindow(hwnd)) {
            result->Success(flutter::EncodableValue(false));
            return;
          }
          
          if (!IsWindowVisible(hwnd)) {
            ShowWindow(hwnd, SW_SHOW);
          }
          
          SetForegroundWindow(hwnd);
          
          BOOL success = SetWindowPos(hwnd, HWND_TOP, 0, 0, width, height, SWP_NOMOVE | SWP_NOACTIVATE);
          
          result->Success(flutter::EncodableValue(success != 0));
          return;
        }
      }
    }
    result->Success(flutter::EncodableValue(false));
  } else {
    result->NotImplemented();
  }
}

}  // namespace window_info
