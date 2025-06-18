defmodule Cognit.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :cognit,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},

      # Mishka Chelekom is a fully featured components and UI kit library for Phoenix & Phoenix LiveView
      {:mishka_chelekom, "~> 0.0.5", only: :dev}
    ]
  end

  defp aliases do
    [
      release: [
        "cmd git tag #{@version}",
        "cmd git push",
        "cmd git push --tags"
      ]
    ]
  end
end
