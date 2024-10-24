//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <kline_library/kline_library_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) kline_library_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "KlineLibraryPlugin");
  kline_library_plugin_register_with_registrar(kline_library_registrar);
}
