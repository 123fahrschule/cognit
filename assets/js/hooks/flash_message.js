export const FlashMessage = {
  timer: null,

  remove() {
    this.el.remove();
    clearTimeout(this.timer);
    this.liveSocket.execJS(this.el, this.el.getAttribute("phx-remove"));
  },

  mounted() {
    const type = this.el.dataset.type;

    if (type !== "error") {
      this.timer = setTimeout(() => {
        this.remove();
      }, 5_000);
    }
  },
};
