// saladui/components/calendar.js
import Component from "../core/component";
import SaladUI from "../index";

// Dates are calendar days, not instants. They are kept as Date objects at UTC
// midnight and formatted with timeZone "UTC", so neither the browser's time
// zone nor daylight saving time can shift a day.
const DAY_MS = 24 * 60 * 60 * 1000;

function makeDate(year, monthIndex, day) {
  const date = new Date(0);
  date.setUTCFullYear(year, monthIndex, day);
  return date;
}

export function parseISODate(value) {
  if (typeof value !== "string") return null;
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
  if (!match) return null;

  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  const date = makeDate(year, month - 1, day);

  // Reject overflowing values such as 2026-02-31
  if (date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day)
    return null;
  return date;
}

const pad = (number, length = 2) => String(number).padStart(length, "0");

export function toISODate(date) {
  if (!date) return null;
  return `${pad(date.getUTCFullYear(), 4)}-${pad(date.getUTCMonth() + 1)}-${pad(date.getUTCDate())}`;
}

export function formatDisplayDate(date) {
  return `${pad(date.getUTCDate())}.${pad(date.getUTCMonth() + 1)}.${pad(date.getUTCFullYear(), 4)}`;
}

export function today() {
  const now = new Date();
  return makeDate(now.getFullYear(), now.getMonth(), now.getDate());
}

const addDays = (date, days) => new Date(date.getTime() + days * DAY_MS);

function addMonths(date, months) {
  const year = date.getUTCFullYear();
  const month = date.getUTCMonth() + months;
  // Clamp the day so that Jan 31 + 1 month is Feb 28/29, not Mar 3
  const lastDay = makeDate(year, month + 1, 0).getUTCDate();
  return makeDate(year, month, Math.min(date.getUTCDate(), lastDay));
}

const startOfMonth = (date) =>
  makeDate(date.getUTCFullYear(), date.getUTCMonth(), 1);

const endOfMonth = (date) =>
  makeDate(date.getUTCFullYear(), date.getUTCMonth() + 1, 0);

// Weeks start on Monday: Monday is 0, Sunday is 6
const weekdayIndex = (date) => (date.getUTCDay() + 6) % 7;

const sameDay = (a, b) => !!a && !!b && a.getTime() === b.getTime();

const sameMonth = (a, b) =>
  a.getUTCFullYear() === b.getUTCFullYear() &&
  a.getUTCMonth() === b.getUTCMonth();

function createFormatter(locale, options) {
  try {
    return new Intl.DateTimeFormat(locale, { ...options, timeZone: "UTC" });
  } catch (_error) {
    return new Intl.DateTimeFormat("en", { ...options, timeZone: "UTC" });
  }
}

/**
 * CalendarComponent: a month grid for picking a single date or a date range.
 * The grid follows the WAI-ARIA date picker pattern: a single tabbable day
 * (roving tabindex) and arrow-key navigation. DatePickerComponent extends it
 * to show the grid in a popover.
 *
 * The selection is kept as `from` and `to`. In single mode only `from` is
 * used; in range mode `to` stays empty until the end of the range is picked.
 */
class CalendarComponent extends Component {
  constructor(el, hookContext) {
    super(el, { hookContext });

    this.initParts();

    this.isRange = this.options.mode === "range";
    this.serverValue = this.options.value ?? null;
    this.serverEndValue = this.options.endValue ?? null;
    this.from = parseISODate(this.serverValue);
    this.to = this.isRange ? parseISODate(this.serverEndValue) : null;
    this.previewDate = null;

    this.readConstraints();
    this.readLocale();

    this.focusedDate = this.clampDate(this.from || today());
    this.renderWeekdays();
    this.renderCalendar();
    this.syncValue({ notify: false });

    this.handleGridClick = this.handleGridClick.bind(this);
    this.handleGridHover = this.handleGridHover.bind(this);
    this.handleGridLeave = this.handleGridLeave.bind(this);
    this.handleKeydown = this.handleKeydown.bind(this);
    this.showPreviousMonth = () => this.shiftMonth(-1);
    this.showNextMonth = () => this.shiftMonth(1);
  }

  initParts() {
    this.input = this.getPart("input");
    this.endInput = this.getPart("end-input");
    this.calendar = this.getPart("calendar");
    this.caption = this.getPart("caption");
    this.grid = this.getPart("grid");
    this.weekdaysRow = this.getPart("weekdays");
    this.weeksBody = this.getPart("weeks");
    this.previousButton = this.getPart("previous-month");
    this.nextButton = this.getPart("next-month");
    this.templates = {
      weekday: this.getPart("weekday-template"),
      week: this.getPart("week-template"),
      day: this.getPart("day-template"),
    };
  }

