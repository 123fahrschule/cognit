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
    this.searchDebounce = this.options.debounce || 0;
    this.searchTimer = null;
    this.highlightedItem = null;

    if (this.input) {
      this.onInput = this.handleSearch.bind(this);
      this.input.addEventListener("input", this.onInput);
      this.applyFilter("");
    } else {
      this.updateGroupIndicators();
    }

    // Group select-all is multiple-only; hide the affordance otherwise.
    if (!this.multiple) {
      this.el
        .querySelectorAll('[data-part="group-trigger"]')
        .forEach((el) => el.setAttribute("hidden", ""));
    } else {
      // Open-state keydowns are routed to the search input, so wire Enter/Space
      // directly on the group triggers to keep them keyboard-operable.
      this.onGroupKeydown = (e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          this.toggleGroup(e);
        }
      };
      this.el
        .querySelectorAll('[data-part="group-trigger"]')
        .forEach((el) => el.addEventListener("keydown", this.onGroupKeydown));
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

    base.events.open.mouseMap = {
      ...base.events.open.mouseMap,
      "group-trigger": { click: (e) => this.toggleGroup(e) },
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
      // Preserve any prior query across close/open. Re-applying the current
      // value refreshes visibility/highlight/empty state; in server mode the
      // rendered items are already the server-filtered subset for this query.
      this.applyFilter(this.input.value.trim().toLowerCase());
      queueMicrotask(() => {
        this.input?.focus();
        const len = this.input.value.length;
        this.input.setSelectionRange?.(len, len);
      });
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

  selectValue(value) {
    super.selectValue(value);
    this.updateGroupIndicators();
  }

  // Remember each rendered item's label by value. In server-filter mode a
  // selected option drops out of the DOM once the query no longer matches it,
  // so the live collection can't resolve its label — fall back to this cache.
  cacheItemLabels() {
    this.labelCache ??= new Map();
    this.el.querySelectorAll('[data-part="item"]').forEach((el) => {
      const value = el.dataset.value;
      if (value == null) return;
      const text = el.querySelector('[data-part="item-text"]');
      if (text) this.labelCache.set(value, text.cloneNode(true));
    });
  }

  // Resolve a value's label node from the live collection, then the cache.
  labelFor(value) {
    const live = this.collection
      .getItemByValue(value)
      ?.instance.el.querySelector('[data-part="item-text"]');
    if (live) return live.cloneNode(true);
    const cached = (this.labelCache ??= new Map()).get(value);
    return cached ? cached.cloneNode(true) : null;
  }

  // Override the whole display so the single-item label survives the selected
  // option being filtered out of the rendered list (server-filter mode). The
  // multi-selection summary is translatable via the `selected-label` option.
  updateValueDisplay() {
    if (!this.valueDisplay) return;

    this.cacheItemLabels();

    const selectedValues = this.collection
      .getValue(true)
      .filter((v) => v !== "");

    const placeholder =
      this.valueDisplay.getAttribute("data-placeholder") || "Select an option";

    if (selectedValues.length === 0) {
      this.valueDisplay.replaceChildren(placeholder);
      return;
    }

    if (this.multiple && selectedValues.length > 1) {
      const template = this.options.selectedLabel || "%{count} items selected";
      this.valueDisplay.replaceChildren(
        template.replace("%{count}", selectedValues.length),
      );
      return;
    }

    this.valueDisplay.replaceChildren(
      this.labelFor(selectedValues[0]) || placeholder,
    );
  }

  // Collect the enabled, currently-visible items of a group.
  groupItems(group) {
    return Array.from(group.querySelectorAll('[data-part="item"]'))
      .filter((el) => this.isItemVisible(el))
      .map((el) => this.collection.getItemByValue(el.dataset.value))
      .filter((ci) => ci && !ci.instance.disabled);
  }

  toggleGroup(event) {
    if (!this.multiple) return;

    const group = event.currentTarget.closest('[data-part="group"]');
    if (!group) return;

    const items = this.groupItems(group);
    if (!items.length) return;

    // If every visible item is already selected, clear them; otherwise select
    // the remaining ones.
    const target = !items.every((ci) => ci.selected);
    items.forEach((ci) => {
      if (ci.selected !== target) this.collection.select(ci);
    });

    this.updateValueDisplay();
    this.syncHiddenInputs();
    this.updateGroupIndicators();
    this.pushEvent("value-changed", { value: this.collection.getValue() });
  }

  updateGroupIndicators() {
    if (!this.multiple) return;

    this.el
      .querySelectorAll('[data-part="group"][data-selectable]')
      .forEach((group) => {
        const trigger = group.querySelector('[data-part="group-trigger"]');
        if (!trigger) return;

        const items = this.groupItems(group);
        const selected = items.filter((ci) => ci.selected).length;

        let state = "unchecked";
        if (items.length && selected === items.length) state = "checked";
        else if (selected > 0) state = "indeterminate";

        // Use a private attribute: the framework's updateUI() overwrites
        // data-state on every part with the component's open/closed state.
        trigger
          .querySelector('[data-part="group-indicator"]')
          ?.setAttribute("data-group-state", state);
        trigger
          .querySelector('[data-part="group-check"]')
          ?.toggleAttribute("hidden", state !== "checked");
        trigger
          .querySelector('[data-part="group-minus"]')
          ?.toggleAttribute("hidden", state !== "indeterminate");
      });
  }

  handleSearch() {
    const query = this.input.value.trim().toLowerCase();
    if (this.serverFilter) {
      this.dispatchSearch(query);
    } else {
      this.applyFilter(query);
    }
  }

  // Debounce the server round-trip so we don't fire a search per keystroke.
  dispatchSearch(query) {
    if (this.searchTimer) clearTimeout(this.searchTimer);
    if (this.searchDebounce > 0) {
      this.searchTimer = setTimeout(() => {
        this.searchTimer = null;
        this.pushEvent("search", { query });
      }, this.searchDebounce);
    } else {
      this.pushEvent("search", { query });
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
      // In server mode the rendered items ARE the match set, so never hide them
      // client-side — doing so would filter the stale list against a newer query
      // (e.g. on each phx-change re-render) before the debounced server result.
      const visible = this.serverFilter || query === "" || text.includes(query);
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

    // Visible-item set changed → group select-all state may have changed too.
    this.updateGroupIndicators();
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
    if (this.searchTimer) clearTimeout(this.searchTimer);
    if (this.input && this.onInput) {
      this.input.removeEventListener("input", this.onInput);
    }
    if (this.onGroupKeydown) {
      this.el
        .querySelectorAll('[data-part="group-trigger"]')
        .forEach((el) => el.removeEventListener("keydown", this.onGroupKeydown));
    }
    this.clearHighlight();
    super.beforeDestroy();
  }
}

SaladUI.register("combobox", ComboboxComponent);

export default ComboboxComponent;
