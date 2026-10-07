// saladui/components/date_picker.js
import SaladUI from "../index";
import PositionedElement from "../core/positioned-element";
import CalendarComponent, { formatDisplayDate, today } from "./calendar";

/**
 * DatePickerComponent: an input-styled trigger that opens the calendar in a
 * popover. Value handling, rendering, and keyboard navigation come from
 * CalendarComponent; this class adds the open/closed state, positioning, the
 * trigger's value display, and closing once a date or a full range is picked.
 */
class DatePickerComponent extends CalendarComponent {
  initParts() {
    super.initParts();
    this.trigger = this.getPart("trigger");
    this.valueDisplay = this.getPart("value");
    this.content = this.getPart("content");
    this.restoreFocusOnClose = true;
  }

  getComponentConfig() {
    return {
      stateMachine: {
        closed: {
          enter: "onClosedEnter",
          transitions: {
            open: "open",
            toggle: "open",
          },
        },
        open: {
          enter: "onOpenEnter",
          exit: "onOpenExit",
          transitions: {
            close: "closed",
            toggle: "closed",
            select: "closed",
          },
        },
      },
      hiddenConfig: {
        closed: {
          content: true,
        },
        open: {
          content: false,
        },
      },
      ariaConfig: {
        trigger: {
          all: {
            haspopup: "dialog",
          },
          open: {
            expanded: "true",
          },
          closed: {
            expanded: "false",
          },
        },
      },
    };
  }

  // Key handling covers the whole popover, including content rendered below
  // the calendar, so Escape closes it from anywhere inside.
  getKeydownTarget() {
    return this.content;
  }

  transition(event, params = {}) {
    if (this.trigger?.disabled && this.state === "closed") return false;
    return super.transition(event, params);
  }

  // Value

  syncValue({ notify }) {
    super.syncValue({ notify });

    if (this.valueDisplay) {
      this.valueDisplay.textContent =
        this.formatValue() ||
        this.valueDisplay.getAttribute("data-placeholder") ||
        "";
    }

    // Activates the trigger's data-[placeholder]:text-muted-foreground styling
    this.trigger?.toggleAttribute("data-placeholder", !this.from);
  }

  formatValue() {
    if (!this.from) return "";
    if (!this.isRange) return formatDisplayDate(this.from);
    return `${formatDisplayDate(this.from)} – ${this.to ? formatDisplayDate(this.to) : ""}`.trim();
  }

  // While a range is being picked, the grid shows the half-picked range, but
  // the value only changes once the end is picked.
  getSelection() {
    return this.draft || super.getSelection();
  }

  selectDate(date) {
    if (!date || this.isDateDisabled(date)) return;

    const selection = this.nextSelection(date);

    if (!selection.complete) {
      this.draft = selection;
      this.previewDate = null;
      this.focusedDate = date;
      this.renderCalendar();
      return;
    }

    this.draft = null;
    this.commitSelection(selection, date);
    this.close({ restoreFocus: true, event: "select" });
  }

  // Open / close

  initializePositionedElement() {
    if (this.positionedElement || !this.content || !this.trigger) return;

    this.positionedElement = new PositionedElement(this.content, this.trigger, {
      placement: this.content.getAttribute("data-side") || "bottom",
      alignment: this.content.getAttribute("data-align") || "start",
      sideOffset: 6,
      flip: true,
      usePortal: !!this.options.usePortal,
      portalContainer:
        (this.options.portalContainer &&
          document.querySelector(this.options.portalContainer)) ||
        document.body,
      trapFocus: true,
      // Only the navigation buttons, the one tabbable day, and content added
      // below the calendar take part in Tab
      focusableSelector:
        'a[href], button:not([disabled]):not([tabindex="-1"]), input:not([disabled]):not([type="hidden"]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])',
      initialFocus: () => this.getDayButton(this.focusedDate),
      onOutsideClick: () => this.close({ restoreFocus: false }),
    });
  }

  close({ restoreFocus = true, event = "close" } = {}) {
    this.restoreFocusOnClose = restoreFocus;
    this.transition(event);
  }

  onOpenEnter() {
    this.restoreFocusOnClose = true;
    this.draft = null;
    this.previewDate = null;
    this.focusedDate = this.clampDate(this.from || today());
    this.renderCalendar();

    this.initializePositionedElement();
    this.positionedElement?.activate();
    this.pushEvent("opened");
  }

  onOpenExit() {
    if (this.positionedElement) {
      // Focus is restored here, not by the focus trap: after an outside click
      // the user has already moved on, so focus must stay where they put it.
      this.positionedElement.focusTrap.previouslyFocused = null;
      this.positionedElement.deactivate();
    }

    if (this.restoreFocusOnClose) {
      this.trigger?.focus({ preventScroll: true });
    }
  }

  onClosedEnter() {
    // Closing halfway through picking a range keeps the previous value
    if (this.draft) {
      this.draft = null;
      this.renderSelection();
    }
    this.pushEvent("closed");
  }

  onServerValueChanged() {
    this.draft = null;
  }

  onMonthChanged() {
    this.positionedElement?.update();
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      event.preventDefault();
      event.stopPropagation();
      this.close({ restoreFocus: true });
      return;
    }

    super.handleKeydown(event);
  }

  // LiveView

  onDomUpdate() {
    // While the calendar sits in a portal, a LiveView patch renders a second
    // copy of it inside the root. Drop that copy so ids and parts stay unique.
    if (this.content && !this.el.contains(this.content)) {
      this.el
        .querySelectorAll('[data-part="content"]')
        .forEach((copy) => copy.remove());
    }

    super.onDomUpdate();

    if (this.state === "open") {
      this.positionedElement?.update();
    }
  }

  beforeDestroy() {
    super.beforeDestroy();
    this.positionedElement?.destroy();
    this.positionedElement = null;
  }
}

SaladUI.register("date-picker", DatePickerComponent);

export default DatePickerComponent;