  getComponentConfig() {
    return {};
  }

  setupComponentEvents() {
    if (this.componentEventsBound) return;
    this.componentEventsBound = true;

    // Listeners sit on the parts themselves rather than on the root, so they
    // keep working when a date picker moves its calendar into a portal.
    this.weeksBody?.addEventListener("click", this.handleGridClick);
    // mousemove rather than mouseover: re-rendering the grid under a still
    // pointer fires mouseover, which would override a keyboard preview.
    this.weeksBody?.addEventListener("mousemove", this.handleGridHover);
    this.weeksBody?.addEventListener("mouseleave", this.handleGridLeave);
    this.getKeydownTarget()?.addEventListener("keydown", this.handleKeydown);
    this.previousButton?.addEventListener("click", this.showPreviousMonth);
    this.nextButton?.addEventListener("click", this.showNextMonth);
  }

  getKeydownTarget() {
    return this.calendar;
  }

  // Options

  readConstraints() {
    this.minDate = parseISODate(this.options.min);
    this.maxDate = parseISODate(this.options.max);
    this.disabledDates = new Set(
      (this.options.disabledDates || []).filter((value) => parseISODate(value)),
    );
  }

  readLocale() {
    const locale = this.options.locale || document.documentElement.lang || "en";
    if (locale === this.locale) return;

    this.locale = locale;
    this.formatters = {
      caption: createFormatter(locale, { month: "long", year: "numeric" }),
      weekdayShort: createFormatter(locale, { weekday: "short" }),
      weekdayLong: createFormatter(locale, { weekday: "long" }),
      dayLabel: createFormatter(locale, {
        weekday: "long",
        day: "numeric",
        month: "long",
        year: "numeric",
      }),
    };
  }

  isDateDisabled(date) {
    if (this.minDate && date < this.minDate) return true;
    if (this.maxDate && date > this.maxDate) return true;
    return this.disabledDates.has(toISODate(date));
  }

  clampDate(date) {
    if (this.minDate && date < this.minDate) return this.minDate;
    if (this.maxDate && date > this.maxDate) return this.maxDate;
    return date;
  }

  // Selection

  // The selection shown in the grid. DatePickerComponent overrides it to show
  // a range that is still being picked.
  getSelection() {
    return { from: this.from, to: this.to };
  }

  // Works out the selection after `date` is picked:
  //
  //   * single: picks the date, or clears it when it's already selected
  //   * range: the first pick starts a range and the second ends it (a day
  //     before the start restarts the range instead). Picking the start of a
  //     finished range clears it.
  nextSelection(date) {
    const { from, to } = this.getSelection();

    if (!this.isRange) {
      return sameDay(from, date)
        ? { from: null, to: null, complete: true }
        : { from: date, to: null, complete: true };
    }

    if (from && to && sameDay(from, date)) {
      return { from: null, to: null, complete: true };
    }
    if (!from || to || date < from) {
      return { from: date, to: null, complete: false };
    }
    return { from, to: date, complete: true };
  }

  selectDate(date) {
    if (!date || this.isDateDisabled(date)) return;
    this.commitSelection(this.nextSelection(date), date);
  }

  commitSelection({ from, to }, date) {
    this.from = from;
    this.to = to;
    this.previewDate = null;
    this.focusedDate = date || this.focusedDate;
    this.syncValue({ notify: true });
    this.renderCalendar();
    this.pushEvent("value-changed", { value: this.getEventValue() });
  }

  getEventValue() {
    if (!this.isRange) return toISODate(this.from);
    return { from: toISODate(this.from), to: toISODate(this.to) };
  }

  syncValue({ notify }) {
    if (this.input) this.input.value = toISODate(this.from) || "";
    if (this.endInput) this.endInput.value = toISODate(this.to) || "";

    if (notify) {
      // LiveView marks only the input an event comes from as used, so the
      // end input needs its own event for its errors to show up.
      [this.endInput, this.input].forEach((input) =>
        input?.dispatchEvent(new Event("change", { bubbles: true })),
      );
    }
  }

  // Rendering

