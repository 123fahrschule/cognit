const COLLAPSED_GAP = 14;
const EXPANDED_GAP = 14;
const SCALE_STEP = 0.05;
const PEEK_COUNT = 3;
const STORAGE_KEY = "cognit:toasts";

export const Toaster = {
  mounted() {
    this.defaultDuration = parseInt(this.el.dataset.duration || "4000", 10);
    this.fromTop = this.el.dataset.position?.startsWith("top");
    this.fromLeft = this.el.dataset.position?.endsWith("left");
    this.centered = this.el.dataset.position?.endsWith("center");
    this.stack = [];
    this.expanded = false;

    // Inherited by each card so it doesn't sit flush against the viewport
    // edge — absolutely positioned children ignore their container's own
    // padding, so the gap has to live on the card itself.
    this.el.style.setProperty("--salad-toast-gap", "clamp(1rem, 4vw, 2rem)");

    this.el.addEventListener("mouseenter", () => this.setExpanded(true));
    this.el.addEventListener("mouseleave", () => this.setExpanded(false));
    this.el.addEventListener("focusin", () => this.setExpanded(true));
    this.el.addEventListener("focusout", () => this.setExpanded(false));

    this.handleEvent("cognit:toast", (payload) => {
      const entry = this.persistToast(payload);
      this.addToast(payload, entry.id);
    });

    this.replayPersistedToasts();
  },

  // A toast pushed right before a live navigation dies with the page: the
  // event still arrives, but the toaster element is torn down while the view
  // is swapped. Every pushed toast is therefore mirrored into sessionStorage
  // and replayed with its remaining lifetime by the next toaster instance,
  // so toasts survive live navigation. Entries are dropped once dismissed or
  // expired.
  persistToast({ html, duration }) {
    const entry = {
      id: self.crypto?.randomUUID?.() || `${Date.now()}-${Math.random()}`,
      html,
      duration: duration ?? this.defaultDuration,
      addedAt: Date.now(),
    };

    this.writePersistedToasts([...this.readPersistedToasts(), entry]);
    return entry;
  },

  unpersistToast(id) {
    if (!id) return;

    this.writePersistedToasts(
      this.readPersistedToasts().filter((entry) => entry.id !== id)
    );
  },

  replayPersistedToasts() {
    const now = Date.now();
    const alive = [];

    this.readPersistedToasts().forEach((entry) => {
      const remaining = entry.duration - (now - entry.addedAt);
      if (entry.duration > 0 && remaining <= 0) return;

      alive.push(entry);
      this.addToast(
        { html: entry.html, duration: entry.duration > 0 ? remaining : 0 },
        entry.id
      );
    });

    this.writePersistedToasts(alive);
  },

  readPersistedToasts() {
    try {
      return JSON.parse(sessionStorage.getItem(STORAGE_KEY)) || [];
    } catch {
      return [];
    }
  },

  writePersistedToasts(entries) {
    try {
      sessionStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
    } catch {
      // Unavailable storage only costs navigation survival.
    }
  },

  addToast({ html, duration }, storageId) {
    const wrapper = document.createElement("div");
    wrapper.innerHTML = html.trim();
    const card = wrapper.firstElementChild;
    if (!card) return;

    card._cognitStorageId = storageId;
    card.style.position = "absolute";
    card.style.width = "min(24rem, calc(100vw - 2 * var(--salad-toast-gap)))";
    // Centered cards anchor to the viewport middle and shift back half their
    // width through the translate in cardTransform.
    if (this.centered) {
      card.style.left = "50%";
    } else {
      card.style[this.fromLeft ? "left" : "right"] = "var(--salad-toast-gap)";
    }
    card.style[this.fromTop ? "top" : "bottom"] = "var(--salad-toast-gap)";
    card.style.transformOrigin = `${this.fromTop ? "top" : "bottom"} ${
      this.centered ? "center" : this.fromLeft ? "left" : "right"
    }`;
    card.style.opacity = "0";
    card.style.transform = this.cardTransform(this.fromTop ? -8 : 8, 1);

    // The action button already carries a real `phx-click` binding (rendered
    // server-side), so LiveView's own delegated click handling runs it. We
    // only need to dismiss the card afterwards.
    card
      .querySelector("button[phx-click]")
      ?.addEventListener("click", () => this.dismiss(card));

    // Click anywhere on the card (outside the action) dismisses
    card.addEventListener("click", (e) => {
      if (e.target.closest("button")) return;
      this.dismiss(card);
    });

    this.el.appendChild(card);
    this.stack.unshift(card);

    // Force a style flush so the enter animation transitions from the
    // values set above instead of jumping straight to the layout below.
    card.offsetWidth;
    requestAnimationFrame(() => this.layout());

    const totalMs = duration ?? this.defaultDuration;
    if (totalMs > 0) {
      card._cognitTiming = { remaining: totalMs, startedAt: Date.now() };
      card._cognitTimer = setTimeout(() => this.dismiss(card), totalMs);
    }
  },

  setExpanded(expanded) {
    if (this.expanded === expanded) return;
    this.expanded = expanded;
    this.stack.forEach((card) => this.pauseOrResume(card, expanded));
    this.layout();
  },

  pauseOrResume(card, paused) {
    const timing = card._cognitTiming;
    if (!timing) return;

    if (paused) {
      clearTimeout(card._cognitTimer);
      timing.remaining -= Date.now() - timing.startedAt;
    } else {
      timing.startedAt = Date.now();
      card._cognitTimer = setTimeout(
        () => this.dismiss(card),
        Math.max(timing.remaining, 1000)
      );
    }
  },

  layout() {
    let offset = 0;

    this.stack.forEach((card, index) => {
      const z = this.stack.length - index;
      card.style.zIndex = z;

      if (this.expanded) {
        const y = (this.fromTop ? 1 : -1) * offset;
        card.style.transform = this.cardTransform(y, 1);
        card.style.opacity = "1";
        card.style.pointerEvents = "auto";
        offset += card.offsetHeight + EXPANDED_GAP;
      } else {
        const depth = Math.min(index, PEEK_COUNT - 1);
        const y = (this.fromTop ? 1 : -1) * depth * COLLAPSED_GAP;
        const scale = 1 - depth * SCALE_STEP;
        card.style.transform = this.cardTransform(y, scale);
        card.style.opacity = index < PEEK_COUNT ? "1" : "0";
        card.style.pointerEvents = index === 0 ? "auto" : "none";
      }
    });
  },

  dismiss(card) {
    if (card._cognitDismissed) return;
    card._cognitDismissed = true;
    clearTimeout(card._cognitTimer);
    this.unpersistToast(card._cognitStorageId);

    this.stack = this.stack.filter((c) => c !== card);
    this.layout();

    card.style.opacity = "0";
    card.style.transform = this.cardTransform(this.fromTop ? -8 : 8, 1);
    setTimeout(() => card.remove(), 300);
  },

  // Centered positions carry the -50% horizontal shift inside the transform,
  // so every transform update has to go through here to keep it.
  cardTransform(y, scale) {
    const x = this.centered ? "-50%" : "0px";
    return `translate(${x}, ${y}px) scale(${scale})`;
  },

  destroyed() {
    this.stack.forEach((card) => clearTimeout(card._cognitTimer));
  },
};
