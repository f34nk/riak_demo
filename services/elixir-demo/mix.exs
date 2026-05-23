defmodule RiakElixirDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :riak_elixir_demo,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: false,
      deps: deps(),
      application: application()
    ]
  end

  defp application do
    [
      extra_applications: [:logger, :req],
      mod: {RiakElixirDemo.Application, []}
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"}
    ]
  end
end
