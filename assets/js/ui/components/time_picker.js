// saladui/components/time_picker.js
import Component from "../core/component";
import SaladUI from "../index";

const pad = (number) => String(number).padStart(2, "0");

const SEGMENTS = {
  hours: { max: 23 },
  minutes: { max: 59 },
};

/**
 * Reads a time of day and returns it as "hh:mm" (24-hour), or null when it
 * can't be read. Used for pasted text: "14:30", "14.30", "14h30", "1430",
 * and "930" all work.
 */
export function parseTime(text) {
  if (typeof text !== "string") return null;
  const value = text.trim();

  let hours;
  let minutes;

  if (/^\d{3,4}$/.test(value)) {
    hours = value.slice(0, -2);
    minutes = value.slice(-2);
  } else {
    const match = /^(\d{1,2})\s*[:.h]\s*(\d{1,2})?(?::\d{2})?$/i.exec(value);
    if (!match) return null;
    hours = match[1];
    minutes = match[2] || "0";
  }

  hours = Number(hours);
  minutes = Number(minutes);
  if (hours > 23 || minutes > 59) return null;
  return `${pad(hours)}:${pad(minutes)}`;
}

// "14:30" -> { hours: 14, minutes: 30 }, "--:30" -> { hours: null, minutes: 30 }
function parseSegments(value) {
  const [hours, minutes] = (value || "").split(":");
  const read = (part) => (/^\d{1,2}$/.test(part || "") ? Number(part) : null);
  return { hours: read(hours), minutes: read(minutes) };
}

/**
 * TimePickerComponent: a time input with separate hour and minute fields,
 * like a native <input type="time">, always in 24-hour "hh:mm".
 *
 * The component handles typing itself (via beforeinput, so it works with
 * on-screen keyboards too): digits fill in the focused field and move on to
 * the minutes once the hours are complete. The time goes to a hidden input,
 * which is what the form submits. It's updated when focus leaves the time
 * picker, on Enter, and on every arrow key step; each update that changes the
 * time fires a change event on the hidden input (for LiveView's phx-change)
 * and pushes `value-changed`.
 */
class TimePickerComponent extends Component {
  constructor(el, hookContext) {
    super(el, { hookContext });

    this.fields = {
      hours: this.getPart("hours"),
      minutes: this.getPart("minutes"),
    };
    // Hidden copies of the fields' text, which size the fields
    this.sizers = {
      hours: this.getPart("hours-sizer"),
      minutes: this.getPart("minutes-sizer"),
    };
    this.input = this.getPart("input");

    this.serverValue = this.options.value ?? "";
    this.committed = this.serverValue;
    Object.assign(this, parseSegments(this.committed));
    // Digits typed into the focused field so far
    this.typed = "";

    this.readConstraints();
    this.readServerInvalid();
    this.render();
    this.renderInvalid();

    this.handleFocusIn = this.handleFocusIn.bind(this);
    this.handleFocusOut = this.handleFocusOut.bind(this);
    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleKeydown = this.handleKeydown.bind(this);
    this.handleBeforeInput = this.handleBeforeInput.bind(this);
    this.handleInput = this.handleInput.bind(this);
    this.handlePaste = this.handlePaste.bind(this);
    this.stopFormEvent = (event) => event.stopPropagation();
  }

  getComponentConfig() {
    return {};
  }

  setupComponentEvents() {
    if (this.componentEventsBound) return;
    this.componentEventsBound = true;

    this.el.addEventListener("focusin", this.handleFocusIn);
    this.el.addEventListener("focusout", this.handleFocusOut);
    this.el.addEventListener("mousedown", this.handleMouseDown);

    Object.values(this.fields).forEach((field) => {
      field?.addEventListener("keydown", this.handleKeydown);
      field?.addEventListener("beforeinput", this.handleBeforeInput);
      field?.addEventListener("input", this.handleInput);
      field?.addEventListener("paste", this.handlePaste);
      // The fields have no name; the hidden input carries the time to the form
      field?.addEventListener("change", this.stopFormEvent);
    });
  }

  // Options

  readConstraints() {
    const toMinutes = (value) => {
      const time = parseTime(value);
      return time
        ? Number(time.slice(0, 2)) * 60 + Number(time.slice(3))
        : null;
    };
    this.min = toMinutes(this.options.min);
    this.max = toMinutes(this.options.max);
    this.step = Math.max(Number(this.options.step) || 1, 1);
  }

  // aria-invalid as rendered by the server, e.g. for changeset errors
  readServerInvalid() {
    this.serverInvalid = this.el.getAttribute("aria-invalid") === "true";
  }

  // Value

  getValue() {
    const { hours, minutes } = this;
    if (hours === null && minutes === null) return "";
    const format = (part) => (part === null ? "--" : pad(part));
    return `${format(hours)}:${format(minutes)}`;
  }

  isComplete() {
    return this.hours !== null && this.minutes !== null;
  }

