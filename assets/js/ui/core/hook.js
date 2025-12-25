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
      // Save state from OLD component before destroying
      const currentState = this.component.state;
      const focusedValue = this.component.collection?.focusedItem?.value;
      const shouldPreserve = this.component.shouldPreserveStateOnUpdate();

      this.component.destroy();
      this.component = null;
      this.initComponent();
      //   this.component.parseOptions();
      //   this.component.setupEvents();
      //   this.component.updatePartsVisibility();
      //   this.component.updateUI();

      // Restore state on NEW component (if opted in and component was recreated)
      if (shouldPreserve && currentState === 'open' && this.component) {
        this.component.transition('open');

        // Restore focused item for components with collections (like select)
        if (focusedValue && this.component.collection) {
          const item = this.component.collection.getItemByValue(focusedValue);
          if (item) {
            this.component.collection.focus(item);
          }
        }
      }
    }
  },

  destroyed() {
    this.component?.destroy();
    this.component = null;
  },
};

export { SaladUIHook };
