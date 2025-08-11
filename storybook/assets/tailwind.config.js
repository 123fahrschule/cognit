// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");

module.exports = {
  important: ".cognit-storybook",
  presets: [require("../../assets/tailwind_preset.js")],
  content: ["../../lib/**/*.*ex", "../storybook/**/*.exs"],
};
