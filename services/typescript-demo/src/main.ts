import { OpenRiakClient, PutDefaultObjectCommand } from "@openriak/client";

const RIAK_HOST = process.env.RIAK_HOST ?? "openriak";
const RIAK_PORT = process.env.RIAK_PORT ?? "8098";
const endpoint = `http://${RIAK_HOST}:${RIAK_PORT}`;
const BASE_URL = endpoint;

const client = new OpenRiakClient({
  endpoint,
});

const BUCKET = "demo";
const KEY = "hello-typescript";

const TEST_OBJECT = {
  client: "typescript",
  message: "Hello from OpenRiak",
};

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

  const jsonBytes = new TextEncoder().encode(JSON.stringify(TEST_OBJECT));

  const putOutput = await client.send(
    new PutDefaultObjectCommand({
      bucket: BUCKET,
      key: KEY,
      contentType: "application/json",
      w: "1",
      dw: "1",
      body: jsonBytes,
    }),
  );

  console.log(
    `Wrote object -> bucket='${BUCKET}' key='${KEY}' status=${putOutput.statusCode}`,
  );

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
