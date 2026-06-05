package demo;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Map;
import java.util.Objects;
import openriak.current.api.client.OpenRiakClient;
import openriak.current.api.model.PutDefaultObjectOperationInput;
import openriak.current.api.model.PutDefaultObjectOutput;
import openriak.protocol.OpenRiakHttpProtocol;
import software.amazon.smithy.java.io.datastream.DataStream;

public final class Main {

    private static final String RIAK_HOST = env("RIAK_HOST", "openriak");
    private static final String RIAK_PORT = env("RIAK_PORT", "8098");

    private static final String BUCKET = "demo";
    private static final String KEY = "hello-java";

    private static final Gson GSON = new Gson();
    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    private static final Map<String, Object> TEST_OBJECT = Map.of(
            "client", "java",
            "message", "Hello from OpenRiak"
    );

    public static void main(String[] args) {
        try {
            System.out.println("=== OpenRiak Java Demo ===");

            URI endpoint = URI.create("http://" + RIAK_HOST + ":" + RIAK_PORT);
            OpenRiakClient client = OpenRiakClient.builder()
                    .configBuilder()
                        .endpoint(endpoint)
                        .protocol(new OpenRiakHttpProtocol())
                    .build()
                    .build();
            System.out.println("Using OpenRiak at " + endpoint);

            byte[] jsonBytes = GSON.toJson(TEST_OBJECT).getBytes(StandardCharsets.UTF_8);
            try (PutDefaultObjectOperationInput putInput = PutDefaultObjectOperationInput.builder()
                    .bucket(BUCKET)
                    .key(KEY)
                    .contentType("application/json")
                    .w("1")
                    .dw("1")
                    .body(DataStream.ofBytes(jsonBytes))
                    .build()) {
                PutDefaultObjectOutput putOutput = client.putDefaultObject(putInput);
                System.out.printf(
                        "Wrote object -> bucket='%s' key='%s' status=%d%n",
                        BUCKET,
                        KEY,
                        putOutput.getStatusCode());
            }

            JsonObject result = readObject(BUCKET, KEY);
            System.out.println("Result: " + GSON.toJson(result));

            String message = result.get("message").getAsString();
            if (!Objects.equals(message, TEST_OBJECT.get("message"))) {
                throw new IllegalStateException("Value mismatch after read!");
            }

            System.out.println("Demo complete: write and read verified.");
            System.exit(0);
        } catch (Exception e) {
            System.err.println(e.getMessage());
            e.printStackTrace(System.err);
            System.exit(1);
        }
    }

    private static JsonObject readObject(String bucket, String key) throws Exception {
        String baseUrl = "http://" + RIAK_HOST + ":" + RIAK_PORT;
        String url = baseUrl + "/buckets/" + bucket + "/keys/" + key;
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(10))
                .GET()
                .build();

        HttpResponse<String> response = HTTP.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IllegalStateException("GET failed with status " + response.statusCode());
        }
        System.out.printf("Read object  <- bucket='%s' key='%s' status=%d%n", bucket, key, response.statusCode());
        return GSON.fromJson(response.body(), JsonObject.class);
    }

    private static String env(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }
}
