import json

import pytest
from smithy_core import URI

from openriak.aio.protocols import OpenRiakHttpClientProtocol
from openriak.models import (
    GET_DEFAULT_OBJECT,
    PUT_DEFAULT_OBJECT,
    GetDefaultObjectOperationInput,
    PutDefaultObjectOperationInput,
)
from openriak._private.schemas import OPEN_RIAK


@pytest.fixture
def protocol() -> OpenRiakHttpClientProtocol:
    return OpenRiakHttpClientProtocol(OPEN_RIAK)


@pytest.fixture
def endpoint() -> URI:
    return URI(scheme="http", host="localhost", port=8098, path="/")


@pytest.mark.asyncio
async def test_put_default_object_request_shape(protocol, endpoint):
    payload = json.dumps({"client": "python", "message": "Hello from OpenRiak"}).encode()
    input_model = PutDefaultObjectOperationInput(
        bucket="demo",
        key="hello",
        content_type="application/json",
        w="1",
        dw="1",
        body=payload,
    )

    request = protocol.serialize_request(
        operation=PUT_DEFAULT_OBJECT,
        input=input_model,
        endpoint=endpoint,
        context={},
    )

    assert request.method == "PUT"
    assert request.destination.path == "/buckets/demo/keys/hello"
    assert request.destination.query == "w=1&dw=1"
    assert request.fields["Content-Type"].as_string() == "application/json"
    assert request.fields["content-length"].as_string() == str(len(payload))


@pytest.mark.asyncio
async def test_get_default_object_request_shape(protocol, endpoint):
    input_model = GetDefaultObjectOperationInput(bucket="demo", key="hello")

    request = protocol.serialize_request(
        operation=GET_DEFAULT_OBJECT,
        input=input_model,
        endpoint=endpoint,
        context={},
    )

    assert request.method == "GET"
    assert request.destination.path == "/buckets/demo/keys/hello"
    assert request.destination.query == ""
    assert list(request.fields) == []