  renderWeekdays() {
    if (!this.weekdaysRow || !this.templates.weekday) return;

    // 2024-01-01 was a Monday
    const monday = makeDate(2024, 0, 1);
    const cells = Array.from({ length: 7 }, (_, offset) => {
      const date = addDays(monday, offset);
      const cell =
        this.templates.weekday.content.firstElementChild.cloneNode(true);
      cell.textContent = this.formatters.weekdayShort
        .format(date)
        .replace(/\.$/, "")
        .slice(0, 2);
      cell.setAttribute("abbr", this.formatters.weekdayLong.format(date));
      return cell;
    });

    this.weekdaysRow.replaceChildren(...cells);
  }

  renderCalendar() {
    if (!this.weeksBody || !this.templates.day || !this.focusedDate) return;

    const hadFocus = this.weeksBody.contains(document.activeElement);

    const month = startOfMonth(this.focusedDate);
    this.visibleMonth = month;
    const caption = this.formatters.caption.format(month);

    if (this.caption) this.caption.textContent = caption;
    this.grid?.setAttribute("aria-label", caption);
    this.grid?.setAttribute("aria-multiselectable", String(this.isRange));

    if (this.previousButton) {
      this.previousButton.disabled = !!this.minDate && month <= this.minDate;
    }
    if (this.nextButton) {
      this.nextButton.disabled =
        !!this.maxDate && addDays(endOfMonth(month), 1) > this.maxDate;
    }

    const firstDay = addDays(month, -weekdayIndex(month));
    const lastOfMonth = endOfMonth(month);
    const lastDay = addDays(lastOfMonth, 6 - weekdayIndex(lastOfMonth));
    const currentDay = today();

    const weeks = [];
    let week = null;

    for (let date = firstDay; date <= lastDay; date = addDays(date, 1)) {
      if (weekdayIndex(date) === 0) {
        week = this.templates.week.content.firstElementChild.cloneNode(false);
        weeks.push(week);
      }

      const cell = this.templates.day.content.firstElementChild.cloneNode(true);
      const button = cell.querySelector("button");
      button.textContent = String(date.getUTCDate());
      button.dataset.date = toISODate(date);
      button.setAttribute("aria-label", this.formatters.dayLabel.format(date));
      button.tabIndex = sameDay(date, this.focusedDate) ? 0 : -1;

      if (sameDay(date, currentDay))
        button.setAttribute("aria-current", "date");
      if (this.isDateDisabled(date)) {
        button.setAttribute("data-disabled", "");
        button.setAttribute("aria-disabled", "true");
      }

      week.appendChild(cell);
    }

    this.weeksBody.replaceChildren(...weeks);
    this.renderSelection();

    if (hadFocus) {
      this.getDayButton(this.focusedDate)?.focus({ preventScroll: true });
    }
  }

  // Marks the selected days. Runs on its own while hovering, so a range
  // preview doesn't rebuild the grid under the pointer.
  renderSelection() {
    if (!this.weeksBody) return;

    const { from, to } = this.getSelection();
    const preview =
      this.isRange && from && !to && this.previewDate > from
        ? this.previewDate
        : null;
    const end = to || preview;

    this.weeksBody.querySelectorAll("button[data-date]").forEach((button) => {
      const cell = button.parentElement;
      const date = parseISODate(button.dataset.date);

      const isStart = sameDay(date, from);
      const isEnd = !!to && sameDay(date, to);
      const spans = !!from && !!end && end > from;
      const inside = spans && date > from && date < end;
      const previewEnd = !!preview && sameDay(date, preview);

      const marked = isStart || isEnd || inside || previewEnd;

      // Selected and in-range styles win over the today and outside-month ones
      button.toggleAttribute("data-selected", isStart || isEnd);
      button.toggleAttribute("data-range-middle", inside || previewEnd);
      button.toggleAttribute(
        "data-today",
        !marked && button.getAttribute("aria-current") === "date",
      );
      button.toggleAttribute(
        "data-outside",
        !marked && !sameMonth(date, this.visibleMonth),
      );
      cell.toggleAttribute("data-range-start", spans && isStart);
      cell.toggleAttribute("data-range-end", spans && (isEnd || previewEnd));
      cell.toggleAttribute("data-range-middle", inside);
      cell.setAttribute(
        "aria-selected",
        String(isStart || isEnd || (inside && !preview)),
      );
    });
  }

  getDayButton(date) {
    if (!date || !this.weeksBody) return null;
    return this.weeksBody.querySelector(
      `button[data-date="${toISODate(date)}"]`,
    );
  }

