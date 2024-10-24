#include "include/kline_library/kline_library_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "kline_library_plugin.h"

void KlineLibraryPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  kline_library::KlineLibraryPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
