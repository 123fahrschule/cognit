export const SidebarMenu = {
  mounted() {
    this.updateActiveItems();
  },

  updated() {
    this.updateActiveItems();
  },

  updateActiveItems() {
    const currentPath = window.location.pathname;
    const allButtons = this.el.querySelectorAll(
      '[data-sidebar="menu-button"], [data-sidebar="menu-sub-button"]',
    );

    // Only the most specific (longest) matching href stays active, so a parent
    // like /admin doesn't light up on /admin/foo, and /admin/foo doesn't light
    // up on /admin/foo/baz when baz is its own nav item.
    let bestLength = -1;
    allButtons.forEach((button) => {
      const href = button.getAttribute("href");
      if (href && this.matchesPath(currentPath, href)) {
        bestLength = Math.max(bestLength, this.pathOf(href).length);
      }
    });

    allButtons.forEach((button) => {
      const href = button.getAttribute("href");
      const active =
        href &&
        this.pathOf(href).length === bestLength &&
        this.matchesPath(currentPath, href);
      button.setAttribute("data-active", active ? "true" : "false");
    });

    this.openActiveCollapsibles();
  },

  matchesPath(currentPath, href) {
    const path = this.pathOf(href);
    return currentPath === path || currentPath.startsWith(path + "/");
  },

  pathOf(href) {
    return href.split(/[?#]/)[0];
  },

  openActiveCollapsibles() {
    const activeSubButtons = this.el.querySelectorAll(
      '[data-sidebar="menu-sub-button"][data-active="true"]',
    );

    activeSubButtons.forEach((button) => {
      const collapsible = button.closest('[data-component="collapsible"]');
      if (collapsible) {
        collapsible.setAttribute("data-state", "open");

        const parentButton = collapsible.querySelector(
          '[data-sidebar="menu-button"]',
        );
        if (parentButton) {
          parentButton.setAttribute("data-active", "true");
        }
      }
    });
  },
};
