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
          }
        }
      });
    });

    observer.observe(sidebarRoot, {
      attributes: true,
      attributeFilter: ["data-state"],
    });

    this.observer = observer;

    this.updateActiveItems();
  },

  updateActiveItems() {
    const currentPath = window.location.pathname;
    const menuButtons = this.el.querySelectorAll('[data-sidebar="menu-button"]');

    menuButtons.forEach((button) => {
      const href = button.getAttribute("href");

      if (href && currentPath.startsWith(href)) {
        button.setAttribute("data-active", "true");
      } else {
        button.setAttribute("data-active", "false");
      }
    });
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
  },
};
