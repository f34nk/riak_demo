defmodule Demo.MixProject do
  use Mix.Project

  def project do
    [
      app: :riak_elixir_demo,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Demo.Application, []}
    ]
  end

  defp elixirc_paths(:test),
    do: ["lib", "generated/source/elixir-client-codegen", "test"]

  defp elixirc_paths(_),
    do: ["lib", "generated/source/elixir-client-codegen"]

  defp deps do
    [
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"}
    ]
  end
end
