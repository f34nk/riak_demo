defmodule Demo do
  @moduledoc false

  alias OpenRiakClient
  alias OpenRiakTypes.PutDefaultObjectOperationInput
  alias OpenRiakTypes.GetDefaultObjectOperationInput

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
    config = %{base_url: base_url}

    IO.puts("=== OpenRiak Elixir Demo ===")
    IO.puts("Using OpenRiak at #{base_url}")

    :ok = write_object(config, @bucket, @key, @test_object)
    result = read_object(config, @bucket, @key)

    IO.puts("Result: #{Jason.encode!(result, pretty: true)}")

    if result["message"] != @test_object["message"] do
      raise "Value mismatch after read!"
    end

    IO.puts("Demo complete: write and read verified.")
  end

  defp write_object(config, bucket, key, data) do
    body = Jason.encode!(data)

    input = %PutDefaultObjectOperationInput{
      bucket: bucket,
      key: key,
      w: "1",
      dw: "1",
      content_type: "application/json",
      body: body
    }

    case OpenRiakClient.put_default_object(config, input) do
      {:ok, %{status_code: status}} when status in 200..299 ->
        IO.puts("Wrote object -> bucket='#{bucket}' key='#{key}' status=#{status}")
        :ok

      {:ok, %{status_code: status}} ->
        raise "put failed with status #{status}"

      {:error, reason} ->
        raise inspect(reason)
    end
  end

  defp read_object(config, bucket, key) do
    input = %GetDefaultObjectOperationInput{
      bucket: bucket,
      key: key
    }

    case OpenRiakClient.get_default_object(config, input) do
      {:ok, %{status_code: 200, body: body}} ->
        IO.puts("Read object  <- bucket='#{bucket}' key='#{key}' status=200")
        Jason.decode!(body)

      {:ok, %{status_code: status}} ->
        raise "get failed with status #{status}"

      {:error, reason} ->
        raise inspect(reason)
    end
  end
end