  // Sets the time from the fields. Only hours means on the hour.
  commit() {
    if (this.hours !== null && this.minutes === null) this.minutes = 0;
    this.typed = "";
    this.render();
    this.setValue(this.getValue(), { notify: true });
  }

  setValue(value, { notify }) {
    const changed = value !== this.committed;
    this.committed = value;

    if (this.input) {
      this.input.value = value;
      // Also set the attribute, so a LiveView patch that still carries the old
      // time differs from the DOM and onDomUpdate runs to restore this one.
      this.input.setAttribute("value", value);
    }
    this.renderInvalid();

    if (!notify || !changed) return;

    this.input?.dispatchEvent(new Event("change", { bubbles: true }));

    const complete = /^\d{2}:\d{2}$/.test(value);
    if (value === "" || complete) {
      this.pushEvent("value-changed", { value: complete ? value : null });
    }
  }

  restore() {
    Object.assign(this, parseSegments(this.committed));
    this.typed = "";
    this.render();
  }

  // Rendering

  render() {
    Object.entries(this.fields).forEach(([name, field]) => {
      if (!field) return;
      const value = this[name];
      field.value = value === null ? "" : pad(value);
      if (this.sizers[name]) {
        this.sizers[name].textContent = field.value || field.placeholder;
      }
      if (value === null) {
        field.removeAttribute("aria-valuenow");
      } else {
        field.setAttribute("aria-valuenow", String(value));
      }
    });
    this.el.toggleAttribute(
      "data-placeholder",
      this.hours === null && this.minutes === null,
    );
  }

  renderInvalid() {
    const { hours, minutes } = parseSegments(this.committed);
    const total = hours * 60 + minutes;
    const invalid =
      this.serverInvalid ||
      (this.committed !== "" &&
        (hours === null ||
          minutes === null ||
          hours > 23 ||
          minutes > 59 ||
          (this.min !== null && total < this.min) ||
          (this.max !== null && total > this.max)));

    [this.el, ...Object.values(this.fields)].forEach((element) => {
      if (!element) return;
      if (invalid) {
        element.setAttribute("aria-invalid", "true");
      } else {
        element.removeAttribute("aria-invalid");
      }
    });
  }

  // Focus

  segmentOf(element) {
    return Object.keys(this.fields).find(
      (name) => this.fields[name] === element,
    );
  }

  isEditable(name) {
    const field = this.fields[name];
    return !!field && !field.disabled && !field.readOnly;
  }

  focusSegment(name) {
    this.fields[name]?.focus();
  }

  handleFocusIn(event) {
    // Typing into a newly focused field replaces its value
    if (this.segmentOf(event.target)) this.typed = "";
  }

  handleFocusOut(event) {
    // Moving between the hours and minutes doesn't set the time yet
    if (this.el.contains(event.relatedTarget)) return;
    this.commit();
  }

  // Clicks on the padding, the colon, or the icon focus the nearest field
  handleMouseDown(event) {
    const { hours, minutes } = this.fields;
    if (!hours || hours.disabled) return;

    // While the placeholder hides the fields, a click starts at the hours
    const empty = this.hours === null && this.minutes === null;
    if (
      empty &&
      this.getPart("placeholder") &&
      !this.el.contains(document.activeElement)
    ) {
      event.preventDefault();
      this.focusSegment("hours");
      return;
    }

    if (this.segmentOf(event.target)) return;

    event.preventDefault();
    const pastHours =
      this.hours !== null &&
      minutes &&
      event.clientX >= minutes.getBoundingClientRect().left;
    this.focusSegment(pastHours ? "minutes" : "hours");
  }

  // Typing

  handleBeforeInput(event) {
    const name = this.segmentOf(event.target);
    // Enter arrives as insertLineBreak; letting it through keeps it submitting the form
    if (!name || event.inputType === "insertLineBreak") return;
    event.preventDefault();
    if (!this.isEditable(name)) return;
    this.applyInput(name, event.inputType, event.data);
  }

  // Only reached for input that beforeinput couldn't cancel, e.g. from an
  // input method: undo it, then type its digits
  handleInput(event) {
    event.stopPropagation();
    const name = this.segmentOf(event.target);
    if (!name) return;
    this.render();
    if (event.data && !event.isComposing && this.isEditable(name)) {
      this.applyInput(name, "insertText", event.data);
    }
  }

  handlePaste(event) {
    const name = this.segmentOf(event.target);
    if (!name) return;
    event.preventDefault();
    const text = event.clipboardData?.getData("text") || "";
    if (this.isEditable(name)) this.applyInput(name, "insertText", text);
  }

