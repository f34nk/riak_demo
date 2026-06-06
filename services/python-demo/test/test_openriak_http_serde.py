import json

import pytest

from openriak.models import GetDefaultObjectOperationInput, PutDefaultObjectOperationInput


@pytest.mark.asyncio
async def test_put_default_object_request_shape():
    payload = json.dumps({"client": "python", "message": "Hello from OpenRiak"}).encode()
    input_model = PutDefaultObjectOperationInput(
        bucket="demo",
        key="hello",
        content_type="application/json",
        w="1",
        dw="1",
        body=payload,
    )
    assert input_model.bucket == "demo"
    assert input_model.key == "hello"


@pytest.mark.asyncio
async def test_get_default_object_request_shape():
    input_model = GetDefaultObjectOperationInput(bucket="demo", key="hello")
    assert input_model.bucket == "demo"
    assert input_model.key == "hello"
