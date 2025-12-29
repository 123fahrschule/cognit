export const Sidebar = {
  mounted() {
    const sidebarRoot = this.el;

    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (
          mutation.type === "attributes" &&
          mutation.attributeName === "data-state"
        ) {
          const state = sidebarRoot.getAttribute("data-state");
          if (state) {
            this.saveSidebarState(state);
            this.handleTransition();
          }
        }
      });
    });

    observer.observe(sidebarRoot, {
      attributes: true,
      attributeFilter: ["data-state"],
    });

    this.observer = observer;
  },

  handleTransition() {
    const sidebarRoot = this.el;
    sidebarRoot.classList.add("is-transitioning");

    clearTimeout(this.transitionTimer);
    this.transitionTimer = setTimeout(() => {
      sidebarRoot.classList.remove("is-transitioning");
    }, 200);
  },

  saveSidebarState(state) {
    const EXPIRY_TIME_IN_DAYS = 365;

    const expiryDate = new Date();
    expiryDate.setTime(
      expiryDate.getTime() + EXPIRY_TIME_IN_DAYS * 24 * 60 * 60 * 1000,
    );
    const expires = "expires=" + expiryDate.toUTCString();
    document.cookie = `sidebar_state=${state};${expires};path=/`;
  },

  destroyed() {
    if (this.observer) {
      this.observer.disconnect();
    }
    clearTimeout(this.transitionTimer);
  },
};
