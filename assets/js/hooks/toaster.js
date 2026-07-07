export const Toaster = {
  mounted() {
    this.defaultDuration = parseInt(this.el.dataset.duration || "4000", 10);
    this.fromTop = this.el.dataset.position?.startsWith("top");

    this.handleEvent("cognit:toast", (payload) => this.addToast(payload));
  },

  addToast({ html, duration }) {
    const wrapper = document.createElement("div");
    wrapper.innerHTML = html.trim();
    const card = wrapper.firstElementChild;
    if (!card) return;

    // The action button already carries a real `phx-click` binding (rendered
    // server-side), so LiveView's own delegated click handling runs it. We
    // only need to dismiss the card afterwards.
    card
      .querySelector("button[phx-click]")
      ?.addEventListener("click", () => this.dismiss(card));

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
      .querySelectorAll('div[role="status"]')
      .forEach((c) => c._cognitTimer?.());
  },
};
