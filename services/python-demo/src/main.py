import asyncio
import json
import os

from openriak.client import OpenRiak
from openriak.config import Config
from openriak.models import GetDefaultObjectOperationInput, PutDefaultObjectOperationInput

RIAK_HOST = os.environ.get("RIAK_HOST", "openriak")
RIAK_PORT = os.environ.get("RIAK_PORT", "8098")

BUCKET = "demo"
KEY = "hello"

TEST_OBJECT = {
    "client": "python",
    "message": "Hello from OpenRiak",
}


async def main() -> None:
    endpoint = f"http://{RIAK_HOST}:{RIAK_PORT}"
    print("=== OpenRiak Python Demo ===")
    print(f"Using OpenRiak at {endpoint}")

    config = Config(endpoint_uri=endpoint)
    client = OpenRiak(config)

    json_bytes = json.dumps(TEST_OBJECT).encode("utf-8")

    put_output = await client.put_default_object(
        PutDefaultObjectOperationInput(
            bucket=BUCKET,
            key=KEY,
            content_type="application/json",
            w="1",
            dw="1",
            body=json_bytes,
        )
    )
    print(
        f"Wrote object -> bucket={BUCKET!r} key={KEY!r} "
        f"status={put_output.status_code}"
    )

    get_output = await client.get_default_object(
        GetDefaultObjectOperationInput(
            bucket=BUCKET,
            key=KEY,
        )
    )
    print(
        f"Read object  <- bucket={BUCKET!r} key={KEY!r} "
        f"status={get_output.status_code}"
    )

    body_bytes = await get_output.body.read()
    result = json.loads(body_bytes.decode("utf-8"))
    print(f"Result: {json.dumps(result, indent=2)}")

    assert result["message"] == TEST_OBJECT["message"], "Value mismatch after read!"
    print("Demo complete: write and read verified.")


if __name__ == "__main__":
    asyncio.run(main())
