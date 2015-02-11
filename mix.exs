defmodule Logic.Mixfile do
  use Mix.Project

  def project do
    [app: :logic,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :reprise, :dbg]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:zipper_tree, "~> 0.1.1"},
      {:reprise, "~> 0.3.0"},
      {:dbg, "~> 1.0.0"},
      {:ex_spec, "~> 0.3.0", only: :test}
    ]
  end
end
