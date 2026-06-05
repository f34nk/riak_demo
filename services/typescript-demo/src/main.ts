const RIAK_HOST = process.env.RIAK_HOST ?? "openriak";
const RIAK_PORT = process.env.RIAK_PORT ?? "8098";
const BASE_URL = `http://${RIAK_HOST}:${RIAK_PORT}`;

const BUCKET = "demo";
const KEY = "hello-typescript";

const TEST_OBJECT = {
  client: "typescript",
  message: "Hello from OpenRiak",
};

async function writeObject(
  bucket: string,
  key: string,
  data: Record<string, string>,
): Promise<void> {
  const url = `${BASE_URL}/buckets/${bucket}/keys/${key}?w=1&dw=1`;
  const response = await fetch(url, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
    signal: AbortSignal.timeout(10_000),
  });
  if (!response.ok) {
    throw new Error(`PUT failed with status ${response.status}`);
  }
  console.log(
    `Wrote object -> bucket='${bucket}' key='${key}' status=${response.status}`,
  );
}

async function readObject(
  bucket: string,
  key: string,
): Promise<Record<string, unknown>> {
  const url = `${BASE_URL}/buckets/${bucket}/keys/${key}`;
  const response = await fetch(url, {
    signal: AbortSignal.timeout(10_000),
  });
  if (!response.ok) {
    throw new Error(`GET failed with status ${response.status}`);
  }
  console.log(
    `Read object  <- bucket='${bucket}' key='${key}' status=${response.status}`,
  );
  return (await response.json()) as Record<string, unknown>;
}

async function main(): Promise<void> {
  console.log("=== OpenRiak TypeScript Demo ===");
  console.log(`Using OpenRiak at ${BASE_URL}`);

  await writeObject(BUCKET, KEY, TEST_OBJECT);

  const result = await readObject(BUCKET, KEY);
  console.log(`Result: ${JSON.stringify(result, null, 2)}`);

  if (result.message !== TEST_OBJECT.message) {
    throw new Error("Value mismatch after read!");
  }

  console.log("Demo complete: write and read verified.");
}

main().catch((error: unknown) => {
  console.error(error);
  process.exit(1);
});
