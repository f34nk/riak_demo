package openriak.protocol;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.nio.charset.StandardCharsets;
import openriak.current.api.model.GetDefaultObject;
import openriak.current.api.model.GetDefaultObjectOperationInput;
import openriak.current.api.model.GetDefaultObjectOutput;
import openriak.current.api.model.PutDefaultObject;
import openriak.current.api.model.PutDefaultObjectOperationInput;
import org.junit.jupiter.api.Test;
import software.amazon.smithy.java.context.Context;
import software.amazon.smithy.java.core.serde.TypeRegistry;
import software.amazon.smithy.java.http.api.HttpResponse;
import software.amazon.smithy.java.io.datastream.DataStream;
import software.amazon.smithy.java.io.uri.SmithyUri;

final class OpenRiakHttpProtocolTest {

    private final OpenRiakHttpProtocol protocol = new OpenRiakHttpProtocol();
    private final Context context = Context.create();
    private final SmithyUri endpoint = SmithyUri.of("http", "localhost", 8098, "/", null);

    @Test
    void putDefaultObjectBuildsExpectedHttpRequest() {
        byte[] json = "{\"client\":\"java\",\"message\":\"Hello from OpenRiak\"}".getBytes(StandardCharsets.UTF_8);

        PutDefaultObjectOperationInput input = PutDefaultObjectOperationInput.builder()
                .bucket("demo")
                .key("hello-java")
                .contentType("application/json")
                .w("1")
                .dw("1")
                .body(DataStream.ofBytes(json))
                .build();

        var request = protocol.createRequest(
                PutDefaultObject.instance(),
                input,
                context,
                endpoint);

        assertEquals("PUT", request.method());
        assertEquals("/buckets/demo/keys/hello-java", request.uri().getPath());
        assertEquals("w=1&dw=1", request.uri().getQuery());
        assertEquals("application/json", request.headers().firstValue("Content-Type"));
        assertNotNull(request.body());
    }

    @Test
    void getDefaultObjectBuildsExpectedHttpRequest() {
        GetDefaultObjectOperationInput input = GetDefaultObjectOperationInput.builder()
                .bucket("demo")
                .key("hello-java")
                .build();

        var request = protocol.createRequest(
                GetDefaultObject.instance(),
                input,
                context,
                endpoint);

        assertEquals("GET", request.method());
        assertEquals("/buckets/demo/keys/hello-java", request.uri().getPath());
        assertEquals(DataStream.ofEmpty(), request.body());
    }

    @Test
    void getDefaultObjectDeserializesSuccessResponse() throws Exception {
        byte[] json = "{\"client\":\"java\",\"message\":\"Hello from OpenRiak\"}".getBytes(StandardCharsets.UTF_8);

        GetDefaultObjectOperationInput input = GetDefaultObjectOperationInput.builder()
                .bucket("demo")
                .key("hello-java")
                .build();

        var request = protocol.createRequest(
                GetDefaultObject.instance(),
                input,
                context,
                endpoint);

        HttpResponse response = HttpResponse.create()
                .setStatusCode(200)
                .setHeader("Content-Type", "application/json")
                .setBody(DataStream.ofBytes(json))
                .toUnmodifiable();

        try (GetDefaultObjectOutput output = protocol.deserializeResponse(
                GetDefaultObject.instance(),
                context,
                TypeRegistry.empty(),
                request,
                response)) {
            assertEquals(200, output.getStatusCode());
            assertEquals("application/json", output.getContentType());
            assertNotNull(output.getBody());
            assertArrayEquals(json, output.getBody().asByteBuffer().array());
        }
    }
}
