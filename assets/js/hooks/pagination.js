export const Pagination = {
  mounted() {
    this.submitting = false;

    this.el.addEventListener("pagination:navigate", (e) => {
      const { page, page_size } = e.detail;
      this.patchUrl(page, page_size);
    });

    this.el.querySelectorAll("select[data-pagination-select]").forEach((el) => {
      el.addEventListener("change", () => {
        const pageSize = parseInt(el.value);
        if (Number.isFinite(pageSize)) {
          this.patchUrl(1, pageSize);
        }
      });
    });
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
