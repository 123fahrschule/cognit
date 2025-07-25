// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

module.exports = {
  theme: {
    extend: {
      colors: require("./tailwind.colors.json"),
      fontFamily: {
        sans: ["Open Sans", "sans-serif"],
      },
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("./vendor/tailwindcss-animate"),
  ],
};
