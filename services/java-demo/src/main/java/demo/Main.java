package demo;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.Objects;
import openriak.v3_4.api.client.OpenRiakClient;
import openriak.v3_4.api.model.GetDefaultObjectOperationInput;
import openriak.v3_4.api.model.GetDefaultObjectOutput;
import openriak.v3_4.api.model.PutDefaultObjectOperationInput;
import openriak.v3_4.api.model.PutDefaultObjectOutput;
import openriak.protocol.OpenRiakHttpProtocol;
import software.amazon.smithy.java.auth.api.identity.IdentityResolver;
import software.amazon.smithy.java.auth.api.identity.IdentityResult;
import software.amazon.smithy.java.auth.api.identity.LoginIdentity;
import software.amazon.smithy.java.context.Context;
import software.amazon.smithy.java.io.datastream.DataStream;

public final class Main {

    private static final String RIAK_HOST = env("RIAK_HOST", "openriak");
    private static final String RIAK_PORT = env("RIAK_PORT", "8098");

    private static final String BUCKET = "demo";
    private static final String KEY = "hello-java";

    private static final Gson GSON = new Gson();

    private static final Map<String, Object> TEST_OBJECT = Map.of(
            "client", "java",
            "message", "Hello from OpenRiak"
    );

    public static void main(String[] args) {
        try {
            System.out.println("=== OpenRiak Java Demo ===");

            String endpoint = "http://" + RIAK_HOST + ":" + RIAK_PORT;
            OpenRiakClient client = OpenRiakClient.builder()
                    .endpoint(endpoint)
                    .protocol(new OpenRiakHttpProtocol())
                    .addIdentityResolver(loginIdentityResolver(
                            env("RIAK_USER", ""),
                            env("RIAK_PASSWORD", "")))
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

            GetDefaultObjectOperationInput getInput = GetDefaultObjectOperationInput.builder()
                    .bucket(BUCKET)
                    .key(KEY)
                    .build();

            JsonObject result;
            try (GetDefaultObjectOutput getOutput = client.getDefaultObject(getInput)) {
                System.out.printf(
                        "Read object  <- bucket='%s' key='%s' status=%d%n",
                        BUCKET,
                        KEY,
                        getOutput.getStatusCode());
                DataStream bodyStream = getOutput.getBody();
                byte[] bodyBytes = bodyStream.asByteBuffer().array();
                result = GSON.fromJson(new String(bodyBytes, StandardCharsets.UTF_8), JsonObject.class);
            }

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

    private static String env(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? defaultValue : value;
    }

    private static IdentityResolver<LoginIdentity> loginIdentityResolver(String username, String password) {
        LoginIdentity identity = LoginIdentity.create(username, password);
        return new IdentityResolver<>() {
            @Override
            public IdentityResult<LoginIdentity> resolveIdentity(Context context) {
                return IdentityResult.of(identity);
            }

            @Override
            public Class<LoginIdentity> identityType() {
                return LoginIdentity.class;
            }
        };
    }
}
