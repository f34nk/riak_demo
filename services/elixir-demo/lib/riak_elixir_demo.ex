defmodule RiakElixirDemo do
  @moduledoc false

  @bucket "demo"
  @key "hello-elixir"

  @test_object %{
    "client" => "elixir",
    "message" => "Hello from OpenRiak"
  }

  def run do
    riak_host = System.get_env("RIAK_HOST", "openriak")
    riak_port = System.get_env("RIAK_PORT", "8098")
    base_url = "http://#{riak_host}:#{riak_port}"

    IO.puts("=== OpenRiak Elixir Demo ===")
    IO.puts("Using OpenRiak at #{base_url}")

    write_object(base_url, @bucket, @key, @test_object)
    result = read_object(base_url, @bucket, @key)

    IO.puts("Result: #{Jason.encode!(result, pretty: true)}")

    if result["message"] != @test_object["message"] do
      raise "Value mismatch after read!"
    end

    IO.puts("Demo complete: write and read verified.")
  end

  defp write_object(base_url, bucket, key, data) do
    url = "#{base_url}/buckets/#{bucket}/keys/#{key}?w=1&dw=1"

    %{status: status} =
      Req.put!(url,
        json: data,
        headers: %{"content-type" => "application/json"},
        receive_timeout: 10_000
      )

    IO.puts("Wrote object -> bucket='#{bucket}' key='#{key}' status=#{status}")
  end

  defp read_object(base_url, bucket, key) do
    url = "#{base_url}/buckets/#{bucket}/keys/#{key}"

    %{status: status, body: body} =
      Req.get!(url, receive_timeout: 10_000)

    IO.puts("Read object  <- bucket='#{bucket}' key='#{key}' status=#{status}")
    body
  end
end
