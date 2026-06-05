import {
  GetDefaultObjectCommand,
  OpenRiakClient,
  PutDefaultObjectCommand,
} from "@openriak/client";

const RIAK_HOST = process.env.RIAK_HOST ?? "openriak";
const RIAK_PORT = process.env.RIAK_PORT ?? "8098";
const endpoint = `http://${RIAK_HOST}:${RIAK_PORT}`;

const client = new OpenRiakClient({
  endpoint,
});

const BUCKET = "demo";
const KEY = "hello-typescript";

const TEST_OBJECT = {
  client: "typescript",
  message: "Hello from OpenRiak",
};

async function main(): Promise<void> {
  console.log("=== OpenRiak TypeScript Demo ===");
  console.log(`Using OpenRiak at ${endpoint}`);

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

  const getOutput = await client.send(
    new GetDefaultObjectCommand({
      bucket: BUCKET,
      key: KEY,
    }),
  );

  console.log(
    `Read object  <- bucket='${BUCKET}' key='${KEY}' status=${getOutput.statusCode}`,
  );

  const bodyBytes = await getOutput.body!.transformToByteArray();
  const result = JSON.parse(new TextDecoder().decode(bodyBytes)) as Record<
    string,
    unknown
  >;
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
