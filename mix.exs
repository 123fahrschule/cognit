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
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 1.0"},
      {:gettext, "~> 0.26 or ~> 1.0"},
      {:tw_merge, "~> 0.1"},

      # A collection of Live View components inspired by shadcn
      {:salad_ui, "~> 1.0.0-beta.3", only: :dev}
    ]
  end
end
