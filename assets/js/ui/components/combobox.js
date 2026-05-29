// saladui/components/combobox.js
import SelectComponent from "./select";
import SaladUI from "..";

/**
 * ComboboxComponent — a searchable select.
 *
 * Extends SelectComponent to reuse collection management, positioning,
 * hidden-input form sync, and multi-selection handling. Adds:
 *   - a search input inside the content panel
 *   - substring filtering of rendered items (client or server mode)
 *   - highlight-without-focus navigation so the input keeps keyboard focus
 */
class ComboboxComponent extends SelectComponent {
  constructor(el, hookContext) {
    super(el, hookContext);

    this.input = this.getPart("input");
    this.empty = this.getPart("empty");
    this.serverFilter = this.options.filter === "server";
    this.highlightedItem = null;

    if (this.input) {
      this.onInput = this.handleSearch.bind(this);
      this.input.addEventListener("input", this.onInput);
      this.applyFilter("");
    }
  }

  getComponentConfig() {
    const base = super.getComponentConfig();

    // Route open-state key events to the search input so it retains focus
    // while the user navigates with arrow keys.
    base.events.open.keyEventTarget = "input";
    base.events.open.keyMap = {
      Escape: "close",
      ArrowUp: () => this.navigateItem("prev"),
      ArrowDown: () => this.navigateItem("next"),
      Home: () => this.navigateItem("first"),
      End: () => this.navigateItem("last"),
      Enter: (e) => {
        e.preventDefault();
        // Stop the keydown from bubbling to the content element, whose
        // closed-state handler would otherwise re-fire Enter→open and reopen
        // the menu right after selectHighlighted() transitions it closed.
        e.stopPropagation();
        this.selectHighlighted();
      },
    };

    return base;
  }

  // Override Select's onOpenEnter: we do NOT want its highlightFirstSelectedOrFirstItem
  // because that calls collection.focus() which moves DOM focus to the item,
  // away from the search input.
  onOpenEnter() {
    this.initializePositionedElement();

    if (this.positionedElement) {
      this.positionedElement.activate();
    }

    if (this.input) {
      this.input.value = "";
      this.applyFilter("");
      queueMicrotask(() => this.input?.focus());
    } else {
      this.highlightFirstSelectedOrVisible();
    }

    this.pushEvent("opened");
  }

  onClosedEnter() {
    this.clearHighlight();
    super.onClosedEnter();
  }

  isItemVisible(el) {
    return el.getAttribute("data-visible") !== "false";
  }

  // Override: navigate visible (non-hidden, non-disabled) items only,
  // and highlight without moving DOM focus.
  navigateItem(direction) {
    const visible = this.collection.items.filter(
      (ci) => this.isItemVisible(ci.instance.el) && !ci.instance.disabled,
    );
    if (!visible.length) return;

    const current = this.highlightedItem;
    let idx = current ? visible.indexOf(current) : -1;

    switch (direction) {
      case "first":
        idx = 0;
        break;
      case "last":
        idx = visible.length - 1;
        break;
      case "next":
        idx = idx < 0 ? 0 : (idx + 1) % visible.length;
        break;
      case "prev":
      case "previous":
        idx =
          idx < 0
            ? visible.length - 1
            : (idx - 1 + visible.length) % visible.length;
        break;
      default:
        return;
    }

    this.highlightItem(visible[idx]);
  }

  highlightFirstSelectedOrVisible() {
    const selected = this.collection.items.find(
      (ci) => ci.selected && this.isItemVisible(ci.instance.el),
    );
    if (selected) {
      this.highlightItem(selected);
      return;
    }
    this.navigateItem("first");
  }

  highlightItem(collectionItem) {
    this.clearHighlight();
    this.highlightedItem = collectionItem;
    if (collectionItem) {
      collectionItem.instance.el.setAttribute("data-highlighted", "true");
      collectionItem.instance.el.scrollIntoView({ block: "nearest" });
    }
  }

  clearHighlight() {
    if (this.highlightedItem) {
      this.highlightedItem.instance.el.removeAttribute("data-highlighted");
    }
    this.highlightedItem = null;
  }

  // Called by SelectItem on mouseenter — override to highlight instead of DOM-focus.
  handleItemFocus(item) {
    const ci = this.collection.getItemByInstance(item);
    if (ci) this.highlightItem(ci);
  }

  selectHighlighted() {
    if (this.highlightedItem) {
      this.selectValue(this.highlightedItem.instance.value);
    }
  }

  handleSearch() {
    const query = this.input.value.trim().toLowerCase();
    if (this.serverFilter) {
      this.pushEvent("search", { query });
    } else {
      this.applyFilter(query);
    }
  }

  applyFilter(query) {
    const items = Array.from(
      this.el.querySelectorAll('[data-part="item"]'),
    );
    let visibleCount = 0;

    items.forEach((el) => {
      const textEl = el.querySelector('[data-part="item-text"]') || el;
      const text = textEl.textContent.trim().toLowerCase();
      const visible = query === "" || text.includes(query);
      el.setAttribute("data-visible", visible ? "true" : "false");
      if (visible) visibleCount++;
    });

    // Hide groups whose items are all filtered out.
    this.el.querySelectorAll('[data-part="group"]').forEach((group) => {
      const anyVisible = group.querySelector(
        '[data-part="item"][data-visible="true"]',
      );
      group.setAttribute("data-visible", anyVisible ? "true" : "false");
    });

    if (this.empty) {
      this.empty.setAttribute(
        "data-visible",
        visibleCount === 0 ? "true" : "false",
      );
    }

    // Re-highlight if the current highlight is missing, stale, or hidden —
    // but only while the dropdown is open. When closed, any lingering
    // highlight attributes would remain visible on next open.
    const el = this.highlightedItem?.instance?.el;
    if (!el || !el.isConnected || !this.isItemVisible(el)) {
      this.clearHighlight();
      if (this.state === "open") {
        this.navigateItem("first");
      }
    }
  }

  onDomUpdate() {
    // super.onDomUpdate() rebuilds the item collection via reinitializeItems(),
    // which destroys the old item instances. Drop the stale wrapper reference
    // but remember the highlighted value so we can restore it on the new
    // collection without a visible blank frame.
    const prevHighlightedValue =
      this.highlightedItem?.instance?.value ?? null;
    this.highlightedItem = null;

    super.onDomUpdate();

    if (this.input) {
      this.applyFilter(this.input.value.trim().toLowerCase());
    }

    // If the dropdown is closed, strip any lingering highlight attributes so
    // they don't show on next open. When open, restore the prior highlight
    // (or leave whatever applyFilter chose as the first visible item).
    if (this.state !== "open") {
      this.el
        .querySelectorAll('[data-part="item"][data-highlighted]')
        .forEach((el) => el.removeAttribute("data-highlighted"));
      this.highlightedItem = null;
    } else if (prevHighlightedValue !== null) {
      const restored = this.collection.getItemByValue(prevHighlightedValue);
      if (
        restored &&
        this.isItemVisible(restored.instance.el) &&
        !restored.instance.disabled &&
        restored !== this.highlightedItem
      ) {
        this.highlightItem(restored);
      }
    }
  }

  beforeDestroy() {
    if (this.input && this.onInput) {
      this.input.removeEventListener("input", this.onInput);
    }
    this.clearHighlight();
    super.beforeDestroy();
  }
}

SaladUI.register("combobox", ComboboxComponent);

export default ComboboxComponent;
