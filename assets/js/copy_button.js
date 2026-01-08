window.addEventListener("cognit:copy", (event) => {
  let text;

  if (event.detail?.text) {
    text = event.detail.text;
  } else if (event.detail?.target) {
    const targetElement = document.querySelector(event.detail.target);
    if (!targetElement) {
      console.error(
        `Copy button: target element not found: ${event.detail.target}`,
      );
      return;
    }
    text = targetElement.value || targetElement.textContent;
  } else {
    text = event.target.value || event.target.textContent;
  }

  if (!text) {
    console.warn("Copy button: no text to copy");
    return;
  }

  if (!navigator.clipboard) {
    console.error(
      "Copy button: Clipboard API not available. Requires HTTPS or localhost.",
    );
    fallbackCopy(text);
    return;
  }

  navigator.clipboard
    .writeText(text)
    .then(() => {
      showCopyFeedback(event.target);
    })
    .catch((err) => {
      console.error("Failed to copy:", err);
      fallbackCopy(text);
    });
});

function showCopyFeedback(element) {
  const btn = element.closest("button[data-copy-feedback-target]") || element;
  const tooltip = btn.closest('[data-component="tooltip"]');

  if (!tooltip) {
    console.warn("Copy feedback tooltip not found");
    return;
  }

  tooltip.dispatchEvent(
    new CustomEvent("salad_ui:command", {
      detail: {
        command: "open",
        params: {},
      },
      bubbles: false,
    }),
  );

  setTimeout(() => {
    tooltip.dispatchEvent(
      new CustomEvent("salad_ui:command", {
        detail: {
          command: "close",
          params: {},
        },
        bubbles: false,
      }),
    );
  }, 2000);
}

function fallbackCopy(text) {
  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.style.position = "fixed";
  textarea.style.opacity = "0";
  document.body.appendChild(textarea);
  textarea.select();

  try {
    const successful = document.execCommand("copy");
    if (successful) {
      console.log("Fallback copy successful");
    } else {
      console.error("Fallback copy failed");
    }
  } catch (err) {
    console.error("Fallback copy error:", err);
  } finally {
    document.body.removeChild(textarea);
  }
}
