import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let liveSocket = new LiveSocket("/live", Socket, {});
