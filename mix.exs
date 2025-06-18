defmodule Cognit.MixProject do
  use Mix.Project

  def project do
    [
      app: :cognit,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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

      # Mishka Chelekom is a fully featured components and UI kit library for Phoenix & Phoenix LiveView
      {:mishka_chelekom, "~> 0.0.5", only: :dev}
    ]
  end
end
