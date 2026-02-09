export const SidebarMenu = {
  mounted() {
    this.updateActiveItems();
  },

  updateActiveItems() {
    const currentPath = window.location.pathname;
    const allButtons = this.el.querySelectorAll(
      '[data-sidebar="menu-button"], [data-sidebar="menu-sub-button"]',
    );

    allButtons.forEach((button) => {
      const href = button.getAttribute("href");

      if (href && (currentPath === href || currentPath.startsWith(href + "/"))) {
        button.setAttribute("data-active", "true");
      } else {
        button.setAttribute("data-active", "false");
      }
    });

    this.openActiveCollapsibles();
  },

  openActiveCollapsibles() {
    const activeSubButtons = this.el.querySelectorAll(
      '[data-sidebar="menu-sub-button"][data-active="true"]',
    );

    activeSubButtons.forEach((button) => {
      const collapsible = button.closest('[data-component="collapsible"]');
      if (collapsible) {
        collapsible.setAttribute("data-state", "open");
      }
    });
  },
};
