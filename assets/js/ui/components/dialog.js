// saladui/components/dialog.js
import Component from "../core/component";
import SaladUI from "../index";
import FocusTrap from "../core/focus-trap";
import ClickOutsideMonitor from "../core/click-outside";

let openDialogCount = 0;
let originalBodyOverflow = null;
let originalHtmlOverflow = null;

class DialogComponent extends Component {
  constructor(el, hookContext) {
    const initialState = el.dataset.state || "closed";
    super(el, { hookContext, initialState });

    // Initialize properties
    this.root = this.el;
    this.content = this.getPart("content");
    this.contentPanel = this.getPart("content-panel");
    this.config.preventDefaultKeys = ["Escape"];
    this.hasLockedScroll = false;

    this.setupEvents();

    // If starting in open state, lock scroll immediately
    if (initialState === "open") {
      if (openDialogCount === 0) {
        originalHtmlOverflow = document.documentElement.style.overflow;
        originalBodyOverflow = document.body.style.overflow;
        document.documentElement.style.overflow = "hidden";
        document.body.style.overflow = "hidden";
      }
      openDialogCount++;
      this.hasLockedScroll = true;
    }

    this.transition(this.el.dataset.open == "true" ? "open" : "close");
  }

  getComponentConfig() {
    return {
      stateMachine: {
        closed: {
          enter: "onClosedEnter",
          exit: "onClosedExit",
          transitions: {
            open: "open",
          },
        },
        open: {
          enter: "onOpenEnter",
          transitions: {
            close: "closed",
          },
        },
      },
      events: {
        closed: {
          keyMap: {},
        },
        open: {
          keyMap: {
            Escape: "close",
          },
        },
      },
      hiddenConfig: {
        closed: {
          content: true,
        },
        open: {
          content: false,
        },
      },
      ariaConfig: {
        content: {
          all: {
            role: "dialog",
          },
          open: {
            hidden: "false",
            modal: "true",
          },
          closed: {
            hidden: "true",
          },
        },
        "content-panel": {
          open: {
            labelledby: () => this.getPartId("title"),
            describedby: () => this.getPartId("description"),
          },
        },
        "close-trigger": {
          all: {
            label: "Close dialog",
          },
        },
      },
    };
  }

  // Setup component events
  setupComponentEvents() {
    super.setupComponentEvents();

    // Only setup click handler if closeOnOutsideClick is enabled
    if (this.options.closeOnOutsideClick) {
      this.setupOutsideClickDetection();
    }
  }

  setupOutsideClickDetection() {
    // Create click outside monitor to handle clicks on the overlay
    this.clickOutsideMonitor = new ClickOutsideMonitor(
      [this.contentPanel],
      (event) => {
        // Only close if click was directly on the content container (overlay area)
        if (
          event.target === this.content ||
          event.target.dataset.part === "overlay"
        ) {
          this.transition("close");
        }
      },
    );
  }

  // State machine handlers
  onClosedEnter() {
    // Clean up focus trap
    if (this.focusTrap) {
      this.focusTrap.deactivate();
    }

    // Clean up click outside monitor
    if (this.clickOutsideMonitor) {
      this.clickOutsideMonitor.stop();
    }

    // Restore body scroll when last dialog closes
    if (this.hasLockedScroll) {
      openDialogCount = Math.max(0, openDialogCount - 1);
      if (openDialogCount === 0) {
        if (originalHtmlOverflow !== null) {
          document.documentElement.style.overflow = originalHtmlOverflow;
          originalHtmlOverflow = null;
        }
        if (originalBodyOverflow !== null) {
          document.body.style.overflow = originalBodyOverflow;
          originalBodyOverflow = null;
        }
      }
      this.hasLockedScroll = false;
    }

    // Notify the server of the state change
    this.pushEvent("closed");
  }

  onClosedExit() {
    // Prevent body scroll when opening
    if (openDialogCount === 0) {
      originalHtmlOverflow = document.documentElement.style.overflow;
      originalBodyOverflow = document.body.style.overflow;
      document.documentElement.style.overflow = "hidden";
      document.body.style.overflow = "hidden";
    }
    openDialogCount++;
    this.hasLockedScroll = true;
  }

  onOpenEnter() {
    // Initialize focus trap if not already created
    this.el.focus();
    if (!this.focusTrap) {
      this.focusTrap = new FocusTrap(this.contentPanel);
    }

    // Activate focus trap
    this.focusTrap.activate();

    // Activate click outside monitor if enabled
    if (this.clickOutsideMonitor) {
      this.clickOutsideMonitor.start();
    }

    // Setup escape key handling - now handled by the component's keyMap

    // Notify the server of the state change
    this.pushEvent("opened");
  }

  beforeDestroy() {
    // If dialog has locked scroll, restore it
    if (this.hasLockedScroll) {
      openDialogCount = Math.max(0, openDialogCount - 1);
      if (openDialogCount === 0) {
        if (originalHtmlOverflow !== null) {
          document.documentElement.style.overflow = originalHtmlOverflow;
          originalHtmlOverflow = null;
        }
        if (originalBodyOverflow !== null) {
          document.body.style.overflow = originalBodyOverflow;
          originalBodyOverflow = null;
        }
      }
      this.hasLockedScroll = false;
    }

    // Clean up focus trap
    this.focusTrap?.destroy();
    this.focusTrap = null;

    // Clean up click outside monitor
    this.clickOutsideMonitor?.destroy();
    this.clickOutsideMonitor = null;
  }
}

// Register the component
SaladUI.register("dialog", DialogComponent);

export default DialogComponent;
