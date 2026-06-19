defmodule OpenriakHttpCodecTest do
  use ExUnit.Case, async: true

  alias OpenRiakHttp
  alias OpenRiakTypes.PutDefaultObjectOperationInput
  alias OpenRiakTypes.GetDefaultObjectOperationInput
  alias RuntimeTypes.HttpRequest

  test "PutDefaultObject builds expected HTTP request" do
    body = ~s({"client":"elixir","message":"Hello from OpenRiak"})

    input = %PutDefaultObjectOperationInput{
      bucket: "demo",
      key: "hello-elixir",
      w: "1",
      dw: "1",
      content_type: "application/json",
      body: body
    }

    req = OpenRiakHttp.encode_put_default_object_request(input)

    assert %HttpRequest{
             method: "PUT",
             path: "/buckets/demo/keys/hello-elixir",
             query: %{"w" => "1", "dw" => "1"},
             headers: [{"Content-Type", "application/json"}],
             body: ^body
           } = req
  end

  test "GetDefaultObject builds expected HTTP request" do
    input = %GetDefaultObjectOperationInput{
      bucket: "demo",
      key: "hello-elixir"
    }

    req = OpenRiakHttp.encode_get_default_object_request(input)

    assert %HttpRequest{
             method: "GET",
             path: "/buckets/demo/keys/hello-elixir",
             query: %{},
             headers: [],
             body: ""
           } = req
  end
end
