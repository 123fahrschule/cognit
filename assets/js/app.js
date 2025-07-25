import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";import SaladUI from "./ui/index.js";
import "./ui/components/dialog.js";
import "./ui/components/select.js";
import "./ui/components/tabs.js";
import "./ui/components/radio_group.js";
import "./ui/components/popover.js";
import "./ui/components/hover-card.js";
import "./ui/components/collapsible.js";
import "./ui/components/tooltip.js";
import "./ui/components/accordion.js";
import "./ui/components/slider.js";
import "./ui/components/switch.js";
import "./ui/components/dropdown_menu.js";


let liveSocket = new LiveSocket("/live", Socket, {  hooks: { SaladUI: SaladUI.SaladUIHook }});
