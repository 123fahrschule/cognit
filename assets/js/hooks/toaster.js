const COLLAPSED_GAP = 14;
const EXPANDED_GAP = 14;
const SCALE_STEP = 0.05;
const PEEK_COUNT = 3;

export const Toaster = {
  mounted() {
    this.defaultDuration = parseInt(this.el.dataset.duration || "4000", 10);
    this.stack = [];
    this.expanded = false;

    // Absolutely positioned cards ignore the container's padding, so the
    // edge gap lives on each card.
    this.el.style.setProperty("--salad-toast-gap", "clamp(1rem, 4vw, 2rem)");

    this.el.addEventListener("mouseenter", () => this.setExpanded(true));
    this.el.addEventListener("mouseleave", () => this.setExpanded(false));
    this.el.addEventListener("focusin", () => this.setExpanded(true));
    this.el.addEventListener("focusout", () => this.setExpanded(false));

    this.handleEvent("cognit:toast", (payload) => this.addToast(payload));
  },

  addToast({ html, duration }) {
    const wrapper = document.createElement("div");
    wrapper.innerHTML = html.trim();
    const card = wrapper.firstElementChild;
    if (!card) return;

    card.style.position = "absolute";
    card.style.width = "min(24rem, calc(100vw - 2 * var(--salad-toast-gap)))";
    // Centered via left 50% plus the -50% shift in cardTransform.
    card.style.left = "50%";
    card.style.top = "var(--salad-toast-gap)";
    card.style.transformOrigin = "top center";
    card.style.opacity = "0";
    card.style.transform = this.cardTransform(-8, 1);

    // The action button's `phx-click` runs through LiveView's delegated
    // handling; we only dismiss the card afterwards.
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

    // Style flush so the enter animation starts from the values above.
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
        Math.max(timing.remaining, 1000),
      );
    }
  },

  layout() {
    let offset = 0;

    this.stack.forEach((card, index) => {
      const z = this.stack.length - index;
      card.style.zIndex = z;

      if (this.expanded) {
        card.style.transform = this.cardTransform(offset, 1);
        card.style.opacity = "1";
        card.style.pointerEvents = "auto";
        offset += card.offsetHeight + EXPANDED_GAP;
      } else {
        const depth = Math.min(index, PEEK_COUNT - 1);
        const scale = 1 - depth * SCALE_STEP;
        card.style.transform = this.cardTransform(depth * COLLAPSED_GAP, scale);
        card.style.opacity = index < PEEK_COUNT ? "1" : "0";
        card.style.pointerEvents = index === 0 ? "auto" : "none";
      }
    });
  },

  dismiss(card) {
    if (card._cognitDismissed) return;
    card._cognitDismissed = true;
    clearTimeout(card._cognitTimer);

    this.stack = this.stack.filter((c) => c !== card);
    this.layout();

    card.style.opacity = "0";
    card.style.transform = this.cardTransform(-8, 1);
    setTimeout(() => card.remove(), 300);
  },

  // Every transform update must keep the -50% centering shift.
  cardTransform(y, scale) {
    return `translate(-50%, ${y}px) scale(${scale})`;
  },

  destroyed() {
    this.stack.forEach((card) => clearTimeout(card._cognitTimer));
  },
};
