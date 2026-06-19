defmodule Demo.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    try do
      Demo.run()
      System.halt(0)
    rescue
      error ->
        IO.puts(Exception.format(:error, error, __STACKTRACE__))
        System.halt(1)
    end

    {:ok, self()}
  end
end
