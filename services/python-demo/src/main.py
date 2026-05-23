import json
import os
import sys
import time

import requests

RIAK_HOST = os.environ.get("RIAK_HOST", "riak")
RIAK_PORT = os.environ.get("RIAK_PORT", "8098")
BASE_URL = f"http://{RIAK_HOST}:{RIAK_PORT}"

BUCKET = "demo"
KEY = "hello"

TEST_OBJECT = {
    "client": "python",
    "message": "Hello from OpenRiak",
    "timestamp": time.time(),
}


def kv_vnodes_ready() -> bool:
    url = f"{BASE_URL}/stats?timeout=2000"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code != 200:
            return False
        stats = response.json()
        running = stats.get("riak_kv_vnodes_running", 0)
        partitions = stats.get("ring_num_partitions", 0)
        return partitions > 0 and running >= partitions
    except (requests.exceptions.RequestException, ValueError):
        return False


def wait_for_riak(retries: int = 60, delay: float = 2.0) -> None:
    url = f"{BASE_URL}/ping"
    for attempt in range(1, retries + 1):
        try:
            response = requests.get(url, timeout=3)
            if response.status_code == 200:
                break
        except requests.exceptions.ConnectionError:
            pass
        print(f"Waiting for OpenRiak ... attempt {attempt}/{retries}")
        time.sleep(delay)
    else:
        print("ERROR: OpenRiak did not become ready in time.", file=sys.stderr)
        sys.exit(1)

    for attempt in range(1, retries + 1):
        if kv_vnodes_ready():
            print(f"OpenRiak is ready ({url})")
            return
        print(f"Waiting for KV vnodes ... attempt {attempt}/{retries}")
        time.sleep(delay)

    print("ERROR: OpenRiak KV vnodes did not become ready in time.", file=sys.stderr)
    sys.exit(1)


def write_object(bucket: str, key: str, data: dict) -> None:
    url = f"{BASE_URL}/buckets/{bucket}/keys/{key}?w=1&dw=1"
    response = requests.put(
        url,
        data=json.dumps(data),
        headers={"Content-Type": "application/json"},
        timeout=10,
    )
    response.raise_for_status()
    print(f"Wrote object -> bucket={bucket!r} key={key!r} status={response.status_code}")


def read_object(bucket: str, key: str) -> dict:
    url = f"{BASE_URL}/buckets/{bucket}/keys/{key}"
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    print(f"Read object  <- bucket={bucket!r} key={key!r} status={response.status_code}")
    return response.json()


def main() -> None:
    print("=== OpenRiak Python Demo ===")
    wait_for_riak()

    write_object(BUCKET, KEY, TEST_OBJECT)

    result = read_object(BUCKET, KEY)
    print(f"Result: {json.dumps(result, indent=2)}")

    assert result["message"] == TEST_OBJECT["message"], "Value mismatch after read!"
    print("Demo complete: write and read verified.")


if __name__ == "__main__":
    main()
