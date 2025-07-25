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

/* Hooks */
import { SaladUIHook } from "./js/ui/core/hook";

import { FlashMessage } from "./js/hooks/flash_message.js";
import { LocaleSelect } from "./js/hooks/locale_select.js";

export const Hooks = {
  FlashMessage,
  LocaleSelect,

  SaladUI: SaladUIHook,
};

export default {
  Hooks,
};
