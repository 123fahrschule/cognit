export const SidebarMenu = {
  mounted() {
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
};
