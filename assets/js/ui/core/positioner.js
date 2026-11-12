// saladui/core/positioner.js - Updated to use fixed positioning
/**
 * Core Positioning utility for SaladUI components
 * Handles pure positioning calculations without side effects
 */
const OPPOSITE_SIDE = {
  top: "bottom",
  right: "left",
  bottom: "top",
  left: "right",
};

class Positioner {
  /**
   * Calculate position for an element relative to a reference element
   *
   * @param {HTMLElement} element - The element to position
   * @param {HTMLElement} reference - The reference element to position against
   * @param {Object} options - Positioning options
   * @returns {Object} The computed position data
   */
  static calculate(element, reference, options = {}) {
    const {
      placement = "bottom",
      alignment = "center",
      container = document.body,
      flip = true,
      alignOffset = 0,
      sideOffset = 8,
    } = options;

    // Get element and reference rects for positioning
    const referenceRect = reference.getBoundingClientRect();
    const elementRect = {
      width: element.offsetWidth,
      height: element.offsetHeight,
    };

    // Find container bounds
    let containerRect;
    if (container === document.body) {
      containerRect = this.getClippingRect(element);
    } else {
      containerRect = container.getBoundingClientRect();
    }

    const positionFor = (side) =>
      this.getBasePosition(
        side,
        alignment,
        elementRect,
        referenceRect,
        alignOffset,
        sideOffset,
      );

    const actualPlacement = flip
      ? this.choosePlacement(placement, elementRect, containerRect, positionFor)
      : placement;
    const { x, y } = positionFor(actualPlacement);

    return {
      x,
      y,
      placement: actualPlacement,
    };
  }

  /**
   * Apply position to an element
   * @param {HTMLElement} element - Element to position
   * @param {number} x - X coordinate
   * @param {number} y - Y coordinate
   */
  static applyPosition(element, x, y) {
    element.style.position = "fixed";

    const containingBlock = this.getContainingBlock(element);
    if (containingBlock) {
      const rect = containingBlock.getBoundingClientRect();
      x -= rect.left;
      y -= rect.top;
    }

    element.style.top = y + "px";
    element.style.left = x + "px";
    element.style.margin = "0";
  }

  /**
   * The viewport narrowed by every overflow-clipping ancestor from the
   * containing block up. A fixed element escapes overflow clipping unless a
   * transformed ancestor (e.g. an open mobile drawer) contains it.
   */
  static getClippingRect(element) {
    const rect = {
      top: 0,
      right: window.innerWidth,
      bottom: window.innerHeight,
      left: 0,
    };

    for (
      let ancestor = this.getContainingBlock(element);
      ancestor && ancestor !== document.body;
      ancestor = ancestor.parentElement
    ) {
      const style = window.getComputedStyle(ancestor);
      if (style.overflowX === "visible" && style.overflowY === "visible") {
        continue;
      }

      const clip = ancestor.getBoundingClientRect();
      rect.top = Math.max(rect.top, clip.top);
      rect.right = Math.min(rect.right, clip.right);
      rect.bottom = Math.min(rect.bottom, clip.bottom);
      rect.left = Math.max(rect.left, clip.left);
    }

    rect.width = rect.right - rect.left;
    rect.height = rect.bottom - rect.top;
    return rect;
  }

  static getContainingBlock(element) {
    let parent = element.parentElement;
    while (parent && parent !== document.documentElement) {
      const style = window.getComputedStyle(parent);
      if (
        style.transform !== "none" ||
        style.perspective !== "none" ||
        style.filter !== "none" ||
        style.willChange === "transform" ||
        style.willChange === "perspective" ||
        style.willChange === "filter"
      ) {
        return parent;
      }
      parent = parent.parentElement;
    }
    return null;
  }

  /**
   * Calculate base position based on placement and alignment
   */
  static getBasePosition(
    placement,
    alignment,
    elementRect,
    referenceRect,
    alignOffset = 0,
    sideOffset = 8,
  ) {
    let x = 0;
    let y = 0;

    // Position based on placement
    switch (placement) {
      case "top":
        y = referenceRect.top - elementRect.height - sideOffset;
        break;
      case "right":
        x = referenceRect.right + sideOffset;
        y = referenceRect.top;
        break;
      case "bottom":
        y = referenceRect.bottom + sideOffset;
        break;
      case "left":
        x = referenceRect.left - elementRect.width - sideOffset;
        y = referenceRect.top;
        break;
    }

    // Adjust based on alignment
    switch (alignment) {
      case "start":
        if (placement === "top" || placement === "bottom") {
          x = referenceRect.left + alignOffset;
        } else {
          y = referenceRect.top + alignOffset;
        }
        break;
      case "center":
        if (placement === "top" || placement === "bottom") {
          x =
            referenceRect.left +
            referenceRect.width / 2 -
            elementRect.width / 2 +
            alignOffset;
        } else {
          y =
            referenceRect.top +
            referenceRect.height / 2 -
            elementRect.height / 2 +
            alignOffset;
        }
        break;
      case "end":
        if (placement === "top" || placement === "bottom") {
          x = referenceRect.right - elementRect.width + alignOffset;
        } else {
          y = referenceRect.bottom - elementRect.height + alignOffset;
        }
        break;
    }

    return { x, y };
  }

  /**
   * Pick the first side with room: the requested one, its opposite, then —
   * for left/right, e.g. a menu inside a full-width mobile drawer — below or
   * above. With no room anywhere, the side that overflows least wins.
   */
  static choosePlacement(placement, elementRect, containerRect, positionFor) {
    const opposite = OPPOSITE_SIDE[placement];
    if (!opposite) return placement;

    const candidates =
      placement === "left" || placement === "right"
        ? [placement, opposite, "bottom", "top"]
        : [placement, opposite];

    const overflow = (side) =>
      this.overflowOnSide(side, positionFor(side), elementRect, containerRect);

    return (
      candidates.find((side) => overflow(side) <= 0) ||
      (overflow(placement) <= overflow(opposite) ? placement : opposite)
    );
  }

  static overflowOnSide(side, { x, y }, { width, height }, containerRect) {
    switch (side) {
      case "top":
        return containerRect.top - y;
      case "right":
        return x + width - containerRect.right;
      case "bottom":
        return y + height - containerRect.bottom;
      case "left":
        return containerRect.left - x;
    }
  }

  /**
   * Utility method to find all scrollable parent elements
   */
  static findScrollableParents(element) {
    const scrollableParents = [];
    let currentElement = element;

    while (currentElement && currentElement !== document.body) {
      const style = window.getComputedStyle(currentElement);
      if (
        style.overflow === "auto" ||
        style.overflow === "scroll" ||
        style.overflowX === "auto" ||
        style.overflowX === "scroll" ||
        style.overflowY === "auto" ||
        style.overflowY === "scroll"
      ) {
        scrollableParents.push(currentElement);
      }
      currentElement = currentElement.parentElement;
    }

    // Always include window for global scrolling
    scrollableParents.push(window);

    return scrollableParents;
  }
}

export default Positioner;
