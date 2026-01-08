/* Open Sans font */
import "./css/open_sans.css";

/* Material Symbols icons */
import "./css/material_symbols.css";

/* SaladUI components */
import "./js/ui/components/dialog.js";
import "./js/ui/components/select.js";
import "./js/ui/components/tabs.js";
import "./js/ui/components/radio_group.js";
import "./js/ui/components/popover.js";
import "./js/ui/components/hover-card.js";
import "./js/ui/components/collapsible.js";
import "./js/ui/components/tooltip.js";
import "./js/ui/components/accordion.js";
import "./js/ui/components/slider.js";
import "./js/ui/components/switch.js";
import "./js/ui/components/dropdown_menu.js";

import "./js/copy_button.js";
import "./js/live_reload_listeners.js";

/* Hooks */
import { SaladUIHook } from "./js/ui/core/hook";

import { FlashMessage } from "./js/hooks/flash_message.js";
import { LocaleSelect } from "./js/hooks/locale_select.js";
import { Sidebar } from "./js/hooks/sidebar.js";
import { SidebarMenu } from "./js/hooks/sidebar_menu.js";
import { getCognitParams } from "./js/connect_params.js";

export const Hooks = {
  FlashMessage,
  LocaleSelect,
  Sidebar,
  SidebarMenu,

  SaladUI: SaladUIHook,
};

export default {
  Hooks,
  getCognitParams,
};
