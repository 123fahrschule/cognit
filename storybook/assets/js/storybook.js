import Cognit from "cognit";

(function () {
  window.storybook = { Hooks: Cognit.Hooks };
  Cognit.Toaster.attach();
})();