  // Navigation

  focusDate(date) {
    this.focusedDate = this.clampDate(date);
    this.previewDate = this.focusedDate;
    this.renderCalendar();
    this.getDayButton(this.focusedDate)?.focus({ preventScroll: true });
  }

  shiftMonth(months) {
    if (!this.focusedDate) return;

    const navButton = months < 0 ? this.previousButton : this.nextButton;
    const navHadFocus = document.activeElement === navButton;

    this.focusedDate = this.clampDate(addMonths(this.focusedDate, months));
    this.renderCalendar();
    this.onMonthChanged();

    // Reaching min/max disables the button that was just pressed; move focus
    // into the grid so it isn't lost.
    if (navHadFocus && navButton.disabled) {
      this.getDayButton(this.focusedDate)?.focus({ preventScroll: true });
    }
  }

  // Called after the visible month changed, e.g. to reposition a popover
  onMonthChanged() {}

  handleGridClick(event) {
    const button = event.target.closest("button[data-date]");
    if (!button || button.hasAttribute("data-disabled")) return;
    this.selectDate(parseISODate(button.dataset.date));
  }

  handleGridHover(event) {
    if (!this.isRange) return;

    const button = event.target.closest("button[data-date]");
    const date = button && parseISODate(button.dataset.date);
    if (sameDay(date, this.previewDate) || (!date && !this.previewDate)) return;

    this.previewDate = date;
    this.renderSelection();
  }

  handleGridLeave() {
    if (!this.isRange || !this.previewDate) return;

    this.previewDate = null;
    this.renderSelection();
  }

  handleKeydown(event) {
    // Arrow keys only navigate when a day has focus; Enter and Space fall
    // through to the button's native click.
    const button = event.target.closest?.("button[data-date]");
    if (!button || !this.focusedDate) return;

    const date = this.focusedDate;
    let next;

    switch (event.key) {
      case "ArrowLeft":
        next = addDays(date, -1);
        break;
      case "ArrowRight":
        next = addDays(date, 1);
        break;
      case "ArrowUp":
        next = addDays(date, -7);
        break;
      case "ArrowDown":
        next = addDays(date, 7);
        break;
      case "Home":
        next = addDays(date, -weekdayIndex(date));
        break;
      case "End":
        next = addDays(date, 6 - weekdayIndex(date));
        break;
      case "PageUp":
        next = addMonths(date, event.shiftKey ? -12 : -1);
        break;
      case "PageDown":
        next = addMonths(date, event.shiftKey ? 12 : 1);
        break;
      default:
        return;
    }

    event.preventDefault();
    const monthChanged = !sameMonth(this.clampDate(next), date);
    this.focusDate(next);
    if (monthChanged) this.onMonthChanged();
  }

  // LiveView

  onDomUpdate() {
    super.onDomUpdate();
    this.readConstraints();
    this.readLocale();

    // Take the server's value only when the server changed it. A re-render
    // that still carries the old value (e.g. no phx-change on the form) must
    // not undo the user's pick.
    const serverValue = this.options.value ?? null;
    const serverEndValue = this.options.endValue ?? null;
    if (
      serverValue !== this.serverValue ||
      serverEndValue !== this.serverEndValue
    ) {
      this.serverValue = serverValue;
      this.serverEndValue = serverEndValue;
      this.from = parseISODate(serverValue);
      this.to = this.isRange ? parseISODate(serverEndValue) : null;
      this.onServerValueChanged();
      if (this.from) this.focusedDate = this.from;
    }
    this.focusedDate = this.clampDate(this.focusedDate || today());

    // The patch replaced the server-rendered (empty) weekday row and grid
    this.renderWeekdays();
    this.renderCalendar();
    this.syncValue({ notify: false });
  }

  // Called when the server sent a new value
  onServerValueChanged() {}

  beforeDestroy() {
    this.weeksBody?.removeEventListener("click", this.handleGridClick);
    this.weeksBody?.removeEventListener("mousemove", this.handleGridHover);
    this.weeksBody?.removeEventListener("mouseleave", this.handleGridLeave);
    this.getKeydownTarget()?.removeEventListener("keydown", this.handleKeydown);
    this.previousButton?.removeEventListener("click", this.showPreviousMonth);
    this.nextButton?.removeEventListener("click", this.showNextMonth);
  }
}

SaladUI.register("calendar", CalendarComponent);

export default CalendarComponent;
