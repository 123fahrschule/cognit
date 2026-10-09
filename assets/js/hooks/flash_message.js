const defaultDuration = 5_000;

export const FlashMessage = {
  timer: null,

  remove() {
    clearTimeout(this.timer);
    this.el.remove();
    this.liveSocket.execJS(this.el, this.el.getAttribute("phx-remove"));
  },

  mounted() {
    const ms = this.dismissAfter();

    if (ms > 0) {
      this.timer = setTimeout(() => this.remove(), ms);
    }
  },

  destroyed() {
    clearTimeout(this.timer);
  },

  // `data-duration` wins, including for errors. Without it, non-error flashes
  // still dismiss after 5s and errors stay until closed.
  dismissAfter() {
    const raw = this.el.dataset.duration;

    if (raw != null && raw !== "") {
      const ms = Number(raw);
      return Number.isFinite(ms) ? ms : 0;
    }

    return this.el.dataset.type === "error" ? 0 : defaultDuration;
  },
};
