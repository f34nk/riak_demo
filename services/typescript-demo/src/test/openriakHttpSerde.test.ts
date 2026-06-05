import assert from "node:assert/strict";
import { createRequire } from "node:module";
import { before, describe, it } from "node:test";
import { fileURLToPath } from "node:url";

import type { GetDefaultObjectCommandInput, PutDefaultObjectCommandInput } from "@openriak/client";
import type { SerdeContext } from "@smithy/types";

type HttpRequestShape = {
  method: string;
  path: string;
  query: Record<string, string>;
  headers: Record<string, string>;
  body?: unknown;
};

type PutSerde = (input: PutDefaultObjectCommandInput, context: SerdeContext) => Promise<HttpRequestShape>;
type GetSerde = (input: GetDefaultObjectCommandInput, context: SerdeContext) => Promise<HttpRequestShape>;

const require = createRequire(fileURLToPath(import.meta.url));
const protocolModule = Promise.resolve(
  require("@openriak/client/dist-cjs/protocols/Openriakhttp.js") as {
    se_PutDefaultObjectCommand: PutSerde;
    se_GetDefaultObjectCommand: GetSerde;
  },
);

let se_PutDefaultObjectCommand: PutSerde;
let se_GetDefaultObjectCommand: GetSerde;

const TEST_ENDPOINT = {
  protocol: "http:",
  hostname: "localhost",
  port: 8098,
  path: "/",
};

function testContext(): SerdeContext {
  return {
    endpoint: async () => TEST_ENDPOINT,
    base64Decoder: (value: string) => Buffer.from(value, "base64"),
    base64Encoder: (value: Uint8Array) => Buffer.from(value).toString("base64"),
    utf8Decoder: (value: Uint8Array | string) => {
      if (typeof value === "string") {
        return value;
      }
      return new TextDecoder().decode(value);
    },
    utf8Encoder: (value: string) => new TextEncoder().encode(value),
    streamCollector: async (stream: unknown) => {
      const chunks: Uint8Array[] = [];
      for await (const chunk of stream as AsyncIterable<Uint8Array>) {
        chunks.push(chunk);
      }
      return Buffer.concat(chunks);
    },
    requestHandler: {} as SerdeContext["requestHandler"],
    disableHostPrefix: false,
  } as unknown as SerdeContext;
}

describe("OpenRiak HTTP serde", () => {
  before(async () => {
    const protocol = await protocolModule;
    se_PutDefaultObjectCommand = protocol.se_PutDefaultObjectCommand as PutSerde;
    se_GetDefaultObjectCommand = protocol.se_GetDefaultObjectCommand as GetSerde;
  });

  it("PutDefaultObject builds expected HTTP request", async () => {
    const json = new TextEncoder().encode(
      JSON.stringify({ client: "typescript", message: "Hello from OpenRiak" }),
    );

    const input: PutDefaultObjectCommandInput = {
      bucket: "demo",
      key: "hello-typescript",
      contentType: "application/json",
      w: "1",
      dw: "1",
      body: json,
    };

    const request = await se_PutDefaultObjectCommand(input, testContext());

    assert.equal(request.method, "PUT");
    assert.equal(request.path, "/buckets/demo/keys/hello-typescript");
    assert.deepEqual(request.query, { w: "1", dw: "1" });
    assert.equal(request.headers["content-type"], "application/json");
    assert.notEqual(request.body, undefined);
  });

  it("GetDefaultObject builds expected HTTP request", async () => {
    const input: GetDefaultObjectCommandInput = {
      bucket: "demo",
      key: "hello-typescript",
    };

    const request = await se_GetDefaultObjectCommand(input, testContext());

    assert.equal(request.method, "GET");
    assert.equal(request.path, "/buckets/demo/keys/hello-typescript");
    assert.deepEqual(request.query, {});
    assert.equal(request.body, undefined);
  });
});
