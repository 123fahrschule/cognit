const KIND_CLASSES = {
  default: "border bg-background text-foreground",
  success: "border border-success/40 bg-background text-foreground",
  error: "border border-destructive/40 bg-background text-destructive",
  warning: "border border-warning/40 bg-background text-foreground",
  info: "border bg-background text-foreground",
};

const BASE_CARD_CLASSES =
  "pointer-events-auto relative w-full rounded-xl px-4 py-3 shadow-lg " +
  "transition-all duration-300 ease-out";

const ACTION_BUTTON_CLASSES =
  "ml-auto shrink-0 self-center rounded-md bg-primary px-3 py-1.5 " +
  "text-xs font-medium text-primary-foreground hover:bg-primary/90";

export const Toaster = {
  mounted() {
    this.defaultDuration = parseInt(this.el.dataset.duration || "5000", 10);
    this.fromTop = this.el.dataset.position?.startsWith("top");

    this.handleEvent("cognit:toast", (payload) => this.addToast(payload));
  },

  addToast({ kind = "default", title, description, duration, action }) {
    const card = document.createElement("div");
    card.className = `${BASE_CARD_CLASSES} ${KIND_CLASSES[kind] || KIND_CLASSES.default}`;
    card.setAttribute("role", "status");

    const row = document.createElement("div");
    row.className = "flex items-start gap-3";
    card.appendChild(row);

    const textWrap = document.createElement("div");
    textWrap.className = "flex flex-col gap-0.5 min-w-0";
    row.appendChild(textWrap);

    if (title) {
      const titleEl = document.createElement("p");
      titleEl.className = "text-sm font-medium";
      titleEl.textContent = title;
      textWrap.appendChild(titleEl);
    }

    if (description) {
      const descEl = document.createElement("p");
      descEl.className = "text-sm text-muted-foreground";
      descEl.textContent = description;
      textWrap.appendChild(descEl);
    }

    if (action && action.label && action.event) {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = ACTION_BUTTON_CLASSES;
      btn.textContent = action.label;
      btn.addEventListener("click", () => {
        this.pushEvent(action.event, action.params || {});
        this.dismiss(card);
      });
      row.appendChild(btn);
    }

    // Enter animation
    card.style.opacity = "0";
    card.style.transform = this.fromTop
      ? "translateY(-8px)"
      : "translateY(8px)";
    this.fromTop ? this.el.appendChild(card) : this.el.prepend(card);
    requestAnimationFrame(() => {
      card.style.opacity = "1";
      card.style.transform = "translateY(0)";
    });

    // Auto-dismiss with hover pause
    const totalMs = duration ?? this.defaultDuration;
    if (totalMs > 0) {
      let remaining = totalMs;
      let startedAt = Date.now();
      let timer = setTimeout(() => this.dismiss(card), remaining);

      card.addEventListener("mouseenter", () => {
        clearTimeout(timer);
        remaining -= Date.now() - startedAt;
      });
      card.addEventListener("mouseleave", () => {
        startedAt = Date.now();
        timer = setTimeout(() => this.dismiss(card), Math.max(remaining, 1000));
      });
      card._cognitTimer = () => clearTimeout(timer);
    }

    // Click anywhere on the card (outside the action) dismisses
    card.addEventListener("click", (e) => {
      if (e.target.closest("button")) return;
      this.dismiss(card);
    });
  },

  dismiss(card) {
    if (card._cognitDismissed) return;
    card._cognitDismissed = true;
    card._cognitTimer?.();
    card.style.opacity = "0";
    card.style.transform = this.fromTop
      ? "translateY(-8px)"
      : "translateY(8px)";
    setTimeout(() => card.remove(), 300);
  },

  destroyed() {
    this.el
      .querySelectorAll("div[role=status]")
      .forEach((c) => c._cognitTimer?.());
  },
};