  applyInput(name, inputType, data) {
    if (inputType.startsWith("delete")) {
      if (inputType === "deleteContentForward") {
        this.clearSegment(name);
      } else {
        this.deleteDigit(name);
      }
      return;
    }

    const text = data || "";
    if (!text) return;

    // A pasted time fills in both fields
    if (text.length > 2 && parseTime(text)) {
      Object.assign(this, parseSegments(parseTime(text)));
      this.typed = "";
      this.render();
      return;
    }

    for (const char of text) {
      if (/\d/.test(char)) {
        this.typeDigit(name, char);
        // Later digits go to the field that's focused now
        name = this.segmentOf(document.activeElement) || name;
      } else if (/[:.,hH\s]/.test(char) && name === "hours") {
        if (this.hours === null) continue;
        this.focusSegment("minutes");
        name = "minutes";
      }
    }
  }

  typeDigit(name, digit) {
    const { max } = SEGMENTS[name];

    // A digit that doesn't fit after the previous ones starts over
    let typed = this.typed + digit;
    if (Number(typed) > max) typed = digit;

    this[name] = Number(typed);
    // Done after two digits, or when no second digit could follow
    const done = typed.length === 2 || Number(typed) * 10 > max;
    this.typed = done ? "" : typed;
    this.render();

    if (done && name === "hours") this.focusSegment("minutes");
  }

  deleteDigit(name) {
    const value = this[name];
    if (value === null) {
      if (name === "minutes") this.focusSegment("hours");
      return;
    }
    // 14 -> 1 -> empty; typing again continues from what's left
    this[name] = value >= 10 ? Math.floor(value / 10) : null;
    this.typed = this[name] === null ? "" : String(this[name]);
    this.render();
  }

  clearSegment(name) {
    this[name] = null;
    this.typed = "";
    this.render();
  }

  // Keyboard

  handleKeydown(event) {
    if (event.isComposing) return;
    const name = this.segmentOf(event.target);
    if (!name) return;

    switch (event.key) {
      case "Enter":
        // No preventDefault: Enter still submits the form, with the time set
        this.commit();
        break;
      case "Escape":
        if (this.getValue() !== this.committed) {
          // Restore first; a second Escape can close a surrounding dialog
          event.preventDefault();
          event.stopPropagation();
          this.restore();
        }
        break;
      case "ArrowUp":
      case "ArrowDown":
        event.preventDefault();
        if (this.isEditable(name)) {
          this.stepSegment(name, event.key === "ArrowUp" ? 1 : -1);
        }
        break;
      case "ArrowLeft":
        event.preventDefault();
        if (name === "minutes") this.focusSegment("hours");
        break;
      case "ArrowRight":
        event.preventDefault();
        if (name === "hours") this.focusSegment("minutes");
        break;
      case "Backspace":
      case "Delete":
        // Handled here rather than in beforeinput, which doesn't fire when
        // the field is already empty
        event.preventDefault();
        if (this.isEditable(name)) {
          this.applyInput(
            name,
            event.key === "Delete"
              ? "deleteContentForward"
              : "deleteContentBackward",
          );
        }
        break;
    }
  }

  // Hours move by one and minutes to the next multiple of `step`, wrapping
  // around like a clock without changing the other field. An empty field
  // starts at the current hour, or at :00.
  stepSegment(name, direction) {
    const value = this[name];
    const size = SEGMENTS[name].max + 1;
    let next;

    if (value === null) {
      next = name === "hours" ? new Date().getHours() : 0;
    } else if (name === "hours") {
      next = value + direction;
    } else {
      next =
        direction > 0
          ? (Math.floor(value / this.step) + 1) * this.step
          : (Math.ceil(value / this.step) - 1) * this.step;
    }

    this[name] = ((next % size) + size) % size;
    this.typed = "";
    this.render();

    // A complete time is set right away, like a native time input does
    if (this.isComplete()) this.setValue(this.getValue(), { notify: true });
  }

  // LiveView

  onDomUpdate() {
    super.onDomUpdate();
    this.readConstraints();
    this.readServerInvalid();

    const serverValue = this.options.value ?? "";
    if (serverValue !== this.serverValue) {
      this.serverValue = serverValue;
      // Keep a time that's still being entered
      const editing =
        this.el.contains(document.activeElement) &&
        this.getValue() !== this.committed;
      if (!editing) Object.assign(this, parseSegments(serverValue));
      this.setValue(serverValue, { notify: false });
    } else {
      // A re-render that still carries the old time (e.g. no phx-change on
      // the form) must not undo the user's time
      this.setValue(this.committed, { notify: false });
    }

    // The patch reset the fields to the server-rendered values
    this.render();
  }

  beforeDestroy() {
    this.el?.removeEventListener("focusin", this.handleFocusIn);
    this.el?.removeEventListener("focusout", this.handleFocusOut);
    this.el?.removeEventListener("mousedown", this.handleMouseDown);

    Object.values(this.fields).forEach((field) => {
      field?.removeEventListener("keydown", this.handleKeydown);
      field?.removeEventListener("beforeinput", this.handleBeforeInput);
      field?.removeEventListener("input", this.handleInput);
      field?.removeEventListener("paste", this.handlePaste);
      field?.removeEventListener("change", this.stopFormEvent);
    });
  }
}

SaladUI.register("time-picker", TimePickerComponent);

export default TimePickerComponent;
