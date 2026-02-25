export const Pagination = {
  mounted() {
    this.submitting = false;

    this.el.addEventListener("pagination:navigate", (e) => {
      const { page, page_size } = e.detail;
      this.handleChange(page, page_size);
    });

    this.el.addEventListener("change", (e) => {
      const form = e.target.closest("form");
      if (!form) return;

      const formData = new FormData(form);
      const page = parseInt(formData.get("page")) || 1;
      const pageSize = parseInt([...formData.getAll("page_size")].pop());

      if (Number.isFinite(pageSize)) {
        this.handleChange(page, pageSize);
      }
    });
  },

  handleChange(page, pageSize) {
    const event = this.el.dataset.onChange;

    if (event) {
      const target = this.el.dataset.target;
      this.pushEventTo(target || this.el, event, {
        page: page,
        page_size: pageSize,
      });
    } else {
      this.patchUrl(page, pageSize);
    }
  },

  patchUrl(page, pageSize) {
    if (this.submitting) return;
    this.submitting = true;

    const url = new URL(window.location.href);

    if (Number.isFinite(page)) url.searchParams.set("page", page);
    if (Number.isFinite(pageSize)) url.searchParams.set("page_size", pageSize);

    this.liveSocket.js().patch(url.toString());

    setTimeout(() => {
      this.submitting = false;
    }, 100);
  },
};
