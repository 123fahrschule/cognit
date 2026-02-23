// saladui/core/hook.js
import { registry } from "./factory";

const SaladUIHook = {
  mounted() {
    this.initComponent();
    this.setupServerEvents();
  },

  initComponent() {
    const el = this.el;
    const componentType = el.getAttribute("data-component");

    if (!componentType) {
      console.error(
        "SaladUI: Component element is missing data-component attribute",
      );
      return;
    }

    // The registry.create method will handle creating the component and calling setupEvents
    this.component = registry.create(componentType, el, this);
  },

  setupServerEvents() {
    if (!this.component) return;

    this.handleEvent("saladui:command", ({ command, params = {}, target }) => {
      if (target && target !== this.el.id) return;

      if (this.component) {
        this.component.handleCommand(command, params);
      }
    });
  },

  updated() {
    if (this.component) {
      // When morphdom replaces child elements (e.g., after LiveView stream reset
      // with matching DOM IDs), cached part references become stale. Detect this
      // by checking if any parts are disconnected, and fully reinitialize.
      // The root's data-state (preserved by JS.ignore_attributes) ensures correct
      // state restoration.
      const partsStale = this.component.allParts.some((p) => !p.isConnected);
      if (partsStale) {
        this.component.destroy();
        this.component = null;
        this.initComponent();
        this.component?.onDomUpdate();
      } else {
        this.component.onDomUpdate();
      }
    }
  },

  destroyed() {
    this.component?.destroy();
    this.component = null;
  },
};

export { SaladUIHook };
