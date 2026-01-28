defmodule Cognit.MixProject do
  use Mix.Project

  @version "0.1.5"

  def project do
    [
      app: :cognit,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {Cognit.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 1.0"},
      {:gettext, "~> 0.26 or ~> 1.0"},
      {:tw_merge, "~> 0.1"},
      {:jason, "~> 1.4"}
    ]
  end

  defp aliases do
    [
      check: [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "compile --force --warnings-as-errors"
      ],
      release: [
        "check",
        "cmd git tag #{@version}",
        "cmd git push",
        "cmd git push --tags"
      ]
    ]
  end
end
