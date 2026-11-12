import FocusTrap from "../ui/core/focus-trap.js";

const DESKTOP = "(min-width: 768px)";

// Links inside a closed collapsible match the focusable selector but can't
// take focus, which would break the Tab wrap at the end of the drawer.
class VisibleFocusTrap extends FocusTrap {
  getFocusableElements() {
    return super
      .getFocusableElements()
      .filter((element) => element.getClientRects().length > 0);
  }
}

export const Sidebar = {
  mounted() {
    this.media = window.matchMedia(DESKTOP);
    this.panel = this.el.querySelector('[data-sidebar="panel"]');
    this.trap = new VisibleFocusTrap(this.panel);

    this.onToggle = () => this.toggle();
    this.onClose = () => this.setMobileOpen(false);
    this.onSync = () => this.syncExpanded();
    this.onKeydown = (event) => {
      // Menus inside the drawer mark their own Escape handled without stopping it.
      if (event.key === "Escape" && !event.defaultPrevented) {
        this.setMobileOpen(false);
      }
    };
    this.onMediaChange = () => {
      this.syncCollapsible();
      if (this.media.matches) this.setMobileOpen(false);
      this.syncExpanded();
    };

    this.el.addEventListener("cognit:sidebar:toggle", this.onToggle);
    this.el.addEventListener("cognit:sidebar:close", this.onClose);
    this.el.addEventListener("cognit:sidebar:sync", this.onSync);
    this.overlay().addEventListener("click", this.onClose);
    document.addEventListener("keydown", this.onKeydown);
    window.addEventListener("phx:page-loading-stop", this.onClose);
    this.media.addEventListener("change", this.onMediaChange);

    // data-collapsible is ignored on patch, so a server change to the mode arrives only here.
    this.observer = new MutationObserver((mutations) => {
      if (mutations.some((mutation) => mutation.attributeName === "data-state")) {
        this.saveSidebarState(this.el.getAttribute("data-state"));
        this.handleTransition();
      }
      this.syncCollapsible();
      this.syncExpanded();
    });
    this.observer.observe(this.el, {
      attributes: true,
      attributeFilter: ["data-state", "data-collapsible-mode"],
    });

    this.syncCollapsible();
    this.syncExpanded();
  },

  overlay() {
    return this.el.querySelector('[data-sidebar="overlay"]');
  },

  isMobileOpen() {
    return this.el.getAttribute("data-mobile") === "open";
  },

  toggle() {
    if (this.media.matches) {
      const next =
        this.el.getAttribute("data-state") === "collapsed"
          ? "expanded"
          : "collapsed";
      this.el.setAttribute("data-state", next);
    } else {
      this.setMobileOpen(!this.isMobileOpen());
    }
  },

  setMobileOpen(open) {
    if (open === this.isMobileOpen()) return;

    this.el.setAttribute("data-mobile", open ? "open" : "closed");

    if (open) {
      this.panel.setAttribute("role", "dialog");
      this.panel.setAttribute("aria-modal", "true");
      this.panel.setAttribute("aria-label", this.panel.dataset.dialogLabel);
      this.trap.activate();
    } else {
      this.panel.removeAttribute("role");
      this.panel.removeAttribute("aria-modal");
      this.panel.removeAttribute("aria-label");
      this.trap.deactivate();
    }

    this.syncExpanded();
  },

  // Icon-collapse styles key off data-collapsible; the drawer must always
  // render expanded, so the attribute is derived from state and viewport.
  syncCollapsible() {
    const collapsed = this.el.getAttribute("data-state") === "collapsed";
    const mode = this.el.getAttribute("data-collapsible-mode");
    this.el.setAttribute(
      "data-collapsible",
      collapsed && this.media.matches ? mode : "none",
    );
  },

  syncExpanded() {
    const expanded = this.media.matches
      ? this.el.getAttribute("data-state") !== "collapsed"
      : this.isMobileOpen();

    this.triggers().forEach((trigger) => {
      trigger.setAttribute("aria-controls", this.panel.id);
      trigger.setAttribute("aria-expanded", String(expanded));
    });
  },

  // Set here, not server-side: a sidebar with collapsible="none" has no panel to point at.
  triggers() {
    return document.querySelectorAll(`[data-sidebar-target="${this.el.id}"]`);
  },

  handleTransition() {
    this.el.classList.add("is-transitioning");

    clearTimeout(this.transitionTimer);
    this.transitionTimer = setTimeout(() => {
      this.el.classList.remove("is-transitioning");
    }, 200);
  },

  saveSidebarState(state) {
    if (!state) return;
    const EXPIRY_TIME_IN_DAYS = 365;

    const expiryDate = new Date();
    expiryDate.setTime(
      expiryDate.getTime() + EXPIRY_TIME_IN_DAYS * 24 * 60 * 60 * 1000,
    );
    const expires = "expires=" + expiryDate.toUTCString();
    document.cookie = `sidebar_state=${state};${expires};path=/`;
  },

  destroyed() {
    this.triggers().forEach((trigger) => {
      trigger.removeAttribute("aria-controls");
      trigger.removeAttribute("aria-expanded");
    });
    this.observer?.disconnect();
    this.trap?.destroy();
    clearTimeout(this.transitionTimer);
    document.removeEventListener("keydown", this.onKeydown);
    window.removeEventListener("phx:page-loading-stop", this.onClose);
    this.media?.removeEventListener("change", this.onMediaChange);
  },
};
