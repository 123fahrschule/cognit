module.exports = {
  content: [
"../deps/salad_ui/lib/**/*.ex",],
  theme: {
    extend: {
      colors: require("./tailwind.colors.json"),},
  },
  plugins: [
    require("./vendor/tailwindcss-animate"),],
};
